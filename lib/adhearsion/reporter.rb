# encoding: utf-8
require 'toadhopper'

module Adhearsion
  class Reporter < Plugin
    config :reporter do
      api_key nil,                  :desc => "The Airbrake/Errbit API key"
      url     "http://airbrake.io", :desc => "Base URL for notification service"
    end

    init :reporter do
      config = Adhearsion.config[:reporter]
      notifier = Toadhopper.new config.api_key, :notify_host => config.url
      Events.register_callback(:exception) do |e, logger|
        response = notifier.post!(e)
        if !response.errors.empty? || !(200..299).include?(response.status.to_i)
          logger.error "Error posting exception to #{config.url}! Response code #{response.status}"
          response.errors.each do |error|
            logger.error "#{error}"
          end
          logger.warn "Original exception message: #{e.message}"
        end
      end
    end
  end
end
