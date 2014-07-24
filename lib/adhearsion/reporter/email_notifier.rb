# encoding: utf-8

require 'pony'

module Adhearsion
  class Reporter
    class EmailNotifier
      include Singleton

      def init

      end

      def notify(ex)

      end

      def self.method_missing(m, *args, &block)
        instance.send m, *args, &block
      end
    end
  end
end
