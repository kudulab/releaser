load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

setup() {
  # TODO: this does not work! bats bug?
  # if [[ -z "AIT_DOCKER_IMAGE_NAME" ]]; then
  #   echo "fail! AIT_DOCKER_IMAGE_NAME not set"
  #   exit 1
  # fi
  # if [[ -z "AIT_DOCKER_IMAGE_TAG" ]]; then
  #   echo "fail! AIT_DOCKER_IMAGE_TAG not set"
  #   exit 1
  # fi
  echo
  echo "IDE_DOCKER_IMAGE=${AIT_DOCKER_IMAGE_NAME}:${AIT_DOCKER_IMAGE_TAG}" > Idefile.to_be_tested
  echo "IDE_IDENTITY=$(pwd)/test/acceptance/ide_identities/full" >> Idefile.to_be_tested
  # IDE_WORK is set to current directory, docker-releaser is ide-docker-image
  # type of project
}

# Just test that releaser executable is in the docker image and it is invocable
# and returns some output. Everything else was tested before building the
# docker image.
@test "releaser is invocable" {
  run /bin/bash -c "ide --idefile Idefile.to_be_tested -- releaser help"
  assert_output --partial "Available commands: bump, verify_version, build, release, publish"
  assert_equal "$status" 0
}
