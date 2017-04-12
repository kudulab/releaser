load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

releaser=$(readlink -f ./image/releaser)
ide_docker_image_dir="test/integration/test-files/ide-docker-image"
ide_docker_image_dir=$(readlink -f ${ide_docker_image_dir})

@test "help" {
  run /bin/bash -c "cd ${ide_docker_image_dir} && ${releaser} help"
  assert_output --partial "Available commands: bump, verify_version, build, release, publish"
  assert_equal "$status" 0
}
@test "not-existent-command" {
  run /bin/bash -c "cd ${ide_docker_image_dir} && ${releaser} not-existent-command"
  assert_output --partial "Invalid command: 'not-existent-command'"
  assert_equal "$status" 1
}
@test "bump fails if new version not set and cannot get version from OVersion backend" {
  rm -rf "${ide_docker_image_dir}123"
  mkdir -p "${ide_docker_image_dir}123"
  run /bin/bash -c "cd ${ide_docker_image_dir}123 && ${releaser} bump"
  assert_output --partial "releaser-variables: No such file or directory"
  assert_equal "$status" 1

  # cleanup
  rm -rf "${ide_docker_image_dir}123"
}
@test "bump succeeds if new version not set and we can get version from OVersion backend" {
  rm -rf "${ide_docker_image_dir}/.git"
  run /bin/bash -c "cd ${ide_docker_image_dir} && git init && git add --all && git commit -m first && ${releaser} bump"
  assert_output --partial "Got next_version from Consul: 0.1.0"
  assert_output --partial "New version will be: 0.1.1"
  assert_output --partial "Bumped to 0.1.1"
  assert_output --partial "Set next_version into Consul: 0.1.1"
  assert_equal "$status" 0

  run /bin/bash -c "cat ${ide_docker_image_dir}/image/etc_ide.d/variables/60-variables.sh | grep \"0.1.1\""
  assert_equal "$status" 0
  run /bin/bash -c "cat ${ide_docker_image_dir}/CHANGELOG.md | head -1 | grep \"### 0.1.1 (20\""
  assert_equal "$status" 0

  # cleanup
  cd ${ide_docker_image_dir} && git reset --hard
  rm -rf "${ide_docker_image_dir}/.git"
  run /bin/bash -c "cd ${ide_docker_image_dir} && ${releaser} set_next_version 0.1.0"
}
@test "bump succeeds if new version set" {
  rm -rf "${ide_docker_image_dir}/.git"
  run /bin/bash -c "cd ${ide_docker_image_dir} && git init && git add --all && git commit -m first && ${releaser} bump 0.0.13"
  assert_output --partial "New version will be: 0.0.13"
  assert_output --partial "Bumped to 0.0.13"
  assert_output --partial "Set next_version into Consul: 0.0.13"
  assert_equal "$status" 0

  run /bin/bash -c "cat ${ide_docker_image_dir}/image/etc_ide.d/variables/60-variables.sh | grep \"0.0.13\""
  assert_equal "$status" 0
  run /bin/bash -c "cat ${ide_docker_image_dir}/CHANGELOG.md | grep \"### 0.0.13 (20\""
  assert_equal "$status" 0

  # cleanup
  cd ${ide_docker_image_dir} && git reset --hard
  rm -rf "${ide_docker_image_dir}/.git"
  run /bin/bash -c "cd ${ide_docker_image_dir} && ${releaser} set_next_version 0.1.0"
}

@test "verify_version returns 1 if there is git tag for next_version from oversion" {
  rm -rf "${ide_docker_image_dir}/.git"
  run /bin/bash -c "cd ${ide_docker_image_dir} && git init && git add --all && git commit -m first && git tag 0.1.0 && ${releaser} verify_version"
  assert_output --partial "The last version from oversion was already git tagged"
  assert_equal "$status" 1

  # cleanup
  rm -rf "${ide_docker_image_dir}/.git"
}
@test "verify_version returns 1 if there is git tag for last changelog version" {
  rm -rf "${ide_docker_image_dir}/.git"
  run /bin/bash -c "cd ${ide_docker_image_dir} && git init && git add --all && git commit -m first && git tag 0.1.1 && ${releaser} verify_version"
  assert_output --partial "The last version from changelog was already git tagged"
  assert_equal "$status" 1

  # cleanup
  rm -rf "${ide_docker_image_dir}/.git"
}
@test "verify_version returns 0 if there is no git tag for last changelog version and next_version from oversion" {
  rm -rf "${ide_docker_image_dir}/.git"
  run /bin/bash -c "cd ${ide_docker_image_dir} && git init && git add --all && git commit -m first && git tag 0.1.2 && ${releaser} verify_version"
  assert_output --partial "Version verified successfully"
  assert_equal "$status" 0

  # cleanup
  rm -rf "${ide_docker_image_dir}/.git"
}

# function clean_docker_images {
#   tags=$(docker images  docker-registry.ai-traders.com/releaser-test | awk '{print $2}' | tail -n +2)
#   for tag in $tags ; do
#     docker rmi "docker-registry.ai-traders.com/releaser-test:${tag}"
#   done
# }

# @test "build returns 0" {
#   clean_docker_images
#
#   rm -rf "${ide_docker_image_dir}/.git"
#   run /bin/bash -c "cd ${ide_docker_image_dir} && git init && git add --all && git commit -m first && dryrun=true ${releaser} build"
#   assert_output --partial "docker build -t docker-registry.ai-traders.com/releaser-test"
#   assert_equal "$status" 0
#
#   run /bin/bash -c "cat ${ide_docker_image_dir}/image/imagerc | grep 'export AIT_DOCKER_IMAGE_NAME=\"docker-registry.ai-traders.com/releaser-test\"'"
#   assert_equal "$status" 0
#   run /bin/bash -c "cat ${ide_docker_image_dir}/image/imagerc.json | grep '\"docker_image_name\":\"docker-registry.ai-traders.com/releaser-test\"'"
#   assert_equal "$status" 0
#   run /bin/bash -c "cat ${ide_docker_image_dir}/image/imagerc.yml | grep -- '---'"
#   assert_equal "$status" 0
#   run /bin/bash -c "cat ${ide_docker_image_dir}/image/imagerc.yml | grep 'docker_image_name: docker-registry.ai-traders.com/releaser-test'"
#   assert_equal "$status" 0
#
#   cd ${ide_docker_image_dir} && git reset --hard
#   # do not rm .git directory, it is needed in publish test
#   rm "${ide_docker_image_dir}/image/imagerc"*
# }
# @test "publish returns 0" {
#   # do not rm .git directory, reuse it from build test
#   run /bin/bash -c "cd ${ide_docker_image_dir} && git tag 0.1.1 && dryrun=true ${releaser} publish"
#   assert_output --partial "docker tag docker-registry.ai-traders.com/releaser-test"
#   assert_output --partial "docker-registry.ai-traders.com/releaser-test:latest"
#   assert_equal "$status" 0
#
#   cd ${ide_docker_image_dir} && git reset --hard
#   rm -rf "${ide_docker_image_dir}/.git"
#
#   clean_docker_images
# }
