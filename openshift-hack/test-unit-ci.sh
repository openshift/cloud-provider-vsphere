#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Openshift specific test runner scripts. Based on OCP CCCMO one
# https://github.com/openshift/cluster-cloud-controller-manager-operator/blob/master/hack/unit-tests.sh

REPO_ROOT=$(realpath "$(dirname "${BASH_SOURCE[0]}")/..")
LOCAL_BINARIES_PATH=$REPO_ROOT/.build
KUBEBUILDER_ENVTEST_KUBERNETES_VERSION=${KUBEBUILDER_ENVTEST_KUBERNETES_VERSION:-1.28.0}
ENVTEST_ASSETS_DIR=/tmp/controller-tools/envtest

function setupEnvtest() {
    if [ ! -f "${ENVTEST_ASSETS_DIR}/kube-apiserver" ]; then
        ARCH=$(go env GOARCH)
        OS=$(go env GOOS)
        echo "Downloading envtest binaries for k8s ${KUBEBUILDER_ENVTEST_KUBERNETES_VERSION} (${OS}/${ARCH})..."
        curl -fSL "https://github.com/kubernetes-sigs/controller-tools/releases/download/envtest-v${KUBEBUILDER_ENVTEST_KUBERNETES_VERSION}/envtest-v${KUBEBUILDER_ENVTEST_KUBERNETES_VERSION}-${OS}-${ARCH}.tar.gz" -o /tmp/envtest.tar.gz
        tar -xzf /tmp/envtest.tar.gz -C /tmp/
    fi
    export KUBEBUILDER_ASSETS="${ENVTEST_ASSETS_DIR}"
    echo "KUBEBUILDER_ASSETS=${KUBEBUILDER_ASSETS}"

    # Ensure that some home var is set and that it's not the root
    export HOME=${HOME:=/tmp/kubebuilder/testing}
    if [ "$HOME" == "/" ]; then
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
