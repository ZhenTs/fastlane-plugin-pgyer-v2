require 'faraday'
require 'faraday_middleware'

# require 'fastlane/action'
# require_relative '../helper/pgyer_v2_helper'

module Fastlane
  module Actions
    class PgyerV2UpdateAction < Action
      def self.run(params)
        UI.message("The pgyer_v2 plugin is working!")
        api_host = "https://www.pgyer.com/apiv2/app/updateApp"
        api_key = params[:api_key]
        user_key = params[:user_key]
        buildKey = params[:buildKey]

        buildShortcutUrl = params[:buildShortcutUrl]
        if buildShortcutUrl.nil?
          buildShortcutUrl = ""
        end
        # start upload
        conn_options = {
            request: {
                timeout: 1000,
                open_timeout: 300
            }
        }

        pgyer_client = Faraday.new(nil, conn_options) do |c|
          c.request :multipart
          c.request :url_encoded
          c.response :json, content_type: /\bjson$/
          c.adapter :net_http
        end

        params = {
            '_api_key' => api_key,
            'userKey'=>user_key,
            'buildKey' => buildKey,
            'buildShortcutUrl' => buildShortcutUrl,
        }

        UI.message "Start update pgyer app info..."

        response = pgyer_client.post api_host, params
        info = response.body

        if info['code'] != 0
          UI.user_error!("PGYER Plugin Error: #{info['message']}")
        end

        data = info['data']

        Actions.lane_context[Fastlane::Actions::SharedValues::PGYER_BUILD_DOWNLOAD_URL] = "https://www.pgyer.com/#{data['buildShortcutUrl']}"

        UI.success "update success. Visit this URL to see: https://www.pgyer.com/#{ data['buildShortcutUrl']}"

      end

      def self.description
        "pgyer fastlane plugin with api v2"
      end

      def self.authors
        ["zhents"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "pgyer fastlane plugin with api v2"
      end

      def self.output
        [
            ['PGYER_BUILD_DOWNLOAD_URL', '应用短链接'],
        ]
      end

      def self.available_options
        [
            FastlaneCore::ConfigItem.new(key: :api_key,
                                         env_name: "PGYER_API_KEY",
                                         description: "api_key in your pgyer account",
                                         optional: false,
                                         default_value: Actions.lane_context[SharedValues::PGYER_API_KEY],
                                         type: String),
            FastlaneCore::ConfigItem.new(key: :user_key,
                                         env_name: "PGYER_USER_KEY",
                                         description: "user_key in your pgyer account",
                                         default_value: Actions.lane_context[SharedValues::PGYER_USER_KEY],
                                         optional: false,
                                         type: String),
            FastlaneCore::ConfigItem.new(key: :buildKey,
                                         env_name: "PGYER_BUILD_KEY",
                                         description: "app build key",
                                         optional: false,
                                         type: String),
            FastlaneCore::ConfigItem.new(key: :buildShortcutUrl,
                                         env_name: "PGYER_SHORTCUT_URL",
                                         description: "set shortcut url. Please set as a string",
                                         optional: false ,
                                         type: String),
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md
        #
        [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
