require 'azure_mgmt_storage'
require 'vagrant-azure/services/storage_accounts_ext'
require 'vagrant-azure/services/blobclient'
require 'vagrant-azure/patches/key_permission'


module VagrantPlugins
  module Azure
    module Services
      class StorageManagementClientExtended < ::Azure::ARM::Storage::StorageManagementClient

        # @return [StorageAccountExtended] storage_accounts_ext
        attr_reader :storage_accounts_ext

        # @return [BlobClient] blobs
        attr_reader :blobs


        def initialize( credentials, base_url=nil, options=nil )
          super( credentials, base_url, options )
          @storage_accounts_ext = StorageAccountsExtended.new(self)
          @blobs = BlobClient.new(self)


        end

      end
    end
  end
end
