terraform_cloud: close({
	organization: close({
		name:      =~"^[a-zA-Z][a-zA-Z0-9_]{1,30}[a-zA-Z0-9]$"
		workspace: =~"^[a-zA-Z][a-zA-Z0-9_]{1,30}[a-zA-Z0-9]$"
	})
})
google_cloud?: close({
	project_id: =~"^[a-z][a-z0-9-]{4,28}[a-z0-9]$"
})
#server_name: =~"^[a-z][-a-z0-9]{0,30}[a-z0-9]$"
#client:      =~"^[a-zA-Z][-a-zA-Z0-9_]{1,30}[a-zA-Z0-9]$"
#lightsail: {
	region:  =~"^[a-z]+-[a-z]+-[0-9]$"
	compute: "lightsail"
	lightsail: {
		availability_zone: =~"^[a-z]$"
		blueprint_id:      =~"^[a-z0-9]+(_[a-z0-9]+)*$"
		bundle_id:         =~"^[a-z0-9]+(_[a-z0-9]+)+$"
	}
}
#server: {
	applications: ["openvpn"]
	clients: [...#client]
}
#aws_server: {
	provider: "aws"
	aws:      #lightsail
	#server
}
#gce: {
	compute: "gce"
	gce: {
		region:       =~"^[a-z]+-[a-z]+[0-9]$"
		zone:         =~"^[a-z]$"
		machine_type: =~"^[a-z0-9]+(-[a-z0-9]+)+$"
		image: {
			project: =~"^[a-z0-9]+(-[a-z0-9]+)+$"
			family:  =~"^[a-z0-9]+(-[a-z0-9]+)+$"
		}
		enable_ipv6: bool
	}
}
#gc_server: {
	provider: "gc"
	gc:       #gce
	#server
}
servers: close({
	[#server_name]: #aws_server | #gc_server
}) | null
