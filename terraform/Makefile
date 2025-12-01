SHELL := /bin/bash
.SHELLFLAGS := -c -eu -o pipefail

CONFIG := ../config.yml

SSH_USER :=
SSH_PUBLIC_KEY :=

ssh_json := generated.ssh.auto.tfvars.json
backend_hcl := generated.backend.hcl
servers_json := generated.servers.auto.tfvars.json
gc_json := generated.gc.auto.tfvars.json
aws_tf := generated.aws.tf
gc_tf := generated.gc.tf

${ssh_json}:
	echo "\
	{\"ssh_user\": \"${SSH_USER}\", \"ssh_public_key\": \"${SSH_PUBLIC_KEY}\"}\
	" > ${ssh_json}

${backend_hcl}: ${CONFIG}
	echo '#' > ${backend_hcl}
	yq eval . ${CONFIG} -o json | jq -r '"organization = \"\(.terraform_cloud.organization.name)\""' >> ${backend_hcl}
	yq eval . ${CONFIG} -o json | jq -r '"workspaces { name = \"\(.terraform_cloud.organization.workspace)\" }"' >> ${backend_hcl}

${servers_json}: ${CONFIG}
	yq eval . ${CONFIG} -o json \
	| jq "\
		.servers \
		| del(try .[].applications) \
		| del(try .[].clients) \
		| . // {} \
		| .[] |= {aws: null} + {gc: null} + . \
		| {servers: .} \
	" > ${servers_json}

${gc_json}: ${CONFIG}
	yq eval . ${CONFIG} -o json \
	| jq ".google_cloud.project_id | {google_cloud_project_id: .}" \
	> ${gc_json}

${aws_tf}: ${CONFIG} ${backend_hcl} ${servers_json}
	yq eval . ${CONFIG} -o json \
	| jq '(.servers // {})[] | select(.provider == "aws") | .aws.region' \
	> /tmp/expected_regions
	
	terraform output -json \
	| jq '(.aws.value // {})[].region' \
	> /tmp/actual_regions

	cat /tmp/expected_regions /tmp/actual_regions \
	| sort | uniq | paste -s -d ',' /dev/stdin \
	> /tmp/regions

	echo "templatefile(\"templates/aws.tftpl\", {regions=[`cat /tmp/regions`]})" \
	| terraform console \
	| awk '/^<<EOT$$/, /^EOT$$/' | head -n -1 | tail -n +2 \
	> ${aws_tf}

	rm /tmp/expected_regions /tmp/actual_regions /tmp/regions

${gc_tf}: ${CONFIG} ${backend_hcl} ${servers_json} ${gc_json}
	$(eval expected_count := $(shell \
		yq eval . ${CONFIG} -o json \
		| jq '[(.servers // {})[] | select(.provider == "gc")] | length' \
	))
	$(eval actual_count := $(shell \
		terraform output -json | jq '.gc.value | length' \
	))
	test ${expected_count} -gt 0 -o ${actual_count} -gt 0 \
	&& cp templates/gc.tf ${gc_tf} \
	|| echo -n '' > ${gc_tf}
