# UAT Testing

UAT is the "test" deployment of SCSB. This repo contains a set of tests that can be played against the SCSB API. They're collected here mainly to document how they've been tested in the past. Many of the tests depend on certain data conditions to be met, which may change as a result of running these tests (and partner activity).

Tests are assigned numbers from [this spreadsheet](https://docs.google.com/spreadsheets/d/1xTRg69K1gR5S66y3UXOf_ASA-yjQgNPO/edit?ts=5f57dfa2#gid=1447839939), where more information (and some sample data) can be found.

## Setup

```
cp .env-sample .env
```

Update `.env` with target UAT instance and api key.

## Running tests

To run a single test:

```
source .env; bundle exec rspec -fd --tag number:7
```

Enable `debug` logging to get verbose request logging, which may be useful for bug reports:

```
source .env; LOG_LEVEL=debug bundle exec rspec -fd --tag number:7
```
