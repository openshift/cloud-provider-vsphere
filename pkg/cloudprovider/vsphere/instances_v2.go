package vsphere

// This file implements the InstancesV2 interface.
// InstancesV2 is an abstract, pluggable interface for cloud provider instances.
// Unlike the Instances interface, it is designed for external cloud providers and should only be used by them.

import (
	"context"
	v1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/types"
	cloudprovider "k8s.io/cloud-provider"
	"strings"
)

var AdditionalLabels string

func newInstancesV2(instances cloudprovider.Instances, zones cloudprovider.Zones) cloudprovider.InstancesV2 {
	return &instancesV2{
		instances: instances,
		zones:     zones,
	}
}

func (c *instancesV2) getProviderID(ctx context.Context, node *v1.Node) (string, error) {
	if node.Spec.ProviderID != "" {
		return node.Spec.ProviderID, nil
	}

	instanceID, err := c.instances.InstanceID(ctx, types.NodeName(node.Name))
	if err != nil {
		return "", err
	}

	return ProviderName + "://" + instanceID, nil
}

// InstanceExists returns true if the instance for the given node exists according to the cloud provider.
// Use the node.name or node.spec.providerID field to find the node in the cloud provider.
func (c *instancesV2) InstanceExists(ctx context.Context, node *v1.Node) (bool, error) {
	providerID, err := c.getProviderID(ctx, node)
	if err != nil {
		return false, err
	}

	return c.instances.InstanceExistsByProviderID(ctx, providerID)
}

// InstanceShutdown returns true if the instance is shutdown according to the cloud provider.
// Use the node.name or node.spec.providerID field to find the node in the cloud provider.
func (c *instancesV2) InstanceShutdown(ctx context.Context, node *v1.Node) (bool, error) {
	providerID, err := c.getProviderID(ctx, node)
	if err != nil {
		return false, err
	}

	return c.instances.InstanceShutdownByProviderID(ctx, providerID)
}

func (c *instancesV2) getAdditionalLabels() (map[string]string, error) {
	additionalLabels := map[string]string{}
	if AdditionalLabels == "" {
		return additionalLabels, nil
	}

	// We may want to have a way to pass in additional labels to add to a node based on CCM configuration.
	for _, label := range strings.Split(AdditionalLabels, ",") {
		labelKey := label
		labelValue := ""
		if strings.Contains(label, "=") {
			parts := strings.Split(label, "=")
			labelKey = parts[0]
			labelValue = parts[1]
		}
		additionalLabels[labelKey] = labelValue
	}

	return additionalLabels, nil
}

// InstanceMetadata returns the instance's metadata. The values returned in InstanceMetadata are
// translated into specific fields and labels in the Node object on registration.
// Implementations should always check node.spec.providerID first when trying to discover the instance
// for a given node. In cases where node.spec.providerID is empty, implementations can use other
// properties of the node like its name, labels and annotations.
func (c *instancesV2) InstanceMetadata(ctx context.Context, node *v1.Node) (*cloudprovider.InstanceMetadata, error) {
	providerID, err := c.getProviderID(ctx, node)
	if err != nil {
		return nil, err
	}

	instanceType, err := c.instances.InstanceTypeByProviderID(ctx, providerID)
	if err != nil {
		return nil, err
	}

	zone, err := c.zones.GetZoneByProviderID(ctx, providerID)
	if err != nil {
		return nil, err
	}

	nodeAddresses, err := c.instances.NodeAddressesByProviderID(ctx, providerID)
	if err != nil {
		return nil, err
	}

	// Generate additionalLabels
	additionalLabels, err := c.getAdditionalLabels()
	if err != nil {
		return nil, err
	}

	return &cloudprovider.InstanceMetadata{
		ProviderID:       providerID,
		InstanceType:     instanceType,
		NodeAddresses:    nodeAddresses,
		Zone:             zone.FailureDomain,
		Region:           zone.Region,
		AdditionalLabels: additionalLabels,
	}, nil
}
