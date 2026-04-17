# development

> [!TIP]  
> to start over by cleaning up files, run
> `git check-ignore -- **/* **/.* | xargs --interactive -I {} rm -r {}`

## with external servers

> [!WARNING]  
> This involves HCP Terraform and cloud servers, which may incur some costs.

### SSH

#### generate an SSH key pair

On the GitHub Actions page, run [keygen.yml](/.github/workflows/keygen.yml) and download the key pair,
or run the same commands on the host machine.

### [Terraform](/terraform)

#### start a container

```
docker compose -f docker/compose.yaml run --rm --name terraform-bash terraform-bash
```

> [!TIP]  
> to rebuild the image, run
> `docker compose --progress plain -f docker/compose.yaml build --no-cache terraform-bash`

#### run `terraform`

In the container, run the same commands as in [apply.yml](/.github/workflows/apply.yml)

> [!NOTE]  
> put the content of the public key in `SSH_PUBLIC_KEY`

> [!TIP]  
> to use another config file instead of `config.yml` in the top directory,
> run `make` with `CONFIG=` like
> `make CONFIG=/path/to/config.yml target-name` 

> [!NOTE]  
> for the `hashicorp/setup-terraform` action, run `terraform login` with a team API token

> [!TIP]  
> to remove automatically generated files, run `make clean`

#### save output

After `terraform apply`, run

```
terraform output -json > /tmp/tfout.json
```

### [Ansible](/ansible)

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

In the `molecule-bash` container, run `ansible-playbook` as in [ansible.yml](/.github/workflows/ansible.yml)

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
docker cp molecule-bash:/tmp/download .
```

Edit the `ovpn` file if necessary, and establish a VPN connection.


## without external servers

Only Ansible tasks can be developed without HCP Terraform and cloud servers.

### [Ansible](/ansible)

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


# tests in GitHub Actions

Tests are run in repositories whose names end with `-dev`.
See the workflow files for details.

## unit tests

Open a pull request to run the [unit tests](/.github/workflows/unit-tests.yml).

## integration tests

To run the [integration tests](/.github/workflows/integration-tests.yml),
open a pull request and comment either `/it full`, `/it deploy`, or `/it empty`
on the pull request page.

|  | deploy servers | run Ansible | clean up servers |config file|
|---:|:---:|:---:|:---:|---|
| `full` | ✅ | ✅ | ✅ |`tests/config-deploy.yml`|
| `deploy` | ✅ | ❌ | ✅ |`tests/config-deploy.yml`|
| `empty` | ❌ | ❌ | ✅ |`tests/config-empty.yml`|


> [!NOTE]  
> Test config files under `tests/` are not included in the public template repository
> because some fields (e.g. Terraform organization name) in config files are personal settings.


# dependency update

[`renovatebot/github-action`](https://github.com/renovatebot/github-action)
is scheduled to automatically make pull requests to update dependencies.

1. [create a personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token) with these scopes:

- `repo`
- `workflow`

See the [token](https://github.com/renovatebot/github-action?tab=readme-ov-file#token)
for details.

2. [set a repository secret](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-a-repository)
called `RENOVATE_TOKEN` with the token from the previous step
