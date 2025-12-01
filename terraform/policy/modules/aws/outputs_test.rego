package outputs

import rego.v1

test_output_missing if {
	violation[output_missing] with input as {}
	violation[output_missing] with input as {"output": null}
	not violation[output_missing] with input as {"output": {"ipv4_address": null, "region": null}}
}
