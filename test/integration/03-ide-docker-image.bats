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
  /bin/bash -c "cd ${ide_docker_image_dir} && source ${releaser} && set_next_oversion 0.1.0"
}

@test "not-existent-command" {
  rm -rf "${ide_docker_image_dir}/.git"
  run /bin/bash -c "cd ${ide_docker_image_dir} && source ${releaser} && RELEASER_LOG_LEVEL=debug ./tasks not-existent-command"
  assert_output --partial "Invalid command: 'not-existent-command'"
  assert_equal "$status" 1
}
@test "bump fails if new version not set and cannot get version from OVersion backend" {
  rm -rf "${ide_docker_image_dir}123"
  mkdir -p "${ide_docker_image_dir}123"
  run /bin/bash -c "cd ${ide_docker_image_dir}123 && source ${releaser} && RELEASER_LOG_LEVEL=debug bump_changelog_and_oversion"
  echo "output: ${output}"
  assert_output --partial "oversion.yml does not exist"
  assert_equal "$status" 1

  # cleanup
  rm -rf "${ide_docker_image_dir}123"
}
@test "bump succeeds if new version not set and we can get version from OVersion backend" {
  run /bin/bash -c "cd ${ide_docker_image_dir} && git init && git add --all && git commit -m first && ./tasks bump_old"
  echo "output: ${output}"
  assert_output --partial "Got next_version from Consul for docker-releaser-test: 0.1.0"
  assert_output --partial "New version will be: 0.1.1"
  assert_output --partial "Bumped to 0.1.1"
  assert_output --partial "Set next_version into Consul for docker-releaser-test: 0.1.1"
  assert_equal "$status" 0

  run /bin/bash -c "cat ${ide_docker_image_dir}/image/etc_ide.d/variables/60-variables.sh | grep \"0.1.1\""
  assert_equal "$status" 0
  run /bin/bash -c "cat ${ide_docker_image_dir}/CHANGELOG.md | head -1 | grep \"### 0.1.1 (20\""
  assert_equal "$status" 0
}
@test "bump succeeds if new version set" {
  run /bin/bash -c "cd ${ide_docker_image_dir} && git init && git add --all && git commit -m first && RELEASER_LOG_LEVEL=debug ./tasks bump_old 0.0.13"
  echo "output: ${output}"
  assert_output --partial "New version will be: 0.0.13"
  assert_output --partial "Bumped to 0.0.13"
  assert_output --partial "Set next_version into Consul for docker-releaser-test: 0.0.13"
  assert_equal "$status" 0

  run /bin/bash -c "cat ${ide_docker_image_dir}/image/etc_ide.d/variables/60-variables.sh | grep \"0.0.13\""
  assert_equal "$status" 0
  run /bin/bash -c "cat ${ide_docker_image_dir}/CHANGELOG.md | grep -c \"### 0.0.13 (20\""
  assert_output "1"
  assert_equal "$status" 0

  # check that this is idempotent
  run /bin/bash -c "cd ${ide_docker_image_dir} && RELEASER_LOG_LEVEL=debug ./tasks bump_old 0.0.13"
  echo "output: ${output}"
  assert_output --partial "New version will be: 0.0.13"
  assert_output --partial "Bumped to 0.0.13"
  assert_output --partial "Set next_version into Consul for docker-releaser-test: 0.0.13"
  assert_output --partial "Version in changelog is already set"
  assert_equal "$status" 0
  run /bin/bash -c "cat ${ide_docker_image_dir}/image/etc_ide.d/variables/60-variables.sh | grep \"0.0.13\""
  assert_equal "$status" 0
  run /bin/bash -c "cat ${ide_docker_image_dir}/CHANGELOG.md | grep -c \"### 0.0.13 (20\""
  assert_output "1"
  assert_equal "$status" 0
}

@test "verify_version returns 1 if there is git tag for next_version from oversion" {
  run /bin/bash -c "cd ${ide_docker_image_dir} && git init && git add --all && git commit -m first && git tag 0.1.0 && ./tasks verify_version"
  echo "output: ${output}"
  assert_output --partial "The last version from oversion was already git tagged"
  assert_equal "$status" 1
}
@test "verify_version returns 1 if there is git tag for last changelog version" {
  run /bin/bash -c "cd ${ide_docker_image_dir} && git init && git add --all && git commit -m first && git tag 0.1.1 && ./tasks verify_version"
  echo "output: ${output}"
  assert_output --partial "The last version from changelog was already git tagged"
  assert_equal "$status" 1
}
@test "verify_version returns 0 if there is no git tag for last changelog version and next_version from oversion" {
  # we pretend that 0.1.0 was already released and next version is 0.1.1 (not released)
  run /bin/bash -c "cd ${ide_docker_image_dir} && source ${releaser} && set_next_oversion \"0.1.1\""
  run /bin/bash -c "cd ${ide_docker_image_dir} && git init && git add --all && git commit -m first && git tag 0.1.0 && ./tasks verify_version"
  echo "output: ${output}"
  assert_output --partial "Version verified successfully"
  assert_equal "$status" 0
}
