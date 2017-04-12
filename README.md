# releaser

Bash scripts to release various projects.

## Usage

There are many functions to choose from. Recommended usage is presented below.

### For docker images
1. You make changes in a feature branch.
1. You decide that it is time for GoCD to test and release your code, so
 you locally:
    * set `releaser-variables` file, example in `test/integration/ide-docker-image`
    * `releaser bump` to bump the patch version fragment by 1 or
    `releaser bump 1.2.3` to bump to a particular version
    * merge that branch into master and push to git server
    * CI pipeline runs: `releaser verify_version`
    * CI pipeline runs: `releaser build` -- TODO: this will probably be removed, because it should not be implemented here, use dockerimagerake gem for now
    * CI pipeline runs: `releaser release`
    * CI pipeline runs: `releaser publish` -- TODO: this will probably be removed, because it should not be implemented here, use dockerimagerake gem for now


Releaser uses itself, which is treated as true integration test.

## Development

Environment to run tests:
```
sudo ./test/install-bats.sh
```

Run unit tests:
```
bats test/unit/*.bats
```

Run integration tests:
```
bats test/integration/*.bats
```
