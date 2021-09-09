#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Openshift specific test runner scripts. Based on OCP CCCMO one
# https://github.com/openshift/cluster-cloud-controller-manager-operator/blob/master/hack/unit-tests.sh

REPO_ROOT=$(realpath "$(dirname "${BASH_SOURCE[0]}")/..")
LOCAL_BINARIES_PATH=$REPO_ROOT/.build
ENVTEST_VERSION=v0.6.5 # based on version declared in go.mod
ENVTEST_ASSETS_DIR=/tmp/testbin
ENVTEST_SETUP_SCRIPT=https://raw.githubusercontent.com/kubernetes-sigs/controller-runtime/${ENVTEST_VERSION}/hack/setup-envtest.sh

# Use envtest install scripts instead of manual pulling and moving kubebuilder to PATH
function setupEnvtest() {
    echo "Envtest version: ${ENVTEST_VERSION}."
    mkdir -p ${ENVTEST_ASSETS_DIR}
    test -f ${ENVTEST_ASSETS_DIR}/setup-envtest.sh || curl -sSLo ${ENVTEST_ASSETS_DIR}/setup-envtest.sh ${ENVTEST_SETUP_SCRIPT}
    source ${ENVTEST_ASSETS_DIR}/setup-envtest.sh
    fetch_envtest_tools ${ENVTEST_ASSETS_DIR}
    setup_envtest_env ${ENVTEST_ASSETS_DIR}

    # Ensure that some home var is set and that it's not the root
    export HOME=${HOME:=/tmp/kubebuilder/testing}
    if [ $HOME == "/" ]; then
      export HOME=/tmp/kubebuilder/testing
    fi
}

OPENSHIFT_CI=${OPENSHIFT_CI:-""}
ARTIFACT_DIR=${ARTIFACT_DIR:-""}

function go_test() {
     go test ./pkg/...
}

runTestCI() {
    local GO_JUNIT_REPORT_PATH=$LOCAL_BINARIES_PATH/go-junit-report
    echo "CI env detected, run tests with jUnit report extraction"
    if [ -n "$ARTIFACT_DIR" ] && [ -d "$ARTIFACT_DIR" ]; then
        local JUNIT_LOCATION="$ARTIFACT_DIR"/junit_cluster_cloud_controller_manager_operator.xml
        echo "jUnit location: $JUNIT_LOCATION"
        GOBIN=$LOCAL_BINARIES_PATH go install -mod=readonly github.com/jstemmer/go-junit-report@latest
        go_test -v | tee >($GO_JUNIT_REPORT_PATH > "$JUNIT_LOCATION")
    else
        echo "\$ARTIFACT_DIR not set or does not exists, no jUnit will be published"
        go_test
    fi
}

function runTests() {
    if [ "$OPENSHIFT_CI" == "true" ]; then
        runTestCI
    else
        go_test
    fi
}

pushd $REPO_ROOT
  setupEnvtest && \
  runTests
popd
