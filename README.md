# UAT Testing

UAT is the "test" deployment of SCSB. This repo contains a set of tests that can be played against the SCSB API. They're collected here mainly to document how they've been tested in the past. Many of the tests depend on certain initial data conditions to be met, which may change as a result of running these tests (and partner activity).

Tests are assigned numbers from these NYPL test sheets, which include criteria and some sample data:
 - [Sep/Oct 2020 NYPL Test sheet](https://docs.google.com/spreadsheets/d/1xTRg69K1gR5S66y3UXOf_ASA-yjQgNPO/edit?ts=5f57dfa2#gid=1447839939)
 - [March 2021 NYPL Test sheet](https://docs.google.com/spreadsheets/d/1KnMgycTN5Vyx-PeFcDyLp5rcqvuN3m8e/edit#gid=822006474)

## Setup

```
cp .env-sample .env
```

Update `.env` with target UAT instance and api key.

## Running tests

Because of the finicky nature of these tests, you'll probably want to run them one at a time as follows:
1. Read the test so that you understand the intent
2. Verify that the records implicated in the test exist in a testable state (e.g. if it's a deaccession, confirm that the barcode is Available). Update test to use different ids if necessary.
3. Run the test and record the result and output in the testing spreadsheet.

To run a single test:

```
source .env; bundle exec rspec -fd --tag number:7
```

Enable `debug` logging to get verbose request logging, which may be useful for bug reports:

```
source .env; LOG_LEVEL=debug bundle exec rspec -fd --tag number:7
```
