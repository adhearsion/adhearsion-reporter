# encoding: utf-8

require 'pony'

module Adhearsion
  class Reporter
    class EmailNotifier
      include Singleton

      def init
        Pony.options = Adhearsion::Reporter.config.email
      end

      def notify(ex)
        Pony.mail({
          subject: email_subject,
          body: exception_text(ex)
        })
      end

      def self.method_missing(m, *args, &block)
        instance.send m, *args, &block
      end

    private
      def email_subject
        "[#{Adhearsion::Reporter.config.app_name}] Exception"
      end

      def exception_text(exception)
        "#{Adhearsion::Reporter.config.app_name} reported an exception at #{Time.now.to_s}" +
        "\n\n#{exception.class} (#{exception.message}):\n" +
        exception.backtrace.join("\n") +
        "\n\n"
      end
    end
  end
end
