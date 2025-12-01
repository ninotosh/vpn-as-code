package main

import rego.v1

test_resource_missing if {
	violation[resource_missing] with input as {}
	violation[resource_missing] with input as {"resource": null}

	valid := parse_config("hcl2", `
		resource "aws_lightsail_key_pair" "this" {
		}
		resource "aws_lightsail_instance" "this" {
		}
		resource "aws_lightsail_static_ip" "this" {
		}
		resource "aws_lightsail_static_ip_attachment" "this" {
		}
		resource "aws_lightsail_instance_public_ports" "this" {
		}
	`)

	not violation[resource_missing] with input as valid

	missing_aws_lightsail_key_pair := json.remove(valid, ["resource/aws_lightsail_key_pair"])
	violation[resource_missing] with input as missing_aws_lightsail_key_pair
}
