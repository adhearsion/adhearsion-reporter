require 'spec_helper'

describe Adhearsion::Reporter do
  EventClass = Class.new
  ExceptionClass = Class.new StandardError

  context "with a DummyNotifier" do
    class DummyNotifier
      include Singleton
      attr_reader :initialized, :notified
      def init
        @initialized = true
      end

      def notify(ex)
        @notified = ex
      end
    end

    before(:each) do
      Adhearsion::Reporter.config.notifier = DummyNotifier
      Adhearsion::Plugin.init_plugins
      Adhearsion::Events.trigger_immediately :exception, ExceptionClass.new
    end

    it "calls init on the notifier instance" do
      Adhearsion::Reporter.config.notifier.instance.initialized.should == true
    end

    it "logs an exception event" do
      sleep 0.25
      Adhearsion::Reporter.config.notifier.instance.notified.class.should == ExceptionClass
    end
  end

  context "with a AirbrakeNotifier" do
    before(:each) do
      Adhearsion::Reporter.config.notifier = Adhearsion::Reporter::AirbrakeNotifier
    end

    it "should initialize correctly" do
      Toadhopper.should_receive(:new).with(Adhearsion::Reporter.config.api_key, notify_host: Adhearsion::Reporter.config.url)
      Adhearsion::Plugin.init_plugins
    end

    context "exceptions" do
      let(:mock_notifier) { double 'notifier' }
      let(:event_error)   { ExceptionClass.new }

      before { Toadhopper.should_receive(:new).at_least(:once).and_return(mock_notifier) }

      after do
        Adhearsion::Plugin.init_plugins
        Adhearsion::Events.trigger_immediately :exception, event_error
      end

      it "should notify Airbrake" do
        mock_notifier.should_receive(:post!).at_least(:once).with(event_error, hash_including(framework_env: :production)).and_return(double('response').as_null_object)
      end

      context "with an environment set" do
        before { Adhearsion.config.platform.environment = :foo }

        it "notifies airbrake with that environment" do
          mock_notifier.should_receive(:post!).at_least(:once).with(event_error, hash_including(framework_env: :foo)).and_return(double('response').as_null_object)
        end
      end

      context "in excluded environments" do
        before do
          Adhearsion.config.platform.environment = :development
          Adhearsion::Plugin.init_plugins
        end
        it "should not report errors for excluded environments" do
          mock_notifier.should_not_receive(:post!)
        end
      end
    end
  end

  context "with a NewrelicNotifier" do
    before(:each) do
      Adhearsion::Reporter.config.notifier = Adhearsion::Reporter::NewrelicNotifier
    end

    it "should initialize correctly" do
      NewRelic::Agent.should_receive(:manual_start).with(Adhearsion::Reporter.config.newrelic.to_hash)
      Adhearsion::Plugin.init_plugins
    end

    it "should notify Newrelic" do
      NewRelic::Agent.should_receive(:manual_start)

      event_error = ExceptionClass.new
      NewRelic::Agent.should_receive(:notice_error).at_least(:once).with(event_error)

      Adhearsion::Plugin.init_plugins
      Adhearsion::Events.trigger_immediately :exception, event_error
    end
  end
end
