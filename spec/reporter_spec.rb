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

      def self.method_missing(m, *args, &block)
        instance.send m, *args, &block
      end
    end

    before(:each) do
      Adhearsion::Reporter.config.notifier = DummyNotifier
      Adhearsion::Plugin.init_plugins
      Adhearsion::Events.trigger_immediately :exception, ExceptionClass.new
    end

    it "calls init on the notifier instance" do
      expect(Adhearsion::Reporter.config.notifier.instance.initialized).to be(true)
    end

    it "logs an exception event" do
      sleep 0.25
      expect(Adhearsion::Reporter.config.notifier.instance.notified.class).to eq(ExceptionClass)
    end
  end

  context "with a AirbrakeNotifier" do
    before(:each) do
      Adhearsion::Reporter.config.notifier = Adhearsion::Reporter::AirbrakeNotifier
    end

    it "should initialize correctly" do
      expect(Toadhopper).to receive(:new).with(Adhearsion::Reporter.config.api_key, notify_host: Adhearsion::Reporter.config.url)
      Adhearsion::Plugin.init_plugins
    end

    context "exceptions" do
      let(:mock_notifier) { double 'notifier' }
      let(:event_error)   { ExceptionClass.new }
      let(:response)      { double('response').as_null_object }

      before { expect(Toadhopper).to receive(:new).at_least(:once).and_return(mock_notifier) }

      after do
        Adhearsion::Plugin.init_plugins
        Adhearsion::Events.trigger_immediately :exception, event_error
      end

      it "should notify Airbrake" do
        expect(mock_notifier).to receive(:post!).at_least(:once).with(event_error, hash_including(framework_env: :production)).and_return(response)
      end

      context "with an environment set" do
        before { Adhearsion.config.platform.environment = :foo }

        it "notifies airbrake with that environment" do
          expect(mock_notifier).to receive(:post!).at_least(:once).with(event_error, hash_including(framework_env: :foo)).and_return(response)
        end
      end

      context "in excluded environments" do
        before do
          Adhearsion.config.platform.environment = :development
          Adhearsion::Plugin.init_plugins
        end
        it "should not report errors for excluded environments" do
          expect(mock_notifier).to_not receive(:post!)
        end
      end
    end
  end

  context "with a NewrelicNotifier" do
    before(:each) do
      Adhearsion::Reporter.config.notifier = Adhearsion::Reporter::NewrelicNotifier
    end

    it "should initialize correctly" do
      expect(NewRelic::Agent).to receive(:manual_start).with(Adhearsion::Reporter.config.newrelic.to_hash)
      Adhearsion::Plugin.init_plugins
    end

    it "should notify Newrelic" do
      expect(NewRelic::Agent).to receive(:manual_start)

      event_error = ExceptionClass.new
      expect(NewRelic::Agent).to receive(:notice_error).at_least(:once).with(event_error)

      Adhearsion::Plugin.init_plugins
      Adhearsion::Events.trigger_immediately :exception, event_error
    end
  end

  context 'with an EmailNotifier' do
    let(:email_options) do
      {
        via: :sendmail,
        to: 'recv@domain.ext'
      }
    end

    let(:time_freeze) { Time.parse("2014-07-24 17:30:00") }

    let(:fake_backtrace) do
      [
        '1: foo',
        '2: bar'
      ]
    end

    let(:error_message) { "Something bad" }

    before(:each) do
      Adhearsion::Reporter.config.notifier = Adhearsion::Reporter::EmailNotifier
      Adhearsion::Reporter.config.email = email_options
    end

    it "should initialize correctly" do
      Adhearsion::Plugin.init_plugins
      expect(Pony.options).to be(email_options)
    end

    it "should notify via email" do

      event_error = ExceptionClass.new error_message
      event_error.set_backtrace(fake_backtrace)

      hostname = Socket.gethostname
      environment = Adhearsion.config.platform.environment.to_s.upcase

      Timecop.freeze(time_freeze) do
        expect(Pony).to receive(:mail).at_least(:once).with({
          subject: "[#{Adhearsion::Reporter.config.app_name}-#{environment}] Exception: ExceptionClass (#{error_message})",
          body: "#{Adhearsion::Reporter.config.app_name} reported an exception at #{time_freeze.to_s}\n\nExceptionClass (#{error_message}):\n#{event_error.backtrace.join("\n")}\n\n",
          from: hostname
        })

        Adhearsion::Plugin.init_plugins
        Adhearsion::Events.trigger_immediately :exception, event_error
      end
    end
  end

  context "with a SentryNotifier" do
    let(:sentry_options) do
      {
        "dsn" => 'https://123abc:def456@app.getsentry.com/98765',
        "environments" => ['production', 'staging'],
        "current_environment" => 'production'
      }
    end

    before(:each) do
      Adhearsion::Reporter.config.notifier = Adhearsion::Reporter::SentryNotifier
      Adhearsion::Reporter.config.sentry = sentry_options
    end

    it "should initialize correctly" do
      Adhearsion::Plugin.init_plugins

      config = Raven.configuration
      sentry_options.each do |k, v|
        if k == "dsn"   #There is no getter for this attribute, so we have to get it through it components
          expect("#{config.scheme}://#{config.public_key}:#{config.secret_key}@#{config.host}/#{config.path}#{config.project_id}").to eq v
        else
          expect(Raven.configuration.send("#{k}")).to eq v
        end
      end
    end

    it "should notify Sentry" do
      expect(Raven).to receive(:configure)
      event_error = ExceptionClass.new
      expect(Raven).to receive(:capture_exception).at_least(:once).with(event_error)

      Adhearsion::Plugin.init_plugins
      Adhearsion::Events.trigger_immediately :exception, event_error
    end
  end

  context "with multiple notifiers" do

    class BaseNotifier
      include Singleton

      attr_reader :initialized, :notified

      def init
        @initialized = true
      end

      def notify(ex)
        @notified = ex
      end

      def self.method_missing(m, *args, &block)
        instance.send m, *args, &block
      end
    end

    class MockNotifier < BaseNotifier; end
    class AnotherMockNotifier < BaseNotifier; end

    before(:each) do
      Adhearsion::Events.clear_handlers(:exception)
      Adhearsion::Reporter::config.notifiers = [MockNotifier, AnotherMockNotifier]
      Adhearsion::Plugin.init_plugins
      Adhearsion::Events.trigger_immediately :exception, ExceptionClass.new
    end

    it "calls init on each of the notifier instances" do
      Adhearsion::Reporter::config.notifiers.each do |notifier|
        expect(notifier.instance.initialized).to be(true)
      end
    end

    it "logs an exception in each of the registered notifiers" do
      Adhearsion::Reporter::config.notifiers.each do |notifier|
        expect(notifier.instance.notified.class).to eq(ExceptionClass)
      end
    end
  end
end
