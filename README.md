# releaser

Bash scripts to release various projects.

## Install
All the releaser functions are available after you install it.

### In current shell
If you want to run releaser in current shell:
```bash
releaser::loaded || eval "$(curl http://archive.ai-traders.com/releaser/1.1.0/releaser)"
```
 Do not use it in a script as it would always redownload the file.

### In a script

If you want to run releaser from a script:
```bash
set -Eeuo pipefail
if [[ ! -f ./releaser ]]; then
  wget --quiet http://http.archive.ai-traders.com/releaser/1.1.0/releaser || { echo "Cannot download releaser, ignoring."; }
fi
if [[ -f ./releaser ]]; then
  source ./releaser
fi
```

### Validate that loaded

To validate that releaser functions are loaded use: `releaser_loaded` function
or any other releaser function, e.g.: `get_next_oversion`.

### Dependencies

Following should suffice:
* Bash
* Curl
* Ssh client

A complete setup, which is actually tested is specified by [ops-base](https://github.com/kudulab/ops-base).

### Alpine
If using releaser on Alpine, please run:
```
apk add -U coreutils
```
it is needed for `sort -V` option.

## Usage
Provide `./tasks` file with bash `case` (switch). It will allow to run
 a limited amount of commands). Example:

```bash
#!/bin/bash

set -Eeuo pipefail
if [[ ! -f ./releaser ]]; then
  wget --quiet http://http.archive.ai-traders.com/releaser/1.1.0/releaser || { echo "Cannot download releaser, ignoring."; }
fi
if [[ -f ./releaser ]]; then
  source ./releaser
fi

command="$1"
case "${command}" in
  set_version)
      releaser::bump_changelog_and_oversion "$2"
      exit $?
      ;;
  verify)
      releaser::verify_version_for_release
      exit $?
      ;;
  unit)
      time bats ./test/unit/*.bats
      exit $?
      ;;
  *)
      echo "Invalid command: '${command}'"
      exit 1
      ;;
esac
set +e
```

Now you can use it:
* `./tasks set_version`
* `./tasks verify`
* `./tasks unit`

Thanks to `tasks` file it is easy to know which commands to run when working on a project and we
run the same commands locally and on CI.

Examples of `tasks` files:
 * releaser [tasks](./tasks)
 * ide docker image [tasks](./test/integration/test-files/ide-docker-image/tasks)

### Releaser functions
The releaser functions should be documented in code, there is no sense to repeat it here.

You can set those environment variables:
  * `dryrun=true` to avoid writing to files or rsyncing to remote endpoint.
  * `RELEASER_LOG_LEVEL=debug` for more log messages.


### Implementation details
Releaser code consists of bash functions. They allow each project type for custom release cycle.

#### Version bump
Any project should keep version in Changelog and in OVersion backend.
We treat version set in OVersion backend (usually Consul) as the only truth
 version in the moment. You should be able to run
   * `./tasks set_version` to bump the path version string fragment
   * `./tasks set_version 3.44.12` to bump to any version string you want

Get version from OVersion backend:
```
next_version=$(source releaser && releaser::get_next_oversion)
echo "${next_version}"
```

Set version into OVersion backend:
```
source releaser && set_next_oversion 0.2.4
```

## Development
1. You make changes in a feature branch and git push it.
1. You run tests:
   * `./tasks unit`
   * `./tasks itest`
1. You decide that it is time for GoCD to test and release your code, so you locally:
    * run `./tasks set_version` to bump the patch version fragment by 1 or
    `./tasks set_version 1.2.3` to bump to a particular version. Version is bumped in Changelog and OVersion backend.
    * merge that branch into master and push to git server
1. CI pipeline tests and releases releaser.

Releaser uses itself, which is treated as true integration test.
