# Browbeat

[![NYU](https://github.com/NYULibraries/nyulibraries-assets/blob/master/lib/assets/images/nyu.png)](https://dev.library.nyu.edu)
[![Build Status](https://travis-ci.org/NYULibraries/browbeat.svg)](https://travis-ci.org/NYULibraries/browbeat)
[![Code Climate](https://codeclimate.com/github/NYULibraries/browbeat/badges/gpa.svg)](https://codeclimate.com/github/NYULibraries/browbeat)
[![Coverage Status](https://coveralls.io/repos/github/NYULibraries/browbeat/badge.svg?branch=master)](https://coveralls.io/github/NYULibraries/browbeat?branch=master)

Beat you over the head with browser integration testing for the NYU Libraries suite of Web applications.

The purpose of this test suite is to provide comprehensive health checks that run in the cloud (i.e. SauceLabs) and provide automated feedback via e-mail reports and statuspage.io updates.

## Run the test suite

### Run locally

Run all tests:

```
rake browbeat:check:all
```

Run just tests for a specific application:

```
rake browbeat:check:primo
rake browbeat:check:login
rake browbeat:check:pds
```

Run only tests for previously failing applications (per StatusPage):

```
rake browbeat:recheck:failures
```

#### Environment-variable configuration

Specify recipient of email notifications:

```
rake browbeat:check:all FAILURE_EMAIL_RECIPIENT=example@nyu.edu
```

Disable StatusPage integration and email notifications:

```
rake browbeat:check:all FAILURE_TRACKER=false
```

Specify PhantomJS installation:

```
rake browbeat:check:all PHANTOMJS=/full/path/to/phantomjs
```

Specify timeout and max wait:

```
rake browbeat:check:all MAX_WAIT=30 TIMEOUT=6
```

Run tests only for a specific app environment:

```
rake browbeat:check:all BROWBEAT_ENV=production
rake browbeat:check:all BROWBEAT_ENV=staging
```

All above configuration is also available to `browbeat:recheck:failures` task. 

### Run on Docker

First, install docker and ensure your environment is configured per `DOCKER.md`.

You will need to add a passwordless private key `id_rsa` to the project root. This key needs Github access to the [Configula repository](https://github.com/NYULibraries/configula) for this docker configuration to work with Figs and Configula.

Run all tests:

```
rake docker:browbeat:check:all
```

Run just tests for a specific application:

```
rake docker:browbeat:check:primo
rake docker:browbeat:check:login
rake docker:browbeat:check:pds
```

### Run on Selenium and SauceLabs

Using a configuration based on one described in [a post by dankohn](https://github.com/saucelabs/sauce_ruby/issues/261), we can trigger running on sauce with the `DRIVER` environment variable set to `"sauce"`, e.g.:

```
DRIVER=sauce rake browbeat:check:all
```

Note that `DRIVER` may also be set as a browser name to run via selenium in that browser, e.g.:

```
DRIVER=firefox rake browbeat:check:all
```

Without the `DRIVER` set, tests will be run via poltergeist:

```
rake browbeat:check:all
```

#### Dependencies

Sauce on Cucumber requires `sauce-cucumber` and `sauce-connect` gems. These require `cucumber` version `< 2.0`.

#### "Swappable Sauce" on Cucumber

Unfortunately, none of Sauce's documentation mentions how to configure tests to be run either in poltergeist or in sauce. We're limited mainly by the vexing decision to trigger sauce tests with the `@selenium` tag. This is all the more vexing of a design decision since `@selenium` replaces the current driver with `@selenium` in vanilla capybara. To get around this, we've added a callback to disable this override as suggested in a [post by dankohn](https://github.com/saucelabs/sauce_ruby/issues/261).

## Notifications

### Emails

Browbeat will send email notifications in the event of a failure. Emails will sort failures first by service, then by environment (production or staging), then by failure type. Failures will include the scenario failed, the exception thrown, and the step (and line number) at which it failed.

Browbeat will notify that all services are operational only if any service was previously set to failing in StatusPage.

This functionality requires that `FAILURE_EMAIL_RECIPIENT` be set.

### StatusPage

Browbeat will sync with StatusPage using components listed in `config/application.yml`, where keys represent subdirectories of the `features` directory and `status_page_id` specifies the component ID used by the StatusPage API. Given no failures for an application, it will set it to operational. Given any failures, it will set the component to the most severe failure, as determined by tags on the scenarios: `@major_outage`, `@partial_outage`, and `@degraded_performance`

This functionality requires that both `STATUS_PAGE_API_KEY` and `STATUS_PAGE_PAGE_ID` be set.

### Outage definitions

Tests use tags for different grades of outage copied from statuspage.io's excellent [definitions](https://help.statuspage.io/knowledge_base/topics/overview-1):

#### OPERATIONAL

Operational means exactly what it sounds like. The component is functioning as expected and in a timely manner.

#### DEGRADED PERFORMANCE

Degraded Performance means the component is working but is slow or otherwise impacted in a minor way. An example of this would be if you were experiencing an unusually high amount of traffic and the component was taking longer to perform its job than normal.

#### PARTIAL OUTAGE

Components should be set to Partial Outage when they are completely broken for a subset of customers. An example of this would be if some subset of customer's data lived in a specific data center that was down. The component might be broken for that subset of customers but is working for the rest and thus there is a Partial Outage.

#### MAJOR OUTAGE

Components should be set to Major Outage when they are completely unavailable.
