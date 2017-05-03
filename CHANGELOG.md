### 1.0.0 (2017-May-03)

* \#11010 renamed functions:
   * locally_bump_version_in_changelog to set_version_in_changelog
   * locally_bump_version_in_versionfile to set_version_in_file
   * get_next_version to get_next_oversion
   * set_next_version to set_next_oversion
   * verify_version_no_version_file to verify_version_for_release
* \#11008 set_version_in_changelog is now idempotent

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
