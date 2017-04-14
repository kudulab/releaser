# releaser

Bash scripts to release various projects.

## Usage

Releaser code consists of bash functions. There are functions to be
 treated as helpers and another functions to be treated as end user functions.

### Install
All the releaser functions are available after you run:
```bash
releaser_loaded || eval "$(curl http://gogs.ai-traders.com/platform/releaser/raw/0.2.0/src/releaser)"
```
You can put it in a script and it won't download releaser only 1st time the
script it run.

---

Or the other way is:
```bash
wget http://gogs.ai-traders.com/platform/releaser/raw/0.2.0/src/releaser
source releaser
```

---

To validate that releaser functions are loaded use: `releaser_loaded` function
or any other releaser function, e.g.: `get_next_version`.

### End user functions
End user functions are used in `tasks` file.  End user should keep a local file: `tasks` with bash tasks (bash switch that
  allows running a limited amount of commands). We run those tasks for
  releaser development:
  * `./tasks bump`
  * `./tasks unit`
  * `./tasks itest`
  * and so on.

Thanks to `tasks` file it is easy to remember which commands to run and we
 run the same commands locally and on CI. There are also examples for:
  * ide docker image [tasks](./test/integration/test-files/ide-docker-image/tasks)

End user functions understand end user variables which are put in `releaserrc` file.

### Helpers functions
Helpers functions allow each project type for custom release cycle. However, you should never reference helpers functions in `tasks` file,
 because helpers functions do not understand end user variables.


### Alpine
If using releaser on Alpine, please run:
```
apk add -U coreutils
```
it is needed for `sort -V` option.

#### Version bump
Any project should keep version in Changelog and in OVersion backend.
We treat version set in OVersion backend (usually Consul) as the only truth
 version in the moment. You should be able to run
   * `./tasks bump` to bump the path version string fragment
   * `./tasks bump 3.44.12` to bump to any version string you want

Get version from OVersion backend:
```
next_version=$(source releaser && get_next_version)
echo "${next_version}"
```

Set version into OVersion backend:
```
source releaser && set_next_version 0.2.4
```

### Dependencies
* Bash
* Curl
* Ssh client

## Development
1. You make changes in a feature branch and git push it.
1. You run tests:
   * `./tasks unit`
   * `./tasks itest`
1. You decide that it is time for GoCD to test and release your code, so you locally:
    * run `./tasks bump` to bump the patch version fragment by 1 or
    `./tasks bump 1.2.3` to bump to a particular version. Version is bumped in Changelog and OVersion backend.
    * merge that branch into master and push to git server
1. CI pipeline tests and releases releaser.

Releaser uses itself, which is treated as true integration test.

## TODO
Idea: implement a function to write to changelog with `Unreleased` in contents.
 So that release stage can be failed if such changelog contents.
