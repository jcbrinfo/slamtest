# Change log
## 0.2.1 (2016-04-17)
### Fixed
* Remove the `version-` prefix from the outputted version.
* Include the commit hash when versionning a clean snapshot.

## 0.2.0 (2016-04-17)
This is the first release of SlamTest as an independent project. The list of
changes below compares this release to the differents versions that were
included in various projects.

### Added
* More complete documentation.
* Option parsing.
* Versioning.
* Self-tests.
* Built-in manual.
* Option to run a specific test case.
* Options to customize paths.
* Option to skip incomplete test definitions.
* A way to specify the exact expected exit status (see the “Changed” subsection
  below).
* Options to customize the output format.
* Optional structured formats (JSON and CSV).

### Changed
* Do not hard-code test cases’ variants.
* Do not hard-code how to run a test.
* Create directories for generated files when needed.
* Check for missing expected output.
* For test that should return a non-zero exit status, instead of using a
  different directory for the input files, seek the expected exit status in the
  directory named `exit`.

## Fixed
* Do not assume expected output directories to exist.
* Do not assume outputs to be regular files.
* Do not use the `-q` option of `diff` (non-POSIX).
* Fix various quoting mistakes.
* Replace `diff` by `cmp` when comparing regular files.
* Execute the specified command without considering the defined functions.
* Handle race conditions on multiple calls to `mkdir`. For an explanation of the
  importance of this, see the [GNU Coding Standards](http://bit.ly/1VeuAUJ).
* Fix terminology.
