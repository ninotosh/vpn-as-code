package variables

import rego.v1

test_variable_missing if {
	violation[variable_missing] with input as {}
	violation[variable_missing] with input as {"variable": null}
	not violation[variable_missing] with input as {"variable": {"lightsail": null, "ssh_public_key": null}}
}
