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
  echo "IDE_DOCKER_IMAGE=${AIT_DOCKER_IMAGE_NAME}:${AIT_DOCKER_IMAGE_TAG}" > Idefile.releaser
}

# Just test that releaser executable is in the docker image and it is invocable
# and returns some output. Everything else was tested before building the
# docker image.
@test "releaser is invocable" {
  run /bin/bash -c "ide --idefile Idefile.releaser -- releaser help"
  assert_output --partial "Available commands: bump, verify_version, build, release, publish"
  assert_equal "$status" 0
}
