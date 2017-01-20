# encoding: utf-8
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See License in the project root for license information.
require 'log4r'
require 'vagrant-azure/util/machine_id_helper'
require 'vagrant-azure/util/vm_await'


module VagrantPlugins
  module Azure
    module Action
      class TerminateInstance
        include VagrantPlugins::Azure::Util::MachineIdHelper
        include VagrantPlugins::Azure::Util::VMAwait

        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_azure::action::terminate_instance')
        end


        def vhd_name( uri )
              unless uri.nil?
                groups = uri.match(/.+\.blob\.core\.windows\.net\/.+\/(.+)/)
                puts groups
                groups.captures[0].strip if groups
              end
        end


        def container_name( uri )
              unless uri.nil?
                groups = uri.match(/.+\.blob\.core\.windows\.net\/(.+)\/.+/)
                puts groups
                groups.captures[0].strip if groups
              end
        end

        def storage_account( uri )
              unless uri.nil?
                groups = uri.match(/.+\/\/(.+)\.blob\.core\.windows\.net\/.+/)
                groups.captures[0].strip if groups
              end
        end

        def resource_group_from_id(id)
          unless id.nil?
            groups = id.match(/.+\/resourceGroups\/([^\/]+)\/.+/)
            groups.captures[0].strip if groups
          end
        end

        def call(env)
          parsed = parse_machine_id(env[:machine].id)

          begin
            env[:ui].info(I18n.t('vagrant_azure.terminating', parsed))

            vm = env[:azure_arm_service].compute.virtual_machines.get( parsed[:group], parsed[:name])
            vhd = vhd_name(vm.storage_profile.os_disk.vhd.uri )
            container = container_name(vm.storage_profile.os_disk.vhd.uri )
            account = storage_account(vm.storage_profile.os_disk.vhd.uri )

            # ok - which resource group is our storage account in?
            storage_resource_group = nil
            storage_accounts = env[:azure_arm_service].storage.storage_accounts.list.value
            storage_accounts.each do |a|
              if ( a.name == account )
                if storage_resource_group.nil?
                  storage_resource_group = resource_group_from_id(a.id)
                else
                  raise "Storage account #{account} appears more than once."
                end
              end
            end

            # get the storage account key .. this is a different key because this
            # service uses a different protocol (?)
            key = env[:azure_arm_service].storage.storage_accounts.list_keys(storage_resource_group, account).keys.first.value

            # delete the resources carefully.. and in the right order.
            env[:azure_arm_service].compute.virtual_machines.delete(parsed[:group], parsed[:name])
            env[:azure_arm_service].blobs.blobs.delete( account, key, container, vhd)


            # don't delete the resource group - ever!  This is bad practice in complex systems - you might be deleting
            # someone elses stuff doing this.
            # env[:azure_arm_service].resources.resource_groups.delete(parsed[:group]).value!.body
            # however, we should delete the resources that the vm was using..

            # @todo


          rescue MsRestAzure::AzureOperationError => ex
            unless ex.response.status == 404
              raise ex
            end
          end
          #env[:ui].info(I18n.t('vagrant_azure.terminated', parsed))

          #env[:machine].id = nil

          @app.call(env)
        end
      end
    end
  end
end
