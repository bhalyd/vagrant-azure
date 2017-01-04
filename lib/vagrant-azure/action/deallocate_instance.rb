# encoding: utf-8
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See License in the project root for license information.
require 'log4r'
require 'vagrant-azure/util/machine_id_helper'
require 'vagrant-azure/util/vm_await'
require 'vagrant-azure/util/vm_status_translator'
require 'vagrant-azure/util/timer'

module VagrantPlugins
  module Azure
    module Action
      class DeallocateInstance
        include VagrantPlugins::Azure::Util::MachineIdHelper
        include VagrantPlugins::Azure::Util::VMAwait
        include VagrantPlugins::Azure::Util::VMStatusTranslator

        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_azure::action::deallocate_instance')
        end

        def call(env)
          env[:metrics] ||= {}

          parsed = parse_machine_id(env[:machine].id)
          if env[:machine].state.id == :deallocated
            env[:ui].info(I18n.t('vagrant_azure.already_status', :status => 'deallocated.'))
          else
            env[:ui].info(I18n.t('vagrant_azure.deallocating', parsed))
            env[:azure_arm_service].compute.virtual_machines.deallocate(parsed[:group], parsed[:name])

            # Wait for the instance to be ready first
            env[:metrics]['instance_stop_time'] = Util::Timer.time do

              env[:ui].info(I18n.t('vagrant_azure.waiting_for_deallocation'))

              task = await_true(env) do |vm|
                deallocated?(vm.properties.instance_view.statuses)
              end

              if task.value
                env[:ui].info(I18n.t('vagrant_azure.deallocated', parsed))
              else
                raise I18n.t('vagrant_azure.errors.failed_deallocating', parsed) unless env[:interrupted]
              end
            end

            env[:ui].info(I18n.t('vagrant_azure.deallocated', parsed))
          end

          @app.call(env)
        end
      end
    end
  end
end
