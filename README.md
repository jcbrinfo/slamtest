# SlamTest
A simple BASH script to run tests.

# Requirements

* A POSIX-compliant system (Linux, *BSD, OS X, Cygwin, etc.)
* BASH
* make, to build SlamTest itself or to run the self-tests

# Usage
SlamTest is a simple BASH script that runs a program against a series of inputs
and checks that the outputs match the expected ones. The simpliest way to use
this script is to follow the steps below:

1. While at root of the SlamTest’s project, invoke `make` (or `make all`).
2. Copy the `target/main/slamtest` file in your project. For example, you may
   place this file in the `lib/test/bash` directory of your project. Do not
   forget to make the file executable (`chmod u+x lib/test/bash/slamtest`).
3. For each test case, put the input file in the `src/test/resources/in`
   directory and the expected output in the `src/test/resources/out` directory
   of your project. Both files must have the same name and this name is the name
   of test case.
4. To run all the test cases, launch the previously copied script from the root
   directory of your project, with the command to test as the arguments.
   Example: `lib/test/bash/slamtest java -cp target/main com.example.MyProgram`

The script will output a list of the results of every test, followed with a
count of the success and failures. The list is formatted as a task list written
in the [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/#GitHub-flavored-markdown).
This allow to use the output of the SlamTest directly as comments on GitHub.
The actual outputs of the tested program are stored in the `target/test/out`
directory. Note that the outputs combine bytes that the tested program writes in
the standard output (`STDOUT`) and the standard error output (`STDERR`). A
non-zero exit status counts as a fail.

Now, SlamTest allows many variations of the aforementioned procedure.

## Varying argument
Sometimes, you may want to run the same test case multiple times, but with
differents arguments passed to the program. For example, you may need to test
multiple iterations of the same algorithm. In order to do this, for each variant
of a test, put an output file in a `src/test/resources/out-<arg>` directory
instead of the usual `src/test/resources/out` directory, where `<arg>` is the
argument to append to the command specified to the script.

For example, let’s say we have a test case named `a_test` as the only file in
the `src/test/resources/in` directory. When you launch
`lib/test/bash/slamtest target/main/my_program`, SlamTest will invoke the command
`target/main/my_program` (with `src/test/resources/in/a_test` as the standard
input) if the file `src/test/resources/out/a_test` exists, then
`target/main/my_program 42` if the file `src/test/resources/out-42/a_test`
exists.

The same way expected outputs in `src/test/resources/out` are compared with
actual outputs stored in `target/test/out`, each file in
`src/test/resources/out-<arg>` are compared with an output that is stored in
`target/test/out-<arg>`. So, for a file in `src/test/resources/out-42`, the
actual output produced by the tested program is saved in `target/test/out-42`.

## End of options
When parsing the options passed to it, SlamTest follows the POSIX conventions.
So, you can use a `--` argument to explicitly mark the end of the options and
the start of the command to test.

## Complex commands and directories as inputs for test cases
By default, SlamTest runs the specified command by redirecting the standard input
and outputs, and append an additional argument when needed (see “Varying
argument”). However, there are some situation were the tested program need to be
invoked differently. May be the input file are actualy directories, may be the
program requires the filenames as arguments… To handle these cases, SlamTest
has the `-l` that takes the path of a BASH script that defines the `run_test`
function.

The `run_test` is called to run each test and takes at most 3 arguments, with
the last one being optional. The arguments are, respectively:

1. The path to the input file.
2. The path to which the output is redirected.
3. The additional argument to pass to the tested program (see “Varying
   argument”).

The list of the arguments passed to SlamTest that are not options (that is the
tested command if you do not redefine `run_test`) is stored as an array in the
`tested_command` global variable.

Here is the default definition of `run_test`:
```
run_test() {
	"${tested_command[@]}" "${@:3}" < "$1" > "$2" 2>&1
}
```

Note: The script specified to the `-l` is included (“sourced”) directly by
SlamTest’s script. So, avoid defining any global variable (or BASH option) other
than `run_test` in the included script in order to avoid disturbing the inner
workings of main script.

## Expecting non-zero exit statuses
Testing normal conditions is great. Testing also cases the program is expected
to crash is better. For the latter cases, all you need to do is to write a file
with the expected exit status as it content. This file must have the same name
as the input file, and must be in the `src/test/resources/exit` directory of
your project.

For example, if you expect your program to return `42` when running the test
case `foo`, just create the `src/test/resources/exit/foo` file with `42` in it.

## Custom paths
Until now, we used the `src/test/resources` directory for the test case
definitions and `target/test` directory for the files generated while running
the tests. These are the defaults, but you can specify different locations.
To change the path of the test definitions (`src/test/resources` by default),
use the `-d` option. To specify the path of the generated files (`target/test`
by default), use the `-g` option.

## Running only one test case
To run only one test case, specify its name using the `-t` option.

## Script’s output customization
Even if the default output of SlamTest is great, the `-f` option allows to
customize this output. Its argument is composed of two character: one for the
list of the individual results, then one for the summary line. The default value
is `tl` (GitHub task list, long summary line). The first character (for the list
of results) can take the following values:

* `_`: Write nothing at all.

* `c`: Write the content of a RFC 4180 (CSV) file, without the header. For each
  test, write a row with the following 6 fields:
	1. The name of the test case.
	2. The filename of the directory of the expected output, or an empty string
	   if no such file was found.
	3. The degree of success of the test. Here are the possible values:
		* `OK`: Success.
		* `EXIT_MISMATCH`: Unexpected exit code.
		* `OUT_MISMATCH`: Unexpected output.
		* `INTERNAL_ERROR`: Error raised by SlamTest itself (internal error).
		  This usually means that `diff` returned a unexpected exit status.
		* `NO_ACTUAL_OUT`: The file containing the actual output of the test
		  was not found.
		* `NO_EXPECTED_OUT`: No file describing the expected output found. In
		  that case, `""` is used in place of the aforementioned directory name.
	4. The expected exit status. This field is empty for `NO_EXPECTED_OUT`
	   (and may be empty for `INTERNAL_ERROR`).
	5. The exit status of the tested program. Its value is empty for
	  `NO_EXPECTED_OUT` (and may be empty for `INTERNAL_ERROR`).
	6. The additional details. This field is empty for most results except
	   `INTERNAL_ERROR`.

  Example:
  ```
  foo,"out",OK,0,0,
  bar,"out-42",EXIT_MISMATCH,0,21,
  baz,"",NO_EXPECTED_OUT,,,
  ```

* `j`: Write a JSON object where the keys are the test cases’ names. Each value
  is another JSON object with the filename of the directory of the expected
  output as the key of each entry. Each value is again a JSON object with the
  following keys:
	* `"result"`: The degree of success of the test. Here are the possible
	  values:
		* `"OK"`: Success.
		* `"EXIT_MISMATCH"`: Unexpected exit code.
		* `"OUT_MISMATCH"`: Unexpected output.
		* `"INTERNAL_ERROR"`: Error raised by SlamTest itself (internal error).
		  This usually means that `diff` returned a unexpected exit status.
		* `"NO_ACTUAL_OUT"`: The file containing the actual output of the test
		  was not found.
		* `"NO_EXPECTED_OUT"`: No file describing the expected output found. In
		  that case, `""` is used in place of the aforementioned directory name.
	* `"expected_exit"`: The expected exit status. Its value is `null` for
	  `"NO_EXPECTED_OUT"` (and may be `null` for `"INTERNAL_ERROR"`).
	* `"exit"`: The exit status of the tested program. Its value is `null` for
	  `"NO_EXPECTED_OUT"` (and may be `null` for `"INTERNAL_ERROR"`).
	* `"message"`: The additional details. The corresponding value is `null` for
	  most results except `"INTERNAL_ERROR"`.

  Example:
  ```
  {
  	"foo": {
  		"out": {
  			"result": "OK",
  			"expected_exit": 0,
  			"exit": 0,
  			"message": null
  		}
  	},
  	"bar": {
  		"out-42": {
  			"result": "EXIT_MISMATCH",
  			"expected_exit": 0,
  			"exit": 21,
  			"message": null
  		}
  	},
  	"baz": {
  		"": {
  			"result": "NO_EXPECTED_OUT"
  			"expected_exit": null,
  			"exit": null,
  			"message": null
  		}
  	}
  }
  ```

* `t` (default): Write a GitHub task list.

  Example:
  ```
  - [x] `foo`: success
  - [ ] `bar` (42): exit status not 0: got 21
  - [ ] `baz`: expected output missing
  ```

The second character (for the summary line) can take the following values:

* `_`: Write nothing at all.

* `c`: Write the content of a RFC 4180 (CSV) file, without the header. Write a
  row with the following 3 fields:
	1. The total number of tests.
	2. The number of successes.
	3. The number of fails.

  Example:
  ```
  3,1,2
  ```

* `j`: Write a JSON object with the following keys:
	* `"tests"`: The total number of tests.
	* `"successes"`: The number of successes.
	* `"fails"`: The number of fails.

  Example:
  ```
  {"tests": 3, "successes": 1, "fails": 2}
  ```

* `l` (default): Enumerate the count of tests, successes and fails.

  Example:
  ```
  3 tests, 1 success, 2 fails.
  ```

* `s`: Write a summary as a score, that is a fraction of the number of successes
  over the total number of tests.

  Example:
  ```
  1/3
  ```

Note: When neither character of the argument is `_`, an empty line divide the
two outputs.

## Missing expected outputs
By default, finding no expected output at all for a given test case (either in
`src/test/resources/out` or in `src/test/resources/out-*`) count as a fail. If
you want to silently skip the test case instead, use the `-s` flag.

## Ignored files
Because SlamTest uses a glob pattern that does not explicitly include files
whose name begins with a dot, the test cases with that kind of name are silently
ignored (except when explicitly specified with the `-t` option). You may exploit
this behaviour at your advantage (or not)…

## Exit status
To make it easy to combine SlamTest with your other tools, the meaning of the
following exit statuses is fixed:

* 0: All tests pass.
* 1: At least one test fail.
* 2: The script is not used correctly.

## Built-in help
To display the embeded manual, use the `-h` option.

## Version
To show the current version of the script, use the `-v` option.

# Project structure
* `COPYING`: The project’s license.
* `lib/test/bash/slamtest`: An older (simplier) version of the script used to
  test the current version.
* `Makefile`
* `README.md`: The ocumentation’s entry point (this file).
* `src/`: The source files.
	* `main/bash/slamtest`: The test runner.
	* `test/`: The self-tests.
		* `bash/self_test.sh`: The file loaded by SlamTest when testing itself.
		  See `Makefile`.
		* `resources/`: The definitions of self-tests.
			* `in/`: The inputs (directories) of the test cases. Each test case
			  is like a mini-project.
				* `<test_case>/main`: The script to run for the `<test_case>`
				  test case. The standard outputs are the output of the test.
				  The script takes the path to the current version of SlamTest
				  as its only parameter. When the test case is run, the current
				  working directory is the one of the test case.
			* `out/`: The expected outputs. WARNING: The files may contain some
			  carriage returns (U+000D) that must be preserved as-is. Edit
			  carefully (by using an command like `nano -N output_file`).
* `target/`: The generated files.
	* `test/`: The files generated during the self-tests.
		* `in/`: A copy of the test cases located in `src/test/resources/in`.
		  The test cases are copied here to contain the side-effect of running
		  the self-tests. That way, SlamTest can write output files in the
		  `target/test/out` directory of each sub-project without altering the
		  `src` directory of the main project.
		* `out/`: The self-tests’ output.
* `version`: A POSIX shell script used that computes version number.

# Running the self-tests
To test the current version using the older (simplier) version located in
`lib/test/bash/`, run `make check-with-lib`. To test the current version using
itself, run `make check-with-src`. To run both targets, use `make check`.

Note: As specified by GNU Coding Standards, theses targets do not have `all` as
a dependency. So, to build the script and run all the self-tests in one command,
you need to invoke `make all check`.

Note: Because we test things like backslashes in filenames, some tests are
incompatible with Microsoft’s systems.

# Versioning
Stable releases are marked by applying a `version-<version number>` tag to these
commits. Version numbers comply with [Semantic Versioning](http://semver.org),
version 2.0.0. In the source file (`src/main/bash/slamtest`), `$VERSION$` marks
locations where the build script has to put the actual version of SlamTest while
generating `target/main/slamtest`.

# Goals
Writting test cases using well-established test framework is usually a good
practice. But when the situation makes the process so laborious that it
discourages developpers to write tests, we miss the goal of using these
tools. Sometimes, the programming langage in which the project is written
forces the authors to write a ton of lines for a simple test. Other times, the
project is just a tiny toy program and writting elegant test suites would take
a lot more time than writting the actual program. Also, when testing a compiler
or an interpreter, it is often simplier to use a small snippet a the input
instead of an elaborate syntax tree.

SlamTest was created to test these type of projects. The main goal is to make
test creation and execution as simple as possible (just write two files by test
case and launch a script) while keeping SlamTest itself small enough so you can
embed it easily in any project. The first inspiration for the initial design was
the scripts used to test [Nit](http://nitlanguage.org). Since then, many changes
have been made based on the use cases encountered by SlamTest’s author.

# License
See `COPYING`.
