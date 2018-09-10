adhearsion-reporter
==================

Report Adhearsion application exceptions and deployments to:

* [Airbrake](http://airbrake.io)
* [Errbit](https://github.com/errbit/errbit)
* [Sentry](https://sentry.io/)

This Adhearsion plugin requires Adhearsion 2.0 or later.  For Adhearsion 1.0 try the previous version of this gem [ahn_hoptoad](https://github.com/mojolingo/ahn_hoptoad)

Usage
-----

To use this gem, add the following line to your Gemfile:

```ruby
gem 'adhearsion-reporter'
```

To view the available configuration options, run the rake task:

```
rake adhearsion:config:show[reporter]
```

The configuration options are added to config/adhearsion.rb with the rest of Adhearsion's configuration.  Example:

```ruby
Adhearsion.config do |config|
  config.reporter.api_key = "YOUR API KEY HERE"
end
```

Email Notifier
--------------
Email notification uses the [pony](https://github.com/benprew/pony) gem.
The `email` configuration key is passed to Pony on initialization using `Pony.options`.

To set the destination address and the sender address, for example, you can use:

```ruby
Adhearsion::Reporter.config.email = {
  via: :sendmail,
  to: 'recv@domain.ext',
  from: 'send@domain.ext'
}
```

Copyright
---------

Copyright (C) 2012 Adhearsion Foundation Inc.
Released under the MIT License - Check [License file](https://github.com/adhearsion/adhearsion-reporter/blob/master/LICENSE)
