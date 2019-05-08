# releaser

Bash functions to release any type of project.

## Why and features

 * `releaser` is a single file, versioned and released after testing the functions
 * Any project can quickly and easily reference the functions by downloading a specific release from github
 * The `releaser` file is easy to review and hack with, there is no magic framework to learn, just plain bash and git commands. When something does not fit your needs, it is easy to fall back to writing your own script.
 * It works on nearly any setup because of minimal dependencies

Use the functions as you like, but the primary goal is to support following rules regarding project lifecycle:
1. `CHANGELOG.md` is the single source of truth about current project version.
    - **only when** top of changelog has version and date, then current commit is ready for a release
1. We make a distinction between a source code release (pushing a git tag to the repository) and publishing of the project (which is specific to the language/technology used). Source code release happens before publishing of the project.
1. Releases are automated, executed by CI-system only after all tests have passed.
1. Releases are immutable - once a tag is published, there is no way back. This is a guarantee for the users.

A full-blown example of this lifecycle can be found in:
 * [docker-terraform-dojo](https://github.com/kudulab/docker-terraform-dojo)
 * [docker-hugo-dojo](https://github.com/kudulab/docker-hugo-dojo)

## Install
All the releaser functions are available after you source the `releaser` file.

### In a script

If you want to run releaser from a script:
```bash
set -Eeuo pipefail

RELEASER_VERSION="2.1.0"
RELEASER_FILE="ops/releaser-${RELEASER_VERSION}"

mkdir -p ops
if [[ ! -f $RELEASER_FILE ]];then
  wget --quiet -O $RELEASER_FILE https://github.com/kudulab/releaser/releases/download/${RELEASER_VERSION}/releaser
fi
source $RELEASER_FILE
```

Your `.gitignore` should include `ops/`.

### In current shell
If you want to run releaser in current shell:
```bash
releaser::loaded || eval "$(curl https://github.com/kudulab/releaser/releases/download/${RELEASER_VERSION}/releaser)"
```
 Do not use it in a script as it would always redownload the file.

### Dependencies

Following should suffice:
* Bash
* Curl
* Ssh client
* Git

[ops-base](https://github.com/kudulab/ops-base) provides a full specification of environment in which releaser will work.

### Alpine
If using releaser on Alpine, please run:
```
apk add -U coreutils
```
it is needed for `sort -V` option.

## Usage
Provide `./tasks` file with bash `case` (switch). It will allow to run
 a limited number of commands). Example:

```bash
#!/bin/bash

command="$1"
case "${command}" in
  set_version)
      releaser::bump_changelog_version "$2" "$3"
      ;;
  verify)
      releaser::verify_release_ready
      ;;
  unit)
      time bats ./test/unit/*.bats
      ;;
  *)
      echo "Invalid command: '${command}'"
      exit 1
      ;;
esac
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

## License

Copyright 2019 Ewa Czechowska, Tomasz Sętkowski

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
