# development

> [!TIP]  
> to start over by cleaning up files, run
> `git check-ignore -- **/* **/.* | xargs --interactive -I {} rm -r {}`

## with external servers

> [!WARNING]  
> This involves HCP Terraform and cloud servers, which may incur some costs.

### SSH

#### generate an SSH key pair

On the GitHub Actions page, run [keygen.yml](workflows/keygen.yml) and download the key pair,
or run the same commands on the host machine.

### [Terraform](../terraform)

#### start a container

```
docker compose -f docker/compose.yaml run --rm --name terraform-bash terraform-bash
```

> [!TIP]  
> to rebuild the image, run
> `docker compose --progress plain -f docker/compose.yaml build --no-cache terraform-bash`

#### run `terraform`

In the container, run the same commands as in [deploy.yml](workflows/deploy.yml)

> [!NOTE]  
> put the content of the public key in `SSH_PUBLIC_KEY`

> [!TIP]  
> to use another config file instead of `config.yml` in the top directory,
> run `make` with `CONFIG=` like
> `make CONFIG=/path/to/config.yml target-name` 

> [!NOTE]  
> for the `hashicorp/setup-terraform` action, run `terraform login` with a team API token

#### save output

After `terraform apply`, run

```
terraform output -json > /tmp/tfout.json
```

### [Ansible](../ansible)

#### start a container

Open a new terminal and run

```
docker compose -f docker/compose.yaml run --rm --name molecule-bash molecule-bash
```

#### copy files

Open yet another terminal and run

```
docker cp terraform-bash:/tmp/tfout.json /tmp
docker cp /tmp/tfout.json molecule-bash:/tmp
```

```
docker cp ${path_to_ssh_private_key} molecule-bash:/root/ssh_key
```

#### run `ansible-playbook`

In the `molecule-bash` container, run `ansible-playbook` as in [deploy.yml](workflows/deploy.yml)

> [!TIP]  
> All the necessary environment variables are already set in the container.

> [!TIP]  
> to log in to the server with `ssh`, run `ssh -i ${path_to_ssh_private_key} -l ubuntu ${server_ip_address}`

> [!NOTE]  
> Installing `openvpn-dco-dkms` may fail due to insufficient memory.
> However, the OpenVPN server can work without this module.


#### establish a VPN connection

On the host,

```
docker cp molecule-bash:${path_to_download_dir} .
```

Edit the `ovpn` file if necessary, and establish a VPN connection.


## without external servers

Only Ansible tasks can be developed without HCP Terraform and cloud servers.

### [Ansible](../ansible)

#### start a container

```
docker compose -f docker/compose.yaml run --rm --name molecule-bash molecule-bash
```

#### run molecule test

In the container,

1. `cd roles/openvpn`
1. `molecule test --all`

#### test connectivity

In the container,

1. `cd roles/openvpn`
1. `molecule converge`
1. `cp /tmp/download/instance0/client0.ovpn /mnt/ansible`

On the host,

1. edit `ansible/client0.ovpn` to make a diff like

```diff
< remote fe80::fff0 53 udp
< remote instance0 53 udp
< remote fe80::fff0 443 tcp
< remote instance0 443 tcp
---
> remote ::1 5300 udp
> remote 127.0.0.1 5300 udp
> remote ::1 4430 tcp
> remote 127.0.0.1 4430 tcp
```

2. establish a VPN connection with it

> [!NOTE]  
> This is only for testing connectivity from the host as a client to the container as a server.
> You can not access the internet using this connection.


# [integration tests](workflows/integration-tests.yml) in GitHub Actions

1. if the team API token of HCP Terraform in
the repository secret `HCP_TERRAFORM_TEAM_TOKEN`
is expired, regenerate a token and set it.
1. open a pull request
1. check the GitHub Actions workflows
