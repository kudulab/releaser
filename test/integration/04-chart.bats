load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

releaser=$(readlink -f ./src/releaser)
k8s_chart="test/integration/test-files/k8s-chart"
k8s_chart=$(readlink -f ${k8s_chart})

@test "bump succeeds if new version not set and we can get version from OVersion backend" {
  rm -rf "${k8s_chart}/.git"
  run /bin/bash -c "cd ${k8s_chart} && git init && git add --all && git commit -m first && ./tasks bump \"${k8s_chart}/service/Chart.yaml\""
  assert_output --partial "Got next_version from Consul for docker-releaser-test: 0.1.0"
  assert_output --partial "Bumped to 0.1.1 in ${k8s_chart}/service/Chart.yaml"
  assert_equal "$status" 0

  run /bin/bash -c "cat \"${k8s_chart}/service/Chart.yaml\" | grep \"0.1.1\""
  assert_equal "$status" 0

  # cleanup
  cd ${k8s_chart} && git reset --hard
  rm -rf "${k8s_chart}/.git"
  /bin/bash -c "cd ${k8s_chart} && source ${releaser} && set_next_oversion 0.1.0"
}
