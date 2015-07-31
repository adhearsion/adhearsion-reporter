# encoding: utf-8

require 'pony'
require 'socket'

module Adhearsion
  class Reporter
    class EmailNotifier
      include Singleton

      def init
        Pony.options = Adhearsion::Reporter.config.email
      end

      def notify(ex)
        Pony.mail({
          subject: email_subject(ex),
          body: exception_text(ex),
          from: hostname
        })
      end

      def self.method_missing(m, *args, &block)
        instance.send m, *args, &block
      end

    private
      def email_subject(exception)
        "[#{Adhearsion::Reporter.config.app_name}-#{environment}] Exception: #{exception.class} (#{exception.message})"
      end

      def exception_text(exception)
        "#{Adhearsion::Reporter.config.app_name} reported an exception at #{Time.now.to_s}" +
        "\n\n#{exception.class} (#{exception.message}):\n" +
        exception.backtrace.join("\n") +
        "\n\n"
      end

      def environment
        Adhearsion.config.platform.environment.to_s.upcase
      end

      def hostname
        Socket.gethostname
      end
    end
  end
end
