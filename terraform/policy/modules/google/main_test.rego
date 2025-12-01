package main

import rego.v1

test_resource_missing_or_excessive if {
	violation[resource_missing_or_excessive] with input as {}
	violation[resource_missing_or_excessive] with input as {"resource": {}}
	violation[resource_missing_or_excessive] with input as {"resource": {
		"google_compute_instance": null,
		"google_compute_firewall": null,
	}}
	not violation[resource_missing_or_excessive] with input as {"resource": {
		"google_compute_network": null,
		"google_compute_subnetwork": null,
		"google_compute_address": null,
		"google_compute_instance": null,
		"google_compute_firewall": null,
	}}
	violation[resource_missing_or_excessive] with input as {"resource": {
		"foo": null,
		"google_compute_network": null,
		"google_compute_subnetwork": null,
		"google_compute_address": null,
		"google_compute_instance": null,
		"google_compute_firewall": null,
	}}
}
