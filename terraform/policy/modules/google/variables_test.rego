package variables

import rego.v1

test_variable_missing_or_excessive if {
	violation[variable_missing_or_excessive] with input as {}
	violation[variable_missing_or_excessive] with input as {"variable": {}}
	violation[variable_missing_or_excessive] with input as {"variable": {
		"ssh": null,
		"enable_ipv6": null,
	}}
	not violation[variable_missing_or_excessive] with input as {"variable": {
		"compute_instance": null,
		"ssh": null,
		"enable_ipv6": null,
	}}
	violation[variable_missing_or_excessive] with input as {"variable": {
		"foo": null,
		"compute_instance": null,
		"ssh": null,
		"enable_ipv6": null,
	}}
}
