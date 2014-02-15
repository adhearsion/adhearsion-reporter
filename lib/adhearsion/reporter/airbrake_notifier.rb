# encoding: utf-8

require 'toadhopper'

module Adhearsion
  class Reporter
    class AirbrakeNotifier
      include Singleton

      def init
        @notifier = Toadhopper.new Reporter.config.api_key, :notify_host => Reporter.config.url
        @options = {
          framework_env: Adhearsion.config.platform.environment,
          notifier_name: 'adhearsion-reporter',
          notifier_version: Adhearsion::REPORTER_VERSION,
          project_root: Adhearsion.config.platform[:root]
        }
      end

      def notify(ex)
        return unless should_post?
        response = @notifier.post!(ex, @options)
        if !response.errors.empty? || !(200..299).include?(response.status.to_i)
          logger.error "Error posting exception to #{Reporter.config.url}! Response code #{response.status}"
          response.errors.each do |error|
            logger.error "#{error}"
          end
          logger.warn "Original exception message: #{ex.message}"
        end
      end

    private
      def should_post?
        Reporter.config.enable &&
          !Reporter.config.excluded_environments.include?(@options[:framework_env])
      end
    end
  end
end
