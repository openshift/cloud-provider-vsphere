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

REPO_ROOT=$(realpath "$(dirname "${BASH_SOURCE[0]}")/..")
OPENSHIFT_CI=${OPENSHIFT_CI:-""}

# Change directories to the parent directory of the one in which this
# script is located.
cd "$REPO_ROOT"

function runGoimports() {
    # use the goimports that is bundled in the openshift build images
    find "./cmd" -name '*.go' ! -path '*/vendor/*' ! -path '*/.build/*' -exec goimports -w {} \+
    find "./pkg" -name '*.go' ! -path '*/vendor/*' ! -path '*/.build/*' -exec goimports -w {} \+
    echo "fmt and goimports done"
}

function gitDiff() {
    git diff --exit-code
}

function runFmt() {
    runGoimports

    if [ "$OPENSHIFT_CI" == "true" ]; then
        gitDiff
    fi
}

runFmt
