load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

releaser=$(readlink -f ./image/releaser)
ide_docker_image_dir="test/integration/test-files/ide-docker-image"
ide_docker_image_dir=$(readlink -f ${ide_docker_image_dir})

@test "get_next_version" {
  run /bin/bash -c "cd ${ide_docker_image_dir} && ${releaser} get_next_version 2>/dev/null"
  assert_equal "$status" 0
  assert_output "0.1.0"
}
