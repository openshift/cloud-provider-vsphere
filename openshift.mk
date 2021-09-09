## --------------------------------------
## Openshift specific make targets,
## intended to be included in root Makefile in this repository along with openshift-hack folder.
## --------------------------------------

vsphere-cloud-controller-manager:
	openshift-hack/build-go.sh vsphere-cloud-controller-manager
.PHONY: vsphere-cloud-controller-manager

binaries: vsphere-cloud-controller-manager
.PHONY: binaries

verify-history:
	openshift-hack/verify-history.sh
.PHONY: verify-history

fmt:
	openshift-hack/check-fmt.sh
.PHONY: fmt

lint:
	openshift-hack/check-lint.sh
.PHONY: lint

verify: fmt vet lint
.PHONY: verify

test-unit-ci unit:
	openshift-hack/test-unit-ci.sh
.PHONY: test-unit-ci unit
