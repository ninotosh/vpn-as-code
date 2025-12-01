package outputs

import rego.v1

test_output_missing_or_excessive if {
	violation[output_missing_or_excessive] with input as {}
	violation[output_missing_or_excessive] with input as {"output": {}}
	violation[output_missing_or_excessive] with input as {"output": {"ipv4_address": null}}
	not violation[output_missing_or_excessive] with input as {"output": {
		"ipv4_address": null,
		"ipv6_address": null,
	}}
	violation[output_missing_or_excessive] with input as {"output": {
		"foo": null,
		"ipv4_address": null,
		"ipv6_address": null,
	}}
}
