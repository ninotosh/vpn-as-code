# summary

This is Infrastructure as Code applied to VPN.
You can automate deployment of VPN tunneling servers
for personal use with Terraform and Ansible executed in GitHub Actions.

# key features

- fully automated deployment and removal of VPN servers
- multicloud support
- VPN connections on TCP port 443 (typically used for HTTPS) and UDP port 53 (typically used for DNS)
- completely personal VPN servers at locations of your choice

# overview

```mermaid
sequenceDiagram
    actor you
    participant gh as GitHub
    participant ht as HCP Terraform
    participant cs as cloud service
    participant srv as server

    rect rgb(191, 223, 255, .5)
      you ->> you: edit config.yml
      you ->> gh: open a pull request
      gh ->> ht: request to run terraform
      ht ->> cs: `terraform plan`
      cs ->> ht: plan
      ht ->> gh: plan
      gh ->> you: see the plan
    end

    rect rgb(191, 223, 255, .5)
      you ->> gh: merge the pull request
      gh ->> ht: request to run terraform
      ht ->> cs: `terraform apply`
      cs ->> srv: create a<br/>compute instance
      srv ->> cs: 
      cs ->> ht: server information
      ht ->> gh: server information
      gh ->> srv: run ansible
      srv ->> srv: start a VPN server
      srv ->> gh: client files
      gh ->> you: download the client files
    end

    rect rgb(191, 223, 255, .5)
      you ->> srv: establish a VPN connection
    end
```

# supported environments

## cloud services and compute resources to run VPN servers on

- AWS
  - Lightsail
- Google Cloud
  - Compute Engine

## OS

- Ubuntu 24.04

## VPN application

- OpenVPN

> [!NOTE]  
> WireGuard is planned

## protocols

### transport layer

- TCP (port 443)
- UDP (port 53)

### network layer

- IPv4
- IPv6

# prerequisites

- accounts
  - [GitHub](https://docs.github.com/en/get-started/start-your-journey/creating-an-account-on-github)
  - [HashiCorp Cloud Platform](https://developer.hashicorp.com/hcp/docs/hcp/create-account) or [HCP Terraform](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-sign-up)
  - one or more of
    - [AWS](https://aws.amazon.com/resources/create-account/)
    - [Google](https://support.google.com/accounts/answer/27441) for Google Cloud
- VPN client application on each client

# steps

## copy this repository

[Use the template feature](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template).

## initialize the project

### 1. set up HCP Terraform

1. [create an organization](https://developer.hashicorp.com/terraform/cloud-docs/users-teams-organizations/organizations#create-an-organization)
1. [create a workspace](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/create) in the CLI-driven workflow

### 2. set up Google Cloud

1. [create a project](https://developers.google.com/workspace/guides/create-project) if you deploy servers to Google Cloud
1. [enable the Compute Engine API](https://console.cloud.google.com/apis/library/compute.googleapis.com)

## set up access

### 1. allow HCP Terraform to access the cloud services

#### 1.1. set up OIDC integration

##### AWS

See [Use dynamic credentials with the AWS provider](https://developer.hashicorp.com/terraform/cloud-docs/dynamic-provider-credentials/aws-configuration)
for details.

##### Google Cloud

**[Add a Workload Identity Pool and Provider](https://developer.hashicorp.com/terraform/cloud-docs/dynamic-provider-credentials/gcp-configuration#add-a-workload-identity-pool-and-provider)**

Additionally set this attribute mapping on the provider.

| Google | OIDC |
| --- | --- |
|`attribute.terraform_organization_name`|`assertion.terraform_organization_name`|

See [Configure attribute mapping](https://developer.hashicorp.com/terraform/enterprise/registry/test/dynamic-credentials/gcp#configure-attribute-mapping)
for details.

**[Add Permissions to the Workload Identity Principal](https://developer.hashicorp.com/terraform/cloud-docs/dynamic-provider-credentials/gcp-configuration#add-permissions-to-the-workload-identity-principal)**

The principal should look like the following.

```
principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID/attribute.terraform_organization_name/ORGANIZATION_NAME
```

Select `Compute Admin` when assigning roles to the workload identity pool principal.

#### 1.2. [set workspace-specific variables](https://www.terraform.io/cloud-docs/workspaces/variables/managing-variables#workspace-specific-variables) as follows

##### AWS

See [Required Environment Variables](https://developer.hashicorp.com/terraform/cloud-docs/dynamic-provider-credentials/aws-configuration#required-environment-variables).

##### Google Cloud

See [Required Environment Variables](https://developer.hashicorp.com/terraform/cloud-docs/dynamic-provider-credentials/gcp-configuration#required-environment-variables).


### 2. allow GitHub to access HCP Terraform

#### 2.1. [create a team API token](https://www.terraform.io/cloud-docs/users-teams-organizations/api-tokens#team-api-tokens) of HCP Terraform

#### 2.2. [set a repository secret](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-a-repository)

| name | value |
| ---- | ----- |
| `HCP_TERRAFORM_TEAM_TOKEN` | HCP Terraform team API token |


### 3. allow GitHub to access your servers in the cloud

#### 3.1. create an SSH key pair

1. go to the GitHub Actions page and [manually run the workflow](https://docs.github.com/en/actions/managing-workflow-runs/manually-running-a-workflow#running-a-workflow) to [create an SSH key pair](.github/workflows/keygen.yml)

2. [download the zipped artifact](https://docs.github.com/en/actions/managing-workflow-runs/downloading-workflow-artifacts)

    The artifact in GitHub will be automatically deleted in 1 day.

3. unzip the downloaded file

    A file with the `.pub` extension is a public key.
    The other file is a private key.

#### 3.2. set the SSH key pair for GitHub Actions

##### 3.2.1. [set a repository secret](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-a-repository)

| name | value |
| ---- | ----- |
| `SSH_PRIVATE_KEY` | SSH private key |

##### 3.2.2. [set a repository variable](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-variables#creating-configuration-variables-for-a-repository)

| name | value |
| ---- | ----- |
| `SSH_PUBLIC_KEY` | SSH public key |

#### 3.3. delete the downloaded SSH key files

## add / remove servers, or add clients

1. add or edit `config.yml`

See [config-example.yml](config-example.yml) for example.

> [!TIP]  
> You can use `get-blueprints` and `get-bundles` commands in
> [CloudShell](https://docs.aws.amazon.com/cloudshell/latest/userguide/getting-started.html) to
> [list Lightsail blueprints and bundles](https://repost.aws/knowledge-center/lightsail-aws-cli-commands).

2. open a pull request
3. check the plan at the summary on the GitHub Actions page
4. merge the pull request if the plan is fine
5. check the deployment on the GitHub Actions page

> [!TIP]  
> You can add more servers or clients by running the same steps.

> [!TIP]  
> to remove all the existing servers, make `config.yml` look like the one below
> and follow the same steps as to add servers

```yaml
terraform_cloud:
  organization:
    name: my_organization_2558
    workspace: my_workspace
google_cloud:
  project_id: my-project-147248
servers:
```

## make a VPN connection on clients

1. [download](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/download-workflow-artifacts) the artifact for VPN client files from the GitHub Actions page
1. optionally, edit the files as you like
1. move the files to each client
1. make a VPN connection on each client using the VPN application
