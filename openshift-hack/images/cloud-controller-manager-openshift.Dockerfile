FROM registry.ci.openshift.org/ocp/builder:rhel-9-golang-1.26-openshift-5.0 AS builder
WORKDIR /go/src/github.com/openshift/cloud-provider-vsphere
COPY . .

RUN make binaries

FROM registry.ci.openshift.org/ocp/5.0:base-rhel9
COPY --from=builder /go/src/github.com/openshift/cloud-provider-vsphere/.build/vsphere-cloud-controller-manager /bin/vsphere-cloud-controller-manager

LABEL description="vSphere Cloud Controller Manager"

ENTRYPOINT ["/bin/vsphere-cloud-controller-manager"]
