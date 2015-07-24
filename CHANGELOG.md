# develop
  * Handle case where exception is passed with no backtrace in EmailReporter
  * Add notifiers array to allow multiple notifiers
  * EmailReporter added

# v2.1.0
  * Bugfix: record the correct environment with each notification
  * Feature: include a little more metadata with each notification
  * Feature: ignore notification from configurable list of environments (default: development and test)
  * Feature: include hostname and Adhearsion version in environment portion of report

# v2.0.1
  * Bugfix: Adhearsion may pass a logger object with exception events

# v2.0.0
  * First release
