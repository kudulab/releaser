# releaser

Bash scripts to release various projects.

## Install
All the releaser functions are available after you install it.

### In current shell
If you want to run releaser in current shell:
```bash
releaser::loaded || eval "$(curl https://github.com/kudulab/releaser/releases/download/${RELEASER_VERSION}/releaser)"
```
 Do not use it in a script as it would always redownload the file.

### In a script

If you want to run releaser from a script:
```bash
set -Eeuo pipefail

RELEASER_VERSION="2.0.0"
RELEASER_FILE="ops/releaser-${RELEASER_VERSION}"

mkdir -p ops
if [[ ! -f $RELEASER_FILE ]];then
  wget --quiet -O $RELEASER_FILE https://github.com/kudulab/releaser/releases/download/${RELEASER_VERSION}/releaser
fi
source $RELEASER_FILE
```

Your `.gitignore` should include `ops/`.

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

command="$1"
case "${command}" in
  set_version)
      releaser::bump_changelog_version "$2"
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

## Development
1. You make changes in a feature branch and git push it.
1. You run tests:
   * `./tasks unit`
   * `./tasks itest`
1. You decide that it is time for GoCD to test and release your code, so you locally:
    * run `./tasks set_version` to bump the patch version fragment by 1 or
    `./tasks set_version 1.2.3` to bump to a particular version. Version is bumped in the CHANGELOG.md.
    * merge that branch into master and push to git server
1. CI pipeline tests and releases releaser.
