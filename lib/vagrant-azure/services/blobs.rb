# encoding: utf-8
require 'azure'
module VagrantPlugins
  module Azure
    module Services
      class Blobs
        include MsRestAzure

        def initialize( client )
          @client = client
        end

        attr_reader :client

        def list_containers(account_name, key, custom_headers = nil)
          fail ArgumentError, 'account_name is nil' if account_name.nil?
          fail ArgumentError, 'api key is nil' if key.nil?
          fail ArgumentError, '@client.api_version is nil' if @client.api_version.nil?
          fail ArgumentError, '@client.subscription_id is nil' if @client.subscription_id.nil?

          ::Azure.config.storage_account_name = account_name
          ::Azure.config.storage_access_key = key

          service = ::Azure::Blob::BlobService.new
          service.list_containers
        end

        def delete(account_name, key, container,  blob, custom_headers = nil)
          fail ArgumentError, 'account_name is nil' if account_name.nil?
          fail ArgumentError, 'api key is nil' if key.nil?
          fail ArgumentError, 'contiainer is nil' if container.nil?
          fail ArgumentError, 'blob is nil' if blob.nil?
          fail ArgumentError, '@client.api_version is nil' if @client.api_version.nil?
          fail ArgumentError, '@client.subscription_id is nil' if @client.subscription_id.nil?

          ::Azure.config.storage_account_name = account_name
          ::Azure.config.storage_access_key = key
          puts "attemping to delete #{account_name} #{container} / #{blob}"
          service = ::Azure::Blob::BlobService.new
          service.delete_blob( container, blob )
        end


      end
    end
  end
end
