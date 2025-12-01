include Makefile

APPLY_OUTPUT_JSON_PATH :=
PLAN_RESOURCES_JSON_PATH :=

apply-output: ${APPLY_OUTPUT_JSON_PATH}
ifndef APPLY_OUTPUT_JSON_PATH
	$(error specify APPLY_OUTPUT_JSON_PATH)
endif

${APPLY_OUTPUT_JSON_PATH}: /tmp/terraform_apply
	terraform output -json | tee ${APPLY_OUTPUT_JSON_PATH}

apply: /tmp/terraform_apply

/tmp/terraform_apply: /tmp/terraform_plan
	terraform apply -auto-approve | tee /tmp/terraform_apply

plan-resources: ${PLAN_RESOURCES_JSON_PATH}
ifndef PLAN_RESOURCES_JSON_PATH
	$(error specify PLAN_RESOURCES_JSON_PATH)
endif

${PLAN_RESOURCES_JSON_PATH}: /tmp/terraform_plan
ifndef HCP_TERRAFORM_TEAM_TOKEN
	$(error specify HCP_TERRAFORM_TEAM_TOKEN)
endif
	@RUN_ID="`grep --max-count 1 /runs/ /tmp/terraform_plan | rev | cut -d / -f 1 | rev`" && \
	curl --location --header \
		"Authorization: Bearer ${HCP_TERRAFORM_TEAM_TOKEN}" \
		https://app.terraform.io/api/v2/runs/$${RUN_ID}/plan/json-output \
		| jq '[.planned_values.root_module.child_modules[]?.resources]' \
		| tee ${PLAN_RESOURCES_JSON_PATH}

plan: /tmp/terraform_plan

/tmp/terraform_plan: /tmp/terraform_init ${aws_tf} ${gc_tf}
	terraform plan -no-color | tee /tmp/terraform_plan

init: /tmp/terraform_init

/tmp/terraform_init: ${ssh_json} ${backend_hcl} ${servers_json}
	terraform init -backend-config=${backend_hcl} | tee /tmp/terraform_init
