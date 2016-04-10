# Change log
## Unreleased
This will be the first release. The list of changes below compares this release
to the differents versions that were included in various projects.

### Added
* More complete documentation.
* Option parsing.
* Versioning.
* Self-tests.
* Built-in manual.
* Option to run a specific test case.

### Changed
* Do not hard-code test cases’ variants.
* Do not hard-code how to run a test.
* Create directories for generated files when needed.
* Check for missing expected output.

## Fixed
* Do not assume expected output directories to exist.
* Do not assume outputs to be regular files.
* Fix various quoting mistakes.
* Replace `diff` by `cmp` to make comparisons more reliable.
