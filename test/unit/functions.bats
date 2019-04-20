load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

releaser=$(readlink -f ./src/releaser)

@test "releaser::loaded" {
  run /bin/bash -c "source ${releaser} && releaser::loaded"
  assert_equal "$status" 0
}
@test "releaser::get_last_version_from_changelog" {
  run /bin/bash -c "source ${releaser} && releaser::get_last_version_from_changelog \"test/unit/test-files/CHANGELOG-filled.md\""
  assert_output "20.13.41"
  assert_equal "$status" 0
}
@test "releaser::get_last_version_from_changelog when 1st line has no version" {
  run /bin/bash -c "source ${releaser} && releaser::get_last_version_from_changelog \"test/unit/test-files/CHANGELOG.md\""
  refute_output --partial "0.1.0"
  assert_equal "$status" 1
}
@test "releaser::get_last_version_from_changelog when no version whatsoever" {
  run /bin/bash -c "source ${releaser} && releaser::get_last_version_from_changelog \"test/unit/test-files/CHANGELOG-no-version.md\""
  assert_equal "$status" 1
}
@test "releaser::get_last_version_from_whole_changelog when 1st line has no version" {
  run /bin/bash -c "source ${releaser} && releaser::get_last_version_from_whole_changelog \"test/unit/test-files/CHANGELOG.md\""
  assert_output "0.1.0"
  assert_equal "$status" 0
}
@test "releaser::get_last_version_from_whole_changelog when no version in file" {
  run /bin/bash -c "source ${releaser} && releaser::get_last_version_from_whole_changelog \"test/unit/test-files/CHANGELOG-no-version.md\""
  assert_equal "$status" 1
}
@test "releaser::get_last_git_tagged_version" {
  cd test/unit/test-files
  git init one-git-tag-repo
  cd one-git-tag-repo
  touch README.md && git add README.md && git commit -m "init commit" && git tag "99.123.24"
  run /bin/bash -c "source ${releaser} && releaser::get_last_git_tagged_version"
  assert_equal "$status" 0
  assert_output "99.123.24"
  cd ..
  rm -rf one-git-tag-repo
}
@test "releaser::get_last_git_tagged_version fails when no git repo" {
  run /bin/bash -c "source ${releaser} && cd /tmp && releaser::get_last_git_tagged_version"
  assert_output --partial "Not a git repository"
  assert_equal "$status" 1
}
@test "releaser::bump_patch_version from 0.0.1 to 0.0.2" {
  run /bin/bash -c "source ${releaser} && releaser::bump_patch_version \"0.0.1\""
  assert_output "0.0.2"
  assert_equal "$status" 0
}
@test "releaser::bump_patch_version from 129.11.12412 to 129.11.12413" {
  run /bin/bash -c "source ${releaser} && releaser::bump_patch_version \"129.11.12412\""
  assert_output "129.11.12413"
  assert_equal "$status" 0
}
@test "releaser::bump_patch_version fails when no major part" {
  run /bin/bash -c "source ${releaser} && releaser::bump_patch_version \".129.11\""
  assert_output --partial "Version was not SemVer"
  assert_equal "$status" 1
}
@test "releaser::bump_patch_version fails when no minor part" {
  run /bin/bash -c "source ${releaser} && releaser::bump_patch_version \"129..11\""
  assert_output --partial "Version was not SemVer"
  assert_equal "$status" 1
}
@test "releaser::bump_patch_version fails when no patch part" {
  run /bin/bash -c "source ${releaser} && releaser::bump_patch_version \"129.11\""
  assert_output --partial "Version was not SemVer"
  assert_equal "$status" 1
}
@test "releaser::set_version_in_file when some string instead of version" {
  run /bin/bash -c "source ${releaser} && RELEASER_LOG_LEVEL=debug dryrun=true releaser::set_version_in_file \"export this_image_tag=\" \"test/unit/test-files/docker-image-version-file\"  \"129.11.12412\""
  assert_output --partial "export this_image_tag=\"129.11.12412\""
  assert_equal "$status" 0
}
@test "releaser::set_version_in_file when old version was set" {
  run /bin/bash -c "source ${releaser} && RELEASER_LOG_LEVEL=debug dryrun=true releaser::set_version_in_file \"export this_image_tag=\" \"test/unit/test-files/docker-image-version-file1\"  \"129.11.12412\""
  assert_output --partial "export this_image_tag=\"129.11.12412\""
  assert_equal "$status" 0
}
@test "releaser::set_version_in_changelog" {
  run /bin/bash -c "source ${releaser} && RELEASER_LOG_LEVEL=debug dryrun=true releaser::set_version_in_changelog  \"test/unit/test-files/CHANGELOG.md\" \"129.11.12412\""
  assert_output --partial "### 129.11.12412 (20"
  assert_equal "$status" 0
}
@test "releaser::set_version_in_changelog to unreleased" {
  run /bin/bash -c "source ${releaser} && RELEASER_LOG_LEVEL=debug dryrun=true releaser::set_version_in_changelog  \"test/unit/test-files/CHANGELOG.md\" \"1.2.5\" unreleased"
  assert_output --partial "### 1.2.5 - Unreleased"
  assert_equal "$status" 0
}
@test "releaser::set_version_in_changelog to unreleased when same version already set" {
  run /bin/bash -c "source ${releaser} && RELEASER_LOG_LEVEL=debug dryrun=true releaser::set_version_in_changelog  \"test/unit/test-files/CHANGELOG-unreleased.md\" \"1.2.5\" unreleased"
  assert_output --partial "Version and unreleased flag in changelog is already set"
  assert_equal "$status" 0
}
@test "releaser::set_version_in_changelog to unreleased when other unreleased version set" {
  run /bin/bash -c "source ${releaser} && RELEASER_LOG_LEVEL=debug dryrun=true releaser::set_version_in_changelog  \"test/unit/test-files/CHANGELOG-unreleased.md\" \"1.2.6\" unreleased"
  assert_output --partial "Changing current unreleased head of changelog"
  assert_equal "$status" 0
}
@test "releaser::get_chart_version, version quoted" {
  run /bin/bash -c "source ${releaser} && RELEASER_LOG_LEVEL=debug releaser::get_chart_version \"test/unit/test-files/Chart.yaml\""
  assert_output "12.45.10"
  assert_equal "$status" 0
}
@test "releaser::get_chart_version, version not quoted" {
  run /bin/bash -c "source ${releaser} && RELEASER_LOG_LEVEL=debug releaser::get_chart_version \"test/unit/test-files/Chart1.yaml\""
  assert_output "12.45.11"
  assert_equal "$status" 0
}
@test "releaser::bump_chart_version when some string instead of version" {
  run /bin/bash -c "source ${releaser} && RELEASER_LOG_LEVEL=debug dryrun=true releaser::bump_chart_version \"test/unit/test-files/Chart.yaml\"  \"129.11.12412\""
  assert_output --partial "version: \"129.11.12412\""
  assert_equal "$status" 0
}
