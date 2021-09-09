#!/usr/bin/env bash

set -eu


REPO=github.com/openshift/cloud-provider-vsphere
REPO_ROOT="$(git rev-parse --show-toplevel)"
WHAT=${1:-cloud-controller-manager}
GLDFLAGS=${GLDFLAGS:-}

eval $(go env | grep -e "GOHOSTOS" -e "GOHOSTARCH")

: "${GOOS:=${GOHOSTOS}}"
: "${GOARCH:=${GOHOSTARCH}}"

cd "$REPO_ROOT"
if [ -z ${VERSION_OVERRIDE+a} ]; then
	echo "Using version from git..."
	VERSION_OVERRIDE=$(git describe --abbrev=8 --dirty --always)
fi

GLDFLAGS="-extldflags '-static' -w -s"
GLDFLAGS="$GLDFLAGS -X main.version=${VERSION_OVERRIDE}"
GLDFLAGS="$GLDFLAGS -X k8s.io/kubernetes/pkg/version.gitVersion=${VERSION_OVERRIDE}"
GLDFLAGS="$GLDFLAGS -X k8s.io/component-base/pkg/version.gitVersion=${VERSION_OVERRIDE}"

eval $(go env)

echo "Building ${REPO}/cmd/${WHAT} (${VERSION_OVERRIDE})"
GO111MODULE=${GO111MODULE} CGO_ENABLED=0 GOOS=${GOOS} GOARCH=${GOARCH} go build ${GOFLAGS} -ldflags "${GLDFLAGS}" -o .build/${WHAT} ${REPO_ROOT}/cmd/${WHAT}
