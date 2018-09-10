# develop

# v2.3.1
  * Fix Sentry reporting

# v2.3.0
  * Allow reporting of custom environment to Airbrake

# v2.2.0
  * New notifiers: EmailNotifier and SentryNotifier
  * Allow configuring multiple notifiers as a list. The `notifier` option is deprecated in favour of `notifiers`, which can be used the same for a single notifier.

# v2.1.0
  * Bugfix: record the correct environment with each notification
  * Feature: include a little more metadata with each notification
  * Feature: ignore notification from configurable list of environments (default: development and test)
  * Feature: include hostname and Adhearsion version in environment portion of report

# v2.0.1
  * Bugfix: Adhearsion may pass a logger object with exception events

# v2.0.0
  * First release
