FROM registry.ci.openshift.org/ocp/builder:rhel-9-golang-1.23-openshift-4.19 AS builder
WORKDIR /go/src/github.com/openshift/cloud-provider-vsphere
COPY . .

RUN make binaries

FROM registry.ci.openshift.org/ocp/4.19:base-rhel9
COPY --from=builder /go/src/github.com/openshift/cloud-provider-vsphere/.build/vsphere-cloud-controller-manager /bin/vsphere-cloud-controller-manager

LABEL description="vSphere Cloud Controller Manager"

ENTRYPOINT ["/bin/vsphere-cloud-controller-manager"]
