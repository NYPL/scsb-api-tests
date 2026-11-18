# UAT Testing

UAT is the "test" deployment of SCSB. This repo contains a set of tests that can be played against the SCSB API. They're collected here mainly to document how they've been tested in the past. Many of the tests depend on certain initial data conditions to be met, which may change as a result of running these tests (and partner activity).

Tests are assigned numbers from these NYPL test sheets, which include criteria and some sample data:
 - [Sep/Oct 2020 NYPL Test sheet](https://docs.google.com/spreadsheets/d/1xTRg69K1gR5S66y3UXOf_ASA-yjQgNPO/edit?ts=5f57dfa2#gid=1447839939)
 - [March 2021 NYPL Test sheet (Phase IV, Stage 2)](https://docs.google.com/spreadsheets/d/1KnMgycTN5Vyx-PeFcDyLp5rcqvuN3m8e/edit#gid=822006474)
 - [June 2021 NYPL Test sheet (Phase IV, Stage 3)](https://docs.google.com/spreadsheets/d/19AQjgU6IFLHPISI7D2f84ppRsfCAIgtFb7pFiISoaDo/edit#gid=747913097)
 - [Sep 2021 NYPL Test sheet (Phase IV, Stage 3)](https://docs.google.com/spreadsheets/d/1bcoPxLDbj6ZnkqOaLmMCAjl1zBrczIzktkdcLfaFyEE)
 - [Nov 15 2021 NYPL Test sheet (Phase IV, Stage 3 round 2)](https://docs.google.com/spreadsheets/d/1rczCw7KepBDqSXOAbQDrXyIyE58SEF7u_xrXGCsP24U)
 - [June 2022 Release - UAT Test Cases - Regression)](https://docs.google.com/spreadsheets/d/1dmq2klImquGSY3hykRNxzgxIJ6qXfMumt3jbjtBt0ek)
 - [Dec 2022 Release - UAT Test Cases - Regression](https://docs.google.com/spreadsheets/d/1djlZfAdjYl6SLtXgZY75s9DLcWYeJgV0wZfY8Kpy65M/edit#gid=715491896)
 - [May 7 2024](https://docs.google.com/spreadsheets/d/1NVsZdlNuyvJpz279n-WVOsR4WdtS7TZtDTdtKrSbtt8/edit#gid=715491896)
 - [Oct 2025](https://docs.google.com/spreadsheets/d/1W3DmoNia-EsqjMAbTXyrYAKw9YKzA6r1mp8oEjp-Sk4/edit?gid=715491896#gid=715491896)
 - [Nov 2026](https://docs.google.com/spreadsheets/d/11uEMx_N1XH9Z7hU4CDj9VoTcSMLWbkrDWh0wx-zmE0A/edit?gid=715491896#gid=715491896)

## Setup

```
cp .env-sample .env
```

Update `.env` with target UAT instance and api key.

## UAT Workflow

Periodically, a candidate release is made available in the "UAT" environment. Our team will be assigned a number of "API" tests in a large collaborative testing spreadsheet.

For each test we're assigned:
 - Read the test and find the relevant test in this codebase
 - Update this test suite to ensure the "S.No" value in the spreadsheet matches the relevant test by tag (e.g. `number: 7`)
 - (When assigning a new test number to a test, make sure the tag isn't duplicated in an older test)
 - Read the test so that you understand the intent
 - If the test targets a hard-coded record, verify it exists in a desired state. Consider using `select_random_nypl_*` helper functions to auto-select random records to operate on.
 - Run the test as follows and record the ouput in the "Testers Remarks" column of the spreadsheet and mark it as PASS/FAIL.

```
source .env; LOG_LEVEL=debug bundle exec rspec -fd --tag number:7
```

If a test can not be performed because it's not understood or you're missing necessary data, mark it as BLOCKED and write an explanation in "Testers Remarks"
