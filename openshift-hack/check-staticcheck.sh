#!/bin/bash

# Copyright 2019 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

source ./openshift-hack/go-get-tool.sh

REPO_ROOT=$(realpath "$(dirname "${BASH_SOURCE[0]}")/..")
OPENSHIFT_CI=${OPENSHIFT_CI:-""}

# Change directories to the parent directory of the one in which this
# script is located.
cd "$REPO_ROOT"

CHECKS="all,-ST1*,-SA1019"
STATICCHECK_VERSION="2021.1.1"

function runStaticcheck() {
    local STATICCHECK_PATH=$LOCAL_BINARIES_PATH/staticcheck
    go-get-tool "$STATICCHECK_PATH" honnef.co/go/tools/cmd/staticcheck@$STATICCHECK_VERSION

    # Ensure that some home var is set and that it's not the root
    export HOME=${HOME:=/tmp/temphome}
    if [ $HOME == "/" ]; then
      export HOME=/tmp/temphome
    fi

    $STATICCHECK_PATH -checks "${CHECKS}" ./...
    echo "Done staticcheck"
}

runStaticcheck
