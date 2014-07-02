require 'adhearsion'
require 'adhearsion/reporter'
require 'socket'

ENV['AHN_ENV'] = 'production'

RSpec.configure do |config|
  config.tty = true

  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
