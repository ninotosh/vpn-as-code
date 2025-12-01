package variables

import rego.v1

variable_missing_or_excessive := "variable_missing_or_excessive"

violation contains variable_missing_or_excessive if {
	object.keys(object.get(input, "variable", {})) != {
		"compute_instance",
		"ssh",
		"enable_ipv6",
	}
}
