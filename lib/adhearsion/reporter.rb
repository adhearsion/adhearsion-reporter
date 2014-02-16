# encoding: utf-8

require 'toadhopper'

require 'adhearsion'
require 'adhearsion/reporter/airbrake_notifier'
require 'adhearsion/reporter/newrelic_notifier'

module Adhearsion
  class Reporter
    class << self
      def config
        Plugin.config
      end
    end

    class Plugin < Adhearsion::Plugin
      config :reporter do
        api_key nil,                  desc: "The Airbrake/Errbit API key"
        url     "http://airbrake.io", desc: "Base URL for notification service"
        notifier Adhearsion::Reporter::AirbrakeNotifier,
          desc: "The class that will act as the notifier. Built-in classes are Adhearsion::Reporter::AirbrakeNotifier and Adhearsion::Reporter::NewrelicNotifier",
          transform: Proc.new { |v| const_get(v.to_s) }
        enable true, desc: "Disables notifications. Useful for testing"
        excluded_environments [:development, :test], desc: "Skip reporting errors for the listed environments (comma delimited when set by environment variable", transform: Proc.new { |v| names = v.split(','); names = names.each.map &:to_sym }
        newrelic {
          license_key 'MYKEY', desc: "Your license key for New Relic"
          app_name "My Application", desc: "The name of your application as you'd like it show up in New Relic"
          monitor_mode false, desc: "Whether the agent collects performance data about your application"
          developer_mode false, desc: "More information but very high overhead in memory"
          log_level 'info', desc: "The newrelic's agent log level"
        }
      end

      init :reporter do
        Reporter.config.notifier.init
        Events.register_callback(:exception) do |e, logger|
          Reporter.config.notifier.instance.notify e
        end
      end
    end
  end
end
