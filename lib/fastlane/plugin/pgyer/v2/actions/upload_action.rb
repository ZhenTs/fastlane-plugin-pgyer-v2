require 'faraday'
require 'faraday_middleware'

# require 'fastlane/action'
# require_relative '../helper/pgyer_v2_helper'

module Fastlane
  module Actions
    module SharedValues
      PGYER_API_KEY = :PGYER_API_KEY
      PGYER_USER_KEY = :PGYER_USER_KEY
      PGYER_BUILD_KEY = :PGYER_BUILD_KEY
      PGYER_BUILD_TYPE = :PGYER_BUILD_TYPE
      PGYER_BUILD_NAME = :PGYER_BUILD_NAME
      PGYER_BUILD_VERSION = :PGYER_BUILD_VERSION
      PGYER_BUILD_PACKAGE_ID = :PGYER_BUILD_PACKAGE_ID
      PGYER_BUILD_DOWNLOAD_URL = :PGYER_BUILD_DOWNLOAD_URL
      PGYER_BUILD_QRCODE_URL = :PGYER_BUILD_QRCODE_URL
      PGYER_BUILD_PASSWORD = :PGYER_BUILD_PASSWORD
    end

    class PgyerV2UploadAction < Action
      def self.run(params)
        UI.message("The pgyer_v2 plugin is working!")
        api_host = "https://www.pgyer.com/apiv2/app/upload"
        api_key = params[:api_key]
        user_key = params[:user_key]

        Actions.lane_context[Fastlane::Actions::SharedValues::PGYER_API_KEY] =api_key
        Actions.lane_context[Fastlane::Actions::SharedValues::PGYER_USER_KEY] = user_key

        build_file = [
            params[:ipa],
            params[:apk]
        ].detect { |e| !e.to_s.empty? }

        if build_file.nil?
          UI.user_error!("You have to provide a build file")
        end

        UI.message "build_file: #{build_file}"

        password = params[:password]
        if password.nil?
          password = ""
        end

        Actions.lane_context[Fastlane::Actions::SharedValues::PGYER_BUILD_PASSWORD] = password


        update_description = params[:update_description]
        if update_description.nil?
          update_description = ""
        end

        install_type = params[:install_type]
        if install_type.nil?
          install_type = "1"
        end

        channel_shortcut = params[:channel_shortcut]
        if channel_shortcut.nil?
          channel_shortcut = ""
        end

        install_date = params[:install_date]
        if install_date.nil?
          install_date = "2"
        end

        install_start_date = params[:install_start_date]
        if install_start_date.nil?
          install_start_date = ""
        end

        install_end_date = params[:install_end_date]
        if install_end_date.nil?
          install_end_date = ""
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
            'file' => Faraday::UploadIO.new(build_file, 'application/octet-stream'),
            'buildInstallType' => install_type,
            'buildPassword' => password,
            'buildUpdateDescription' => update_description,
            'buildInstallDate' => install_date,
            'buildInstallStartDate' => install_start_date,
            'buildInstallEndDate' => install_end_date,
            'buildChannelShortcut' => channel_shortcut,
        }

        UI.message "Start upload #{build_file} to pgyer..."

        response = pgyer_client.post api_host, params
        info = response.body

        if info['code'] != 0
          UI.user_error!("PGYER Plugin Error: #{info['message']}")
        end

        data = info['data']

        Actions.lane_context[Fastlane::Actions::SharedValues::PGYER_BUILD_KEY] = data['buildKey']
        Actions.lane_context[Fastlane::Actions::SharedValues::PGYER_BUILD_TYPE] = data['buildType']
        Actions.lane_context[Fastlane::Actions::SharedValues::PGYER_BUILD_NAME] = data['buildName']
        Actions.lane_context[Fastlane::Actions::SharedValues::PGYER_BUILD_VERSION] = data['buildVersion']
        Actions.lane_context[Fastlane::Actions::SharedValues::PGYER_BUILD_PACKAGE_ID] = data['buildIdentifier']
        Actions.lane_context[Fastlane::Actions::SharedValues::PGYER_BUILD_DOWNLOAD_URL] = "https://www.pgyer.com/#{data['buildShortcutUrl']}"
        Actions.lane_context[Fastlane::Actions::SharedValues::PGYER_BUILD_QRCODE_URL] = data['buildQRCodeURL']

        UI.success "Upload success. Visit this URL to see: #{ data['buildShortcutUrl']}"

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

      def self.available_options
        [
            FastlaneCore::ConfigItem.new(key: :api_key,
                                         env_name: "PGYER_API_KEY",
                                         description: "api_key in your pgyer account",
                                         optional: false,
                                         type: String),
            FastlaneCore::ConfigItem.new(key: :user_key,
                                         env_name: "PGYER_USER_KEY",
                                         description: "user_key in your pgyer account",
                                         optional: false,
                                         type: String),
            FastlaneCore::ConfigItem.new(key: :apk,
                                         env_name: "PGYER_APK",
                                         description: "Path to your APK file",
                                         default_value: Actions.lane_context[SharedValues::GRADLE_ALL_APK_OUTPUT_PATHS].select{|item|item.include?"armeabi-v7a-release.apk"}.at(0),
                                         optional: true,
                                         verify_block: proc do |value|
                                           UI.user_error!("Couldn't find apk file at path '#{value}'") unless File.exist?(value)
                                         end,
                                         conflicting_options: [:ipa],
                                         conflict_block: proc do |value|
                                           UI.user_error!("You can't use 'apk' and '#{value.key}' options in one run")
                                         end),
            FastlaneCore::ConfigItem.new(key: :ipa,
                                         env_name: "PGYER_IPA",
                                         description: "Path to your IPA file. Optional if you use the _gym_ or _xcodebuild_ action. For Mac zip the .app. For Android provide path to .apk file",
                                         default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                         optional: true,
                                         verify_block: proc do |value|
                                           UI.user_error!("Couldn't find ipa file at path '#{value}'") unless File.exist?(value)
                                         end,
                                         conflicting_options: [:apk],
                                         conflict_block: proc do |value|
                                           UI.user_error!("You can't use 'ipa' and '#{value.key}' options in one run")
                                         end),
            FastlaneCore::ConfigItem.new(key: :password,
                                         env_name: "PGYER_PASSWORD",
                                         description: "set password to protect app",
                                         optional: true,
                                         type: String),
            FastlaneCore::ConfigItem.new(key: :update_description,
                                         env_name: "PGYER_UPDATE_DESCRIPTION",
                                         description: "set update description for app",
                                         optional: true,
                                         type: String),
            FastlaneCore::ConfigItem.new(key: :install_type,
                                         env_name: "PGYER_INSTALL_TYPE",
                                         description: "set install type for app (1=public, 2=password, 3=invite). Please set as a string",
                                         optional: true,
                                         type: String),
            FastlaneCore::ConfigItem.new(key: :channel_shortcut,
                                         env_name: "PGYER_CHANNEL_SHORTCUT",
                                         description: "set channel shortcut for app. Please set as a string",
                                         optional: true,
                                         type: String),
            FastlaneCore::ConfigItem.new(key: :install_date,
                                         env_name: "PGYER_INSTALL_DATE",
                                         description: "set the installation validity period,（1=set the effective time, 2=long-term effective). Please set as a string",
                                         optional: true,
                                         type: String),
            FastlaneCore::ConfigItem.new(key: :install_start_date,
                                         env_name: "PGYER_INSTALL_START_DATE",
                                         description: "set the start time of the validity period.Please set as a string.Like 2018-01-01",
                                         optional: true,
                                         type: String),
            FastlaneCore::ConfigItem.new(key: :install_end_date,
                                         env_name: "PGYER_INSTALL_END_DATE",
                                         description: "set the end time of the validity period.Please set as a string.Like 2019-01-01",
                                         optional: true,
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
