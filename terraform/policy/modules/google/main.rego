package main

import rego.v1

resource_missing_or_excessive := "resource_missing_or_excessive"

violation contains resource_missing_or_excessive if {
	object.keys(object.get(input, "resource", {})) != {
		"google_compute_network",
		"google_compute_subnetwork",
		"google_compute_address",
		"google_compute_instance",
		"google_compute_firewall",
	}
}
