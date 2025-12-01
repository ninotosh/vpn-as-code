package outputs

import rego.v1

output_missing := "output_missing"

violation contains output_missing if {
	keys := [
		"ipv4_address",
		"region",
	]

	key := keys[_]
	not input.output[key]
}
