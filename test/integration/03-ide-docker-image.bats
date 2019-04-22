load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

releaser=$(readlink -f ./src/releaser)
ide_docker_image_dir="test/integration/test-files/ide-docker-image"
ide_docker_image_dir=$(readlink -f ${ide_docker_image_dir})

setup() {
  rm -rf "${ide_docker_image_dir}/.git"
}

teardown() {
  if [[ -d "${ide_docker_image_dir}/.git" ]]; then
    # without this check, the below command concerns git tree found in that
    # or higher dir - releaser git tree
    /bin/bash -c "cd ${ide_docker_image_dir} && git reset --hard"
    rm -rf "${ide_docker_image_dir}/.git"
  fi
}

@test "not-existent-command" {
  rm -rf "${ide_docker_image_dir}/.git"
  run /bin/bash -c "cd ${ide_docker_image_dir} && source ${releaser} && RELEASER_LOG_LEVEL=debug ./tasks not-existent-command"
  assert_output --partial "Invalid command: 'not-existent-command'"
  assert_equal "$status" 1
}
@test "bump fails if new version not set and cannot get version from changelog" {
  rm -rf "${ide_docker_image_dir}123"
  mkdir -p "${ide_docker_image_dir}123"
  run /bin/bash -c "cd ${ide_docker_image_dir}123 && source ${releaser} && RELEASER_LOG_LEVEL=debug releaser::bump_changelog_version"
  echo "output: ${output}"
  assert_output --partial "CHANGELOG.md does not exist"
  assert_equal "$status" 1

  # cleanup
  rm -rf "${ide_docker_image_dir}123"
}
@test "set_version succeeds when specified version in arguments" {
  run /bin/bash -c "cd ${ide_docker_image_dir} && git init && git add --all && git commit -m first && ./tasks set_version 0.1.5"
  echo "output: ${output}"
  assert_output --partial "New version will be: 0.1.5"
  assert_equal "$status" 0

  run /bin/bash -c "cat ${ide_docker_image_dir}/CHANGELOG.md | head -1 | grep \"### 0.1.5 (20\""
  assert_equal "$status" 0
}
@test "set_version succeeds when Unreleased in changelog - same version changelog contains" {
  run /bin/bash -c "cd ${ide_docker_image_dir} && git init && git add --all && git commit -m first && changelog_file=CHANGELOG-unreleased.md RELEASER_LOG_LEVEL=debug ./tasks set_version 0.1.1"
  echo "output: ${output}"
  assert_output --partial "Changing current unreleased head of changelog"
  assert_output --partial "New version will be: 0.1.1"
  assert_output --partial "Bumped to 0.1.1"
  assert_equal "$status" 0

  run /bin/bash -c "cat ${ide_docker_image_dir}/CHANGELOG-unreleased.md | grep -c \"### 0.1.1 (20\""
  assert_output "1"
  assert_equal "$status" 0
  # unreleased flag should have been removed
  run /bin/bash -c "cat ${ide_docker_image_dir}/CHANGELOG-unreleased.md | grep -c \"Unreleased\""
  assert_output "0"
  assert_equal "$status" 1
}
@test "set_version succeeds when Unreleased in changelog and changelog contains different version" {
  run /bin/bash -c "cd ${ide_docker_image_dir} && git init && git add --all && git commit -m first && changelog_file=CHANGELOG-unreleased.md RELEASER_LOG_LEVEL=debug ./tasks set_version 0.28.2"
  echo "output: ${output}"
  assert_output --partial "Changing current unreleased head of changelog"
  assert_output --partial "New version will be: 0.28.2"
  assert_output --partial "Bumped to 0.28.2"
  assert_equal "$status" 0

  run /bin/bash -c "cat ${ide_docker_image_dir}/CHANGELOG-unreleased.md | grep -c \"### 0.28.2 (20\""
  assert_output "1"
  assert_equal "$status" 0
  run /bin/bash -c "cat ${ide_docker_image_dir}/CHANGELOG-unreleased.md | grep -c \"Unreleased\""
  assert_output "0"
  assert_equal "$status" 1
}
@test "set_version with unreleased flag succeeds when Unreleased in changelog and changelog contains different version" {
  run /bin/bash -c "cd ${ide_docker_image_dir} && git init && git add --all && git commit -m first && changelog_file=CHANGELOG-unreleased.md RELEASER_LOG_LEVEL=debug ./tasks set_version 0.28.2 unreleased"
  echo "output: ${output}"
  assert_output --partial "Changing current unreleased head of changelog"
  assert_output --partial "New version will be: 0.28.2"
  assert_output --partial "Bumped to 0.28.2"
  assert_equal "$status" 0

  run /bin/bash -c "cat ${ide_docker_image_dir}/CHANGELOG-unreleased.md | grep -c \"### 0.28.2 - Unreleased\""
  assert_output "1"
  assert_equal "$status" 0
}

@test "verify_version returns 1 when there is git tag for last changelog version" {
  run /bin/bash -c "cd ${ide_docker_image_dir} && git init && git add --all && git commit -m first && git tag 0.1.1 && ./tasks verify_version"
  echo "output: ${output}"
  assert_output --partial "The last version from changelog was already git tagged"
  assert_equal "$status" 1
}
@test "verify_version returns 0 when there is no git tag for last changelog version" {
  # we pretend that 0.1.0 was already released and next version is 0.1.1 (not released)
  run /bin/bash -c "cd ${ide_docker_image_dir} && git init && git add --all && git commit -m first && git tag 0.1.0 && ./tasks verify_version_for_release"
  echo "output: ${output}"
  assert_output --partial "Version was not released before"
  assert_equal "$status" 0
}
@test "verify_version returns 1 when changelog first line contains string: 'Unreleased'" {
  run /bin/bash -c "cd ${ide_docker_image_dir} && source ${releaser} && set_next_oversion \"0.1.1\""
  run /bin/bash -c "cd ${ide_docker_image_dir} && git init && changelog_file=CHANGELOG-unreleased.md ./tasks verify_version_for_release"
  echo "output: ${output}"
  assert_output --partial "Top of changelog has 'Unreleased' flag"
  assert_equal "$status" 1
}
