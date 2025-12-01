package variables

import rego.v1

variable_missing := "variable_missing"

violation contains variable_missing if {
	keys := [
		"lightsail",
		"ssh_public_key",
	]

	key := keys[_]
	not input.variable[key]
}
