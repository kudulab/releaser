load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

releaser_functions=$(readlink -f ./image/releaser_functions)

@test "get_last_version_from_changelog" {
  run /bin/bash -c "source ${releaser_functions} && get_last_version_from_changelog \"test/unit/test-files/CHANGELOG-filled.md\""
  assert_output "20.13.41"
  assert_equal "$status" 0
}
@test "get_last_version_from_changelog if 1st line has no version" {
  run /bin/bash -c "source ${releaser_functions} && get_last_version_from_changelog \"test/unit/test-files/CHANGELOG.md\""
  assert_equal "$status" 1
}

@test "get_last_git_tagged_version" {
  cd test/unit/test-files
  git init one-git-tag-repo
  cd one-git-tag-repo
  touch README.md && git add README.md && git commit -m "init commit" && git tag "99.123.24"
  run /bin/bash -c "source ${releaser_functions} && get_last_git_tagged_version"
  assert_equal "$status" 0
  assert_output "99.123.24"
  cd ..
  rm -rf one-git-tag-repo
}
@test "get_last_git_tagged_version fails if no git repo" {
  cd /tmp
  run /bin/bash -c "source ${releaser_functions} && get_last_git_tagged_version"
  assert_output --partial "Not a git repository"
  assert_equal "$status" 1
}

@test "bump_patch_version from 0.0.1 to 0.0.2" {
  run /bin/bash -c "source ${releaser_functions} && bump_patch_version \"0.0.1\""
  assert_output "0.0.2"
  assert_equal "$status" 0
}
@test "bump_patch_version from 129.11.12412 to 129.11.12413" {
  run /bin/bash -c "source ${releaser_functions} && bump_patch_version \"129.11.12412\""
  assert_output "129.11.12413"
  assert_equal "$status" 0
}
@test "bump_patch_version fails if no major part" {
  run /bin/bash -c "source ${releaser_functions} && bump_patch_version \".129.11\""
  assert_output --partial "old_version was not SemVer"
  assert_equal "$status" 1
}
@test "bump_patch_version fails if no minor part" {
  run /bin/bash -c "source ${releaser_functions} && bump_patch_version \"129..11\""
  assert_output --partial "old_version was not SemVer"
  assert_equal "$status" 1
}
@test "bump_patch_version fails if no patch part" {
  run /bin/bash -c "source ${releaser_functions} && bump_patch_version \"129.11\""
  assert_output --partial "old_version was not SemVer"
  assert_equal "$status" 1
}

@test "locally_bump_version_in_versionfile_dockerimage when some string instead of version" {
  run /bin/bash -c "source ${releaser_functions} && dryrun=true locally_bump_version_in_versionfile_dockerimage \"129.11.12412\" \"test/unit/test-files/docker-image-version-file\""
  assert_output --partial "export this_image_tag=\"129.11.12412\""
  assert_equal "$status" 0
}
@test "locally_bump_version_in_versionfile_dockerimage when old version was set" {
  run /bin/bash -c "source ${releaser_functions} && dryrun=true locally_bump_version_in_versionfile_dockerimage \"129.11.12412\" \"test/unit/test-files/docker-image-version-file1\""
  assert_output --partial "export this_image_tag=\"129.11.12412\""
  assert_equal "$status" 0
}

@test "locally_bump_version_in_changelog" {
  run /bin/bash -c "source ${releaser_functions} && dryrun=true locally_bump_version_in_changelog \"129.11.12412\" \"test/unit/test-files/CHANGELOG.md\""
  assert_output --partial "### 129.11.12412 (20"
  assert_equal "$status" 0
}
