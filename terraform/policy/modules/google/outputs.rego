package outputs

import rego.v1

output_missing_or_excessive := "output_missing_or_excessive"

violation contains output_missing_or_excessive if {
	object.keys(object.get(input, "output", {})) != {
		"ipv4_address",
		"ipv6_address",
	}
}
