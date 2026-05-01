# development

## with external servers

> [!WARNING]  
> This involves HCP Terraform and cloud servers, which may incur some costs.

### SSH

#### generate an SSH key pair

On the GitHub Actions page, run [keygen.yml](/.github/workflows/keygen.yml) and download the key pair,
or run the same commands on your computer.

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
> for the `hashicorp/setup-terraform` action, run `terraform login` with a team API token

> [!NOTE]  
> put the content of the public key in `SSH_PUBLIC_KEY`

> [!TIP]  
> to use another config file instead of `config.yml` in the top directory,
> run `make` with `CONFIG=` like
> `make CONFIG=/path/to/config.yml target-name` 

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
docker cp /path/to/ssh_private_key molecule-bash:/root/ssh_key
```

#### run `ansible-playbook`

In the `molecule-bash` container, run `ansible-playbook` as in [ansible.yml](/.github/workflows/ansible.yml)

> [!TIP]  
> All the necessary environment variables are already set in the container.

> [!TIP]  
> to log in to the server with `ssh`, run `ssh -i ${SSH_PRIVATE_KEY_PATH} -l ubuntu __put_server_ip_address_here__`

> [!NOTE]  
> Installing `openvpn-dco-dkms` may fail if the memory is insufficient.
> However, the Ansible run will move on and the OpenVPN server can work without this module.


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

1. in `ansible/client0.ovpn`, delete `<connection>...</connection>` except one,
and change the host and the port as follows.

| |before|after|
|---|---|---|
|host|`fe80::fff0`|_see below_|
|host|`instance0`|`127.0.0.1`|
|port|`53`|`5300`|
|port|`443`|`4430`|

A new IPv6 address can be
- a link-local address such as `fe80::1` and `fe80::1%lo0`
- one of the addresses returned from
`docker inspect -f '{{range .NetworkSettings.Networks}}{{.GlobalIPv6Address}}{{end}}' instance0`

> [!NOTE]  
> The port forwarding for IPv6 + UDP may not work with Docker Desktop for Mac.

2. establish a VPN connection using the new `ovpn` file

> [!NOTE]  
> This is only for testing connectivity from the host as a client to the container as a server.
> You can not access the internet using this connection.


# tests in GitHub Actions

## unit tests

Some unit tests are automatically run when pull requests are opened.

To run Molecule tests,

1. open a pull request
1. comment as follows

| comment | `certificate` role | `openvpn` role |
|---:|:---:|:---:|
| `/molecule all` | ✅ | ✅ |
| `/molecule certificate` | ✅ | ❌ |
| `/molecule openvpn` | ❌ | ✅ |


## integration tests

> [!IMPORTANT]  
> Integration tests are written to run only in private repositories.

To run the [integration tests](/.github/workflows/integration-tests.yml),

1. set the `HCP_TERRAFORM_TEAM_TOKEN` secret as for server deployment
1. prepare config files
1. open a pull request
1. comment as follows

| comment | deploy servers | run Ansible | clean up servers |config file|
|---:|:---:|:---:|:---:|---|
| `/it full` | ✅ | ✅ | ✅ |`tests/config-deploy.yml`|
| `/it deploy` | ✅ | ❌ | ✅ |`tests/config-deploy.yml`|
| `/it empty` | ❌ | ❌ | ✅ |`tests/config-empty.yml`|

> [!NOTE]  
> Test config files under `tests/` are not included in the public template repository
> because some fields (e.g. Terraform organization name) in config files are personal settings.


# dependency update

> [!IMPORTANT]  
> This is written to run only in private repositories.

[`Renovate`](/.github/workflows/renovate.yml)
is scheduled to automatically make pull requests to update dependencies.

1. [create a personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token) with these scopes:

- `repo`
- `workflow`

See the [token](https://github.com/renovatebot/github-action?tab=readme-ov-file#token)
for details.

2. [set a repository secret](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-a-repository)
called `RENOVATE_TOKEN` with the token from the previous step
