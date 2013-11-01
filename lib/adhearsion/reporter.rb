# encoding: utf-8

require 'toadhopper'

Adhearsion::Reporter = Class.new Adhearsion::Plugin

require 'adhearsion/reporter/airbrake_notifier'
require 'adhearsion/reporter/newrelic_notifier'

module Adhearsion
  class Reporter
    config :reporter do
      api_key nil,                  desc: "The Airbrake/Errbit API key"
      url     "http://airbrake.io", desc: "Base URL for notification service"
      notifier Adhearsion::Reporter::AirbrakeModifier, desc: "The class that will act as the notifier"
      enable true, desc: "Disables notifications. Useful for testing"
      newrelic {
        license_key 'MYKEY', desc: "Your license key for New Relic"
        app_name "My Application", desc: "The name of your application as you'd like it show up in New Relic"
        monitor_mode false, desc: "Whether the agent collects performance data about your application"
        developer_mode false, desc: "More information but very high overhead in memory"
        log_level 'info', desc: "The newrelic's agent log level"
      }
    end

    init :reporter do
      Reporter.config.notifier.instance.init
      Events.register_callback(:exception) do |e, logger|
        Reporter.config.notifier.instance.notify e
      end
    end
  end
end
