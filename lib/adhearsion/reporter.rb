# encoding: utf-8

require 'toadhopper'

require 'adhearsion'
require 'adhearsion/reporter/airbrake_notifier'
require 'adhearsion/reporter/newrelic_notifier'
require 'adhearsion/reporter/email_notifier'
require 'adhearsion/reporter/sentry_notifier'

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
        app_name "Adhearsion", desc: "Application name, used for reporting"
        notifier Adhearsion::Reporter::AirbrakeNotifier,
          desc: "The class that will act as the notifier. Built-in classes are Adhearsion::Reporter::AirbrakeNotifier, Adhearsion::Reporter::NewrelicNotifier, and Adhearsion::Reporter::SentryNotifier. This option is deprecated; please specify in `notifiers`.",
          transform: Proc.new { |v| const_get(v.to_s) }
        notifiers [],
          desc: "Collection of classes that will act as notifiers",
          transform: Proc.new { |v| v.split(',').map { |n| n.to_s.constantize } }
        enable true, desc: "Whether to send notifications - set to false to disable all notifications globally (useful for testing)"
        env nil,
          desc: "Custom environment for error reporting. May be different from the application environment.",
          transform: Proc.new { |v| v.to_sym }
        excluded_environments [:development, :test], desc: "Skip reporting errors for the listed environments (comma delimited when set by environment variable", transform: Proc.new { |v| names = v.split(','); names = names.each.map &:to_sym }
        newrelic {
          license_key 'MYKEY', desc: "Your license key for New Relic"
          app_name "My Application", desc: "The name of your application as you'd like it show up in New Relic"
          monitor_mode false, desc: "Whether the agent collects performance data about your application"
          developer_mode false, desc: "More information but very high overhead in memory"
          log_level 'info', desc: "The newrelic's agent log level"
        }
        email Hash.new(via: :sendmail), desc: "Used to configure the email notifier, with options accepted by the pony (https://github.com/benprew/pony) gem"
        sentry {
          dsn 'https://<user>:<password>@app.getsentry.com/<application>', desc: "The SENTRY_DSN, or client key that has been created in Sentry"
          current_environment 'production', 'The current execution environment'
          environments ['production'], 'The environments for which Sentry is active'
        }
      end

      init :reporter do
        # If a collection of multiple notifiers is not set, fall back to the individual option for BC.
        # TODO: Remove the `notifier` option in v3.0
        if Reporter.config.notifiers.empty?
          Reporter.config.notifiers = [Reporter.config.notifier]
        end

        Reporter.config.notifiers.each do |notifier|
          notifier.init
          Events.register_callback(:exception) do |e, logger|
            notifier.notify e
          end
        end
      end
    end
  end
end
