load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

releaser=$(readlink -f ./src/releaser)

@test "releaser_loaded" {
  run /bin/bash -c "source ${releaser} && releaser_loaded"
  assert_equal "$status" 0
}

@test "get_last_version_from_changelog" {
  run /bin/bash -c "source ${releaser} && get_last_version_from_changelog \"test/unit/test-files/CHANGELOG-filled.md\""
  assert_output "20.13.41"
  assert_equal "$status" 0
}
@test "get_last_version_from_changelog if 1st line has no version" {
  run /bin/bash -c "source ${releaser} && get_last_version_from_changelog \"test/unit/test-files/CHANGELOG.md\""
  assert_equal "$status" 1
}

@test "get_last_git_tagged_version" {
  cd test/unit/test-files
  git init one-git-tag-repo
  cd one-git-tag-repo
  touch README.md && git add README.md && git commit -m "init commit" && git tag "99.123.24"
  run /bin/bash -c "source ${releaser} && get_last_git_tagged_version"
  assert_equal "$status" 0
  assert_output "99.123.24"
  cd ..
  rm -rf one-git-tag-repo
}
@test "get_last_git_tagged_version fails if no git repo" {
  cd /tmp
  run /bin/bash -c "source ${releaser} && get_last_git_tagged_version"
  assert_output --partial "Not a git repository"
  assert_equal "$status" 1
}

@test "bump_patch_version from 0.0.1 to 0.0.2" {
  run /bin/bash -c "source ${releaser} && bump_patch_version \"0.0.1\""
  assert_output "0.0.2"
  assert_equal "$status" 0
}
@test "bump_patch_version from 129.11.12412 to 129.11.12413" {
  run /bin/bash -c "source ${releaser} && bump_patch_version \"129.11.12412\""
  assert_output "129.11.12413"
  assert_equal "$status" 0
}
@test "bump_patch_version fails if no major part" {
  run /bin/bash -c "source ${releaser} && bump_patch_version \".129.11\""
  assert_output --partial "Version was not SemVer"
  assert_equal "$status" 1
}
@test "bump_patch_version fails if no minor part" {
  run /bin/bash -c "source ${releaser} && bump_patch_version \"129..11\""
  assert_output --partial "Version was not SemVer"
  assert_equal "$status" 1
}
@test "bump_patch_version fails if no patch part" {
  run /bin/bash -c "source ${releaser} && bump_patch_version \"129.11\""
  assert_output --partial "Version was not SemVer"
  assert_equal "$status" 1
}

@test "locally_bump_version_in_versionfile when some string instead of version" {
  run /bin/bash -c "source ${releaser} && RELEASER_LOG_LEVEL=debug dryrun=true locally_bump_version_in_versionfile \"export this_image_tag=\" \"test/unit/test-files/docker-image-version-file\"  \"129.11.12412\""
  assert_output --partial "export this_image_tag=\"129.11.12412\""
  assert_equal "$status" 0
}
@test "locally_bump_version_in_versionfile when old version was set" {
  run /bin/bash -c "source ${releaser} && RELEASER_LOG_LEVEL=debug dryrun=true locally_bump_version_in_versionfile \"export this_image_tag=\" \"test/unit/test-files/docker-image-version-file1\"  \"129.11.12412\""
  assert_output --partial "export this_image_tag=\"129.11.12412\""
  assert_equal "$status" 0
}

@test "locally_bump_version_in_changelog" {
  run /bin/bash -c "source ${releaser} && RELEASER_LOG_LEVEL=debug dryrun=true locally_bump_version_in_changelog  \"test/unit/test-files/CHANGELOG.md\" \"129.11.12412\""
  assert_output --partial "### 129.11.12412 (20"
  assert_equal "$status" 0
}

@test "publish_to_archive fails if endpoint_directory_name not set" {
  run /bin/bash -c "source ${releaser} && RELEASER_LOG_LEVEL=debug dryrun=true publish_to_archive"
  assert_output --partial "endpoint_directory_name not set"
  assert_equal "$status" 1
}

@test "publish_to_archive fails if version not set" {
  run /bin/bash -c "source ${releaser} && RELEASER_LOG_LEVEL=debug dryrun=true publish_to_archive \"my_endpoint_name\""
  assert_output --partial "version not set"
  assert_equal "$status" 1
}

@test "publish_to_archive fails if file_to_publish not set" {
  run /bin/bash -c "source ${releaser} && RELEASER_LOG_LEVEL=debug dryrun=true publish_to_archive \"my_endpoint_name\" \"0.1.123\""
  assert_output --partial "file_to_publish not set"
  assert_equal "$status" 1
}

@test "publish_to_archive succeeds if all set" {
  run /bin/bash -c "source ${releaser} && RELEASER_LOG_LEVEL=debug dryrun=true publish_to_archive \"my_endpoint_name\" \"0.1.123\" \"CHANGELOG.md\""
  assert_output --partial "Published into rsync://rsync.archive.ai-traders.com/archive/my_endpoint_name/0.1.123"
  assert_equal "$status" 0
}

@test "get_chart_version, version quoted" {
  run /bin/bash -c "source ${releaser} && RELEASER_LOG_LEVEL=debug get_chart_version \"test/unit/test-files/Chart.yaml\""
  assert_output "12.45.10"
  assert_equal "$status" 0
}
@test "get_chart_version, version not quoted" {
  run /bin/bash -c "source ${releaser} && RELEASER_LOG_LEVEL=debug get_chart_version \"test/unit/test-files/Chart1.yaml\""
  assert_output "12.45.11"
  assert_equal "$status" 0
}

@test "bump_chart_version when some string instead of version" {
  run /bin/bash -c "source ${releaser} && RELEASER_LOG_LEVEL=debug dryrun=true bump_chart_version \"test/unit/test-files/Chart.yaml\"  \"129.11.12412\""
  assert_output --partial "version: \"129.11.12412\""
  assert_equal "$status" 0
}
