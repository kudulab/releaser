load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

releaser=$(readlink -f ./src/releaser)
ide_docker_image_dir="test/integration/test-files/ide-docker-image"
ide_docker_image_dir=$(readlink -f ${ide_docker_image_dir})

# Those are integration tests, because they need oversion file of some dummy
# project.

@test "get_next_version" {
  # ignore log messages
  run /bin/bash -c "cd ${ide_docker_image_dir} && source ${releaser} && get_next_version 2>/dev/null"
  assert_output "0.1.0"
  assert_equal "$status" 0
}

@test "get_next_version can be saved to bash variable" {
  # the whole stdout is just the version number, the rest is stderr
  version=$(cd ${ide_docker_image_dir} && source ${releaser} && get_next_version)
  run echo "${version}"
  assert_output "0.1.0"
  assert_equal "$status" 0
}

@test "set_next_version" {
  run /bin/bash -c "cd ${ide_docker_image_dir} && source ${releaser} && set_next_version \"41.111.3\""
  assert_output --partial "Set next_version into Consul: 41.111.3"
  assert_equal "$status" 0
  /bin/bash -c "cd ${ide_docker_image_dir} && source ${releaser} && set_next_version \"0.1.0\""
}
