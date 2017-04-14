load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

releaser=$(readlink -f ./image/releaser)
ide_docker_image_dir="test/test-files/ide-docker-image"
ide_docker_image_dir=$(readlink -f ${ide_docker_image_dir})

@test "get_next_version" {
  # ignore log messages
  run /bin/bash -c "cd ${ide_docker_image_dir} && ${releaser} get_next_version 2>/dev/null"
  assert_output "0.1.0"
  assert_equal "$status" 0
}

@test "set_next_version" {
  run /bin/bash -c "cd ${ide_docker_image_dir} && ${releaser} set_next_version \"41.111.3\""
  assert_output --partial "Set next_version into Consul: 41.111.3"
  assert_equal "$status" 0
  /bin/bash -c "cd ${ide_docker_image_dir} && ${releaser} set_next_version \"0.1.0\""
}
