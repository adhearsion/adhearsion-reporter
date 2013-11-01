# encoding: utf-8

require 'new_relic/control'

module Adhearsion
  class Reporter
    class NewrelicNotifier
      include Singleton

      def init
        NewRelic::Agent.manual_start(Adhearsion::Reporter.config.newrelic.to_hash)
      end

      def notify(ex)
        NewRelic::Agent.notice_error(ex)
      rescue Exception => e
        logger.error "Error posting exception to Newrelic"
        logger.warn "Original exception message: #{e.message}"
        raise
      end
    end
  end
end
