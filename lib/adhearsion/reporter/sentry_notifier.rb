# encoding: utf-8

require 'raven'

module Adhearsion
  class Reporter
    class SentryNotifier
      include Singleton

      def init
        Raven.configure do |config|
          Reporter.config.sentry.each do |k,v|
            config.send("#{k}=", v) unless v.nil?
          end
        end
      end

      def notify(ex)
        Raven.capture_exception(ex)
      rescue Exception => e
        logger.error "Error posting exception to Sentry"
        logger.warn "Original exception message: #{e.message}"
        raise
      end

      def self.method_missing(m, *args, &block)
        instance.send m, *args, &block
      end

    end
  end
end
