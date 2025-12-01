#!/bin/bash -eu

# example usage
# $ export CONFIG=roles/openvpn/molecule/default/files/config.yml
# $ export TERRAFORM_OUTPUT_PATH=roles/openvpn/molecule/default/files/tfout.json
# $ ./inventory.sh
# {
#   "_meta": {
#     "hostvars": {
#       "instance0": {
#         "ansible_host": "instance0",
#         "external_ipv6_address": "fe80::fff0",
#         "applications": [
#           "openvpn"
#         ],
#         "clients": [
#           "client0",
#           "client1"
#         ]
#       },
#       "instance1": {
#         "ansible_host": "instance1",
#         "external_ipv6_address": null,
#         "applications": [
#           "openvpn"
#         ],
#         "clients": [
#           "client1"
#         ]
#       }
#     }
#   },
#   "ungrouped": {
#     "hosts": [
#       "instance0",
#       "instance1"
#     ]
#   }
# }

config_json_path=/tmp/config.json
hostvars_path=/tmp/hostvars.json

yq eval . $CONFIG -o json > $config_json_path

cat $config_json_path $TERRAFORM_OUTPUT_PATH |
jq -s '
  .[0].servers * (.[1].aws.value + .[1].gc.value)
  | to_entries
  | map(select(.value.ipv4_address or .value.ipv6_address))
  | from_entries
  | map_values({
    "ansible_host": .ipv4_address,
    "external_ipv6_address": .ipv6_address,
    "applications": .applications,
    "clients": .clients
  })
' > ${hostvars_path}

hostvars="`cat ${hostvars_path}`"
hosts="`echo ${hostvars} | jq keys`"

cat << EOF | jq .
{
  "_meta": {
    "hostvars": ${hostvars}
  },
  "ungrouped": {
    "hosts": ${hosts}
  }
}
EOF
