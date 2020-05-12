require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class AppcenterReleasesHelper

      # create request
      def self.connection(upload_url = nil, dsym = false, csv = false)
        require 'faraday'
        require 'faraday_middleware'

        default_api_url = "https://api.appcenter.ms"

        options = {
          url: upload_url || default_api_url
        }

        UI.message("DEBUG: BASE URL #{options[:url]}") if ENV['DEBUG']

        Faraday.new(options) do |builder|
          if upload_url
            builder.request :multipart unless dsym
            builder.request :url_encoded unless dsym
          else
            builder.request :json
          end
          builder.response :json, content_type: /\bjson$/ unless csv
          builder.use FaradayMiddleware::FollowRedirects
          builder.adapter :net_http
        end
      end
      
      def self.fetch_releases(api_token:, owner_name:, app_name:)
        connection = self.connection(nil, false, true)

        url = "/v0.1/apps/#{owner_name}/#{app_name}/releases"

        UI.message("DEBUG: GET #{url}") if ENV['DEBUG']

        response = connection.get(url) do |req|
          req.headers['X-API-Token'] = api_token
          req.headers['internal-request-source'] = "fastlane"
        end

        UI.message("DEBUG: #{response.status} #{JSON.pretty_generate(response.body)}\n") if ENV['DEBUG']

        case response.status
        when 200...300
          JSON.parse(response.body)
        when 401
          UI.user_error!("Auth Error, provided invalid token")
          false
        when 404
          UI.error("Not found, invalid owner or application name")
          false
        else
          UI.error("Error #{response.status}: #{response.body}")
          false
        end
      end
    end
  end
end
