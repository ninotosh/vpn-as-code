package main

import rego.v1

resource_missing := "resource_missing"

violation contains resource_missing if {
	keys := [
		"aws_lightsail_key_pair",
		"aws_lightsail_instance",
		"aws_lightsail_static_ip",
		"aws_lightsail_static_ip_attachment",
		"aws_lightsail_instance_public_ports",
	]

	key := keys[_]
	not input.resource[key]
}
