# Browbeat

Beat you over the head with browser integration testing for the NYU Libraries suite of Web applications.

The purpose of this test suite is to provide comprehensive health checks that run in the cloud (i.e. SauceLabs) and provide automated feedback via e-mail reports and statuspage.io updates.

## Run the test suite

### Run locally

Run all tests:

```
rake browbeat:check:all
```

Run just primo tests:

```
rake browbeat:check:primo
```

### Run on Docker

First, install docker and ensure your environment is configured per `DOCKER.md`.

Run all tests:

```
rake docker:browbeat:check:all
```

Run just primo tests:

```
rake docker:browbeat:check:primo
```

### Run on SauceLabs

### Run on Jenkins

## Status reports

### Posting callbacks to Statuspage.io

### E-mailing failures to development team

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
