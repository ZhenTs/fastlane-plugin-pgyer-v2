# pgyer_v2 plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-pgyer-v2)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-pgyer-v2`, add it to your project by running:

#### Upload apk / ipa
```ruby
lane :beta do
  gym
  pgyer_v2_upload(api_key: "xxxxxxxxx", user_key: "xxxxxxxxx")
end
```
#### Upload and update app shortcut url
```ruby
lane :beta do
  gym
  pgyer_v2_upload(api_key: "xxxxxxxxx", user_key: "xxxxxxxxx")
  pgyer_v2_update(api_key: "xxxxxxxxx", user_key: "xxxxxxxxx",buildKey:"xxxxxxxxx",buildShortcutUrl:"xxxxx")
end

```

## About pgyer_v2

pgyer fastlane plugin with api v2

**Note to author:** Add a more detailed description about this plugin here. If your plugin contains multiple actions, make sure to mention them here.

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

**Note to author:** Please set up a sample project to make it easy for users to explore what your plugin does. Provide everything that is necessary to try out the plugin in this project (including a sample Xcode/Android project if necessary)

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
