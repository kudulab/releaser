load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

releaser=$(readlink -f ./src/releaser)
ide_docker_image_dir="test/integration/test-files/ide-docker-image"
ide_docker_image_dir=$(readlink -f ${ide_docker_image_dir})

# Those are integration tests, because they need oversion file of some dummy
# project.

@test "get_next_oversion" {
  # ignore log messages
  run /bin/bash -c "cd ${ide_docker_image_dir} && source ${releaser} && get_next_oversion 2>/dev/null"
  assert_output "0.1.0"
  assert_equal "$status" 0
}

@test "get_next_oversion can be saved to bash variable" {
  # the whole stdout is just the version number, the rest is stderr
  version=$(cd ${ide_docker_image_dir} && source ${releaser} && get_next_oversion)
  run echo "${version}"
  assert_output "0.1.0"
  assert_equal "$status" 0
}

@test "set_next_oversion" {
  run /bin/bash -c "cd ${ide_docker_image_dir} && source ${releaser} && set_next_oversion \"41.111.3\""
  assert_output --partial "Set next_version into Consul for docker-releaser-test: 41.111.3"
  assert_equal "$status" 0
  /bin/bash -c "cd ${ide_docker_image_dir} && source ${releaser} && set_next_oversion \"0.1.0\""
}

@test "publish_to_archive succeeds if all set" {
  run /bin/bash -c "source ${releaser} && RELEASER_LOG_LEVEL=debug publish_to_archive \"releaser-test\" \"0.1.123\" \"test/integration/test-files/file-to-publish\""
  assert_output --partial "Published into rsync://rsync.archive.ai-traders.com/archive/releaser-test/0.1.123"
  assert_equal "$status" 0

  run wget -O downloaded-file http://http.archive.ai-traders.com/releaser-test/0.1.123/file-to-publish
  assert_equal "$status" 0

  run cat downloaded-file
  assert_output "123"
  assert_equal "$status" 0

  # remove the contents of http://http.archive.ai-traders.com/releaser-test/
  mkdir -p /tmp/aa
  rsync --recursive --delete /tmp/aa/ rsync://rsync.archive.ai-traders.com/archive/releaser-test/
  rm -r /tmp/aa
  rm downloaded-file
}
