# encoding: utf-8
require 'vagrant-azure/services/blobs'

module VagrantPlugins
  module Azure
    module Services

    class BlobClient < MsRestAzure::AzureServiceClient

      include MsRestAzure

      # @return [String] Subscription credentials that uniquely identify the
      # Microsoft Azure subscription. The subscription ID forms part of the URI
      # for every service call.
      attr_accessor :subscription_id
      attr_accessor :base_url
      attr_reader   :credentials
      attr_reader :blobs

      # @return [String] Client Api Version.
      attr_reader :api_version

      def initialize(credentials, base_url=nil, options=nil)
        super( credentials, options )
        @credentials = credentials
        @base_url = base_url
        @blobs = Blobs.new(self)
        @api_version = '2016-01-01'
      end




    end
  end
  end
end
