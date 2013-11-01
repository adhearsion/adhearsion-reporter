# encoding: utf-8

require 'toadhopper'

module Adhearsion
  class Reporter
    class AirbrakeModifier
      include Singleton

      def init
        @notifier = Toadhopper.new Reporter.config.api_key, :notify_host => Reporter.config.url
      end

      def notify(ex)
        response = @notifier.post!(ex) if Reporter.config.enable
        if !response.errors.empty? || !(200..299).include?(response.status.to_i)
          logger.error "Error posting exception to #{Reporter.config.url}! Response code #{response.status}"
          response.errors.each do |error|
            logger.error "#{error}"
          end
          logger.warn "Original exception message: #{ex.message}"
        end
      end
    end
  end
end
