/*
Copyright 2021 The Kubernetes Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// Code generated by client-gen. DO NOT EDIT.

package fake

import (
	"context"

	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	labels "k8s.io/apimachinery/pkg/labels"
	schema "k8s.io/apimachinery/pkg/runtime/schema"
	types "k8s.io/apimachinery/pkg/types"
	watch "k8s.io/apimachinery/pkg/watch"
	testing "k8s.io/client-go/testing"
	v1alpha1 "k8s.io/cloud-provider-vsphere/pkg/cloudprovider/vsphereparavirtual/apis/nsxnetworking/v1alpha1"
)

// FakeRouteSets implements RouteSetInterface
type FakeRouteSets struct {
	Fake *FakeNsxV1alpha1
	ns   string
}

var routesetsResource = schema.GroupVersionResource{Group: "nsx.vmware.com", Version: "v1alpha1", Resource: "routesets"}

var routesetsKind = schema.GroupVersionKind{Group: "nsx.vmware.com", Version: "v1alpha1", Kind: "RouteSet"}

// Get takes name of the routeSet, and returns the corresponding routeSet object, and an error if there is any.
func (c *FakeRouteSets) Get(ctx context.Context, name string, options v1.GetOptions) (result *v1alpha1.RouteSet, err error) {
	obj, err := c.Fake.
		Invokes(testing.NewGetAction(routesetsResource, c.ns, name), &v1alpha1.RouteSet{})

	if obj == nil {
		return nil, err
	}
	return obj.(*v1alpha1.RouteSet), err
}

// List takes label and field selectors, and returns the list of RouteSets that match those selectors.
func (c *FakeRouteSets) List(ctx context.Context, opts v1.ListOptions) (result *v1alpha1.RouteSetList, err error) {
	obj, err := c.Fake.
		Invokes(testing.NewListAction(routesetsResource, routesetsKind, c.ns, opts), &v1alpha1.RouteSetList{})

	if obj == nil {
		return nil, err
	}

	label, _, _ := testing.ExtractFromListOptions(opts)
	if label == nil {
		label = labels.Everything()
	}
	list := &v1alpha1.RouteSetList{ListMeta: obj.(*v1alpha1.RouteSetList).ListMeta}
	for _, item := range obj.(*v1alpha1.RouteSetList).Items {
		if label.Matches(labels.Set(item.Labels)) {
			list.Items = append(list.Items, item)
		}
	}
	return list, err
}

// Watch returns a watch.Interface that watches the requested routeSets.
func (c *FakeRouteSets) Watch(ctx context.Context, opts v1.ListOptions) (watch.Interface, error) {
	return c.Fake.
		InvokesWatch(testing.NewWatchAction(routesetsResource, c.ns, opts))

}

// Create takes the representation of a routeSet and creates it.  Returns the server's representation of the routeSet, and an error, if there is any.
func (c *FakeRouteSets) Create(ctx context.Context, routeSet *v1alpha1.RouteSet, opts v1.CreateOptions) (result *v1alpha1.RouteSet, err error) {
	obj, err := c.Fake.
		Invokes(testing.NewCreateAction(routesetsResource, c.ns, routeSet), &v1alpha1.RouteSet{})

	if obj == nil {
		return nil, err
	}
	return obj.(*v1alpha1.RouteSet), err
}

// Update takes the representation of a routeSet and updates it. Returns the server's representation of the routeSet, and an error, if there is any.
func (c *FakeRouteSets) Update(ctx context.Context, routeSet *v1alpha1.RouteSet, opts v1.UpdateOptions) (result *v1alpha1.RouteSet, err error) {
	obj, err := c.Fake.
		Invokes(testing.NewUpdateAction(routesetsResource, c.ns, routeSet), &v1alpha1.RouteSet{})

	if obj == nil {
		return nil, err
	}
	return obj.(*v1alpha1.RouteSet), err
}

// UpdateStatus was generated because the type contains a Status member.
// Add a +genclient:noStatus comment above the type to avoid generating UpdateStatus().
func (c *FakeRouteSets) UpdateStatus(ctx context.Context, routeSet *v1alpha1.RouteSet, opts v1.UpdateOptions) (*v1alpha1.RouteSet, error) {
	obj, err := c.Fake.
		Invokes(testing.NewUpdateSubresourceAction(routesetsResource, "status", c.ns, routeSet), &v1alpha1.RouteSet{})

	if obj == nil {
		return nil, err
	}
	return obj.(*v1alpha1.RouteSet), err
}

// Delete takes name of the routeSet and deletes it. Returns an error if one occurs.
func (c *FakeRouteSets) Delete(ctx context.Context, name string, opts v1.DeleteOptions) error {
	_, err := c.Fake.
		Invokes(testing.NewDeleteAction(routesetsResource, c.ns, name), &v1alpha1.RouteSet{})

	return err
}

// DeleteCollection deletes a collection of objects.
func (c *FakeRouteSets) DeleteCollection(ctx context.Context, opts v1.DeleteOptions, listOpts v1.ListOptions) error {
	action := testing.NewDeleteCollectionAction(routesetsResource, c.ns, listOpts)

	_, err := c.Fake.Invokes(action, &v1alpha1.RouteSetList{})
	return err
}

// Patch applies the patch and returns the patched routeSet.
func (c *FakeRouteSets) Patch(ctx context.Context, name string, pt types.PatchType, data []byte, opts v1.PatchOptions, subresources ...string) (result *v1alpha1.RouteSet, err error) {
	obj, err := c.Fake.
		Invokes(testing.NewPatchSubresourceAction(routesetsResource, c.ns, name, pt, data, subresources...), &v1alpha1.RouteSet{})

	if obj == nil {
		return nil, err
	}
	return obj.(*v1alpha1.RouteSet), err
}