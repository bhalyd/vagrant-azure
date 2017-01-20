require 'azure_mgmt_storage'

module VagrantPlugins
  module Azure
    module Services
      class StorageAccountsExtended < ::Azure::ARM::Storage::StorageAccounts





        def delete_vhd(vhd_url, custom_headers=nil)
          response = delete_vhd_async(vhd_url, custom_headers).value!
          nil
        end

        def delete_vhd_async(vhd_url, custom_headers=nil)
          fail ArgumentError, 'vhd_url is nil' if vhd_url.nil?
          fail ArgumentError, '@client.api_version is nil' if @client.api_version.nil?
          fail ArgumentError, '@client.subscription_id is nil' if @client.subscription_id.nil?

          request_headers = {}

          # Set Headers
          request_headers['x-ms-client-request-id'] = SecureRandom.uuid
          request_headers['accept-language'] = @client.accept_language unless @client.accept_language.nil?
          request_headers['x-ms-date'] = Time.now.utc.strftime("%a, %e %b %Y %H:%M:%S GMT")

          puts request_headers['x-ms-date']
          request_url = vhd_url

          options = {
              middlewares: [[MsRest::RetryPolicyMiddleware, times: 3, retry: 0.02], [:cookie_jar]],
              query_params: {'api-version' => @client.api_version},
              headers: request_headers.merge(custom_headers || {}),
          }
          promise = @client.make_request_async(:delete, vhd_url, options)

          promise = promise.then do |result|
            http_response = result.response
            status_code = http_response.status
            response_content = http_response.body
            unless status_code == 200 || status_code == 204
              error_model = JSON.load(response_content)
              fail MsRestAzure::AzureOperationError.new(result.request, http_response, error_model)
            end

            result.request_id = http_response['x-ms-request-id'] unless http_response['x-ms-request-id'].nil?

            result
          end

          promise.execute
        end #end delete_vhd_async

      end
    end
  end
end
