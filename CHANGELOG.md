### 2.1.3 (2021-Oct-06)

* updated github-release binary

### 2.1.2 (2019-May-08)

* add `releaser::conditional_verify`

### 2.1.1 (2019-Apr-23)

 * updated readme
 * added license notes

### 2.1.0 (2019-Apr-22)

 * make function names clearer
 * rename `verify_version_for_release` to `verify_release_ready`

### 2.0.2 (2019-Apr-22)

 * added `releaser::conditional_release`

### 2.0.1 (2019-Apr-21)

 * minor fixes - added test task for itests with ops-base \#17556

### 2.0.0 (2019-Apr-20)

Breaking changes as part of public publishing \#17555
 * deleted functions without `releaser::` prefix
 * drops oversion support
 * enhanced tests and implementation

### 1.1.0 (2019-Feb-02)

* no need for releaser_init anymore
* each function now starts with `releaser::` (old function names preserved too)

### 1.0.8 (2019-Jan-03)

* add function bump_changelog_version that sets version in changelog only

### 1.0.7 (2019-Jan-03)

* add function verify_changelog_version that verifies only changelog version

### 1.0.6 (2018-Oct-25)

* revert deleting the methods `log_`\*, because we use them in many other projects

### 1.0.5 (2018-Oct-21)

* add new function get_last_version_from_whole_changelog to read the changelog
 file until it finds a line that matches version pattern (the function:
  get_last_version_from_changelog reads only the 1st line)
* removed releaserrc file, we never used it
* rename log functions so that they are not overridden by other bash helpers
* looser check for `Unreleased` in changelog

### 1.0.4 (2018-Jul-09)

* in the function: `verify_version_for_release` recognize many variants of 'unreleased'

### 1.0.3 (2017-Oct-14)

* we still need functions to check that #11709
   * version was not released already
   * version in changelog and in oversion match
even if `Unreleased` is set in Changelog.
* easier check for `Unreleased` in Changelog, added a test

### 1.0.2 (2017-Oct-12)

* always use date in English

### 1.0.1 (2017-Oct-09)

* verify_version_for_release checks for `Unreleased` keyword on top

### 1.0.0 (2017-May-03)

* \#11010 renamed functions:
   * locally_bump_version_in_changelog to set_version_in_changelog
   * locally_bump_version_in_versionfile to set_version_in_file
   * get_next_version to get_next_oversion
   * set_next_version to set_next_oversion
   * verify_version_no_version_file to verify_version_for_release
* \#11008 set_version_in_changelog is now idempotent
* \#11008 set_version_in_changelog supports if "Unreleased" is in the first line

### 0.4.0 (2017-Apr-26)

* add functions to release k8s chart
* logs from set_next_version function now say project name

### 0.3.2 (2017-Apr-16)

* changed arguments order in locally_bump_version_in_versionfile and
 locally_bump_version_in_changelog functions

### 0.3.1 (2017-Apr-16)

* do not set `set -e` in releaser main file
* better readme

### 0.3.0 (2017-Apr-15)

* \#10891 add publish_to_archive function and publish releaser to archive
* get_next_version informs about project name
* the variables file: `releaserrc` is not obligatory
* rls_changelog_file renamed to changelog_file
* rls_version_file renamed to version_file

### 0.2.1 (2017-Apr-14)

* updated readme on how to install releaser
* added releaser_loaded function to load releaser functions once

### 0.2.0 (2017-Apr-14)

* \#10886 use releaser without ide docker image

### 0.1.3 (2017-Apr-14)

* using ide >= 0.8.0 with options `--quiet --force_not_interactive` we can
 use releaser to save any command output to a variable. E.g.:
 ```
 version=$(ide --quiet --force_not_interactive -- "releaser get_next_version")
 ```

### 0.1.2 (2017-Apr-13)

* install openssh in releaser ide docker image
* use releaser from ide docker image to release releaser

### 0.1.1 (2017-Apr-12)

* Install curl in ide docker image.
* Idefile is not needed here.
* releaser-variables file renamed to releaserrc

### 0.1.0 (2017-Apr-12)

Initial release.
