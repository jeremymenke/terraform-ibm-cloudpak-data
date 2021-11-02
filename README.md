# IBM Cloud Pak for Data 4.0 - Terraform Module

This is a module and example to make it easier to provision Cloud Pak for Data on an IBM Cloud Platform OpenShift Cluster provisioned on either Classic or VPC infrastructure. The cluster is required to contain at least 4 nodes of size 16x64. If VPC is used, Portworx™ is required to provide necessary storage classes.

## Compatibility

This module is meant for use with Terraform 0.13 (and higher).

## Usage

A full example is in the [examples](./examples/) folder.

e.g:

```hcl
provider "ibm" {
  region = var.region
  ibmcloud_api_key = var.ibmcloud_api_key
}

data "ibm_resource_group" "group" {
  name = var.resource_group_name
}

resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }
  provisioner "local-exec" {
    command = "mkdir -p ${local.cluster_config_path}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id   = var.cluster_id
  resource_group_id = data.ibm_resource_group.group.id
  config_dir        = local.cluster_config_path
}

# Get classic cluster ingress_hostname for output
data "ibm_container_cluster" "cluster" {
  count = ! var.on_vpc ? 1 : 0
  cluster_name_id = var.cluster_id
}

# Get vpc cluster ingress_hostname for output
data "ibm_container_vpc_cluster" "cluster" {
  count = var.on_vpc ? 1 : 0
  cluster_name_id = var.cluster_id
}

// Module:
module "cp4data" {
  source          = "../.."
  enable          = true

  // ROKS cluster parameters:
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  on_vpc              = var.on_vpc
  portworx_is_ready   = 1          // Assuming portworx is installed if using VPC infrastructure

  // Prereqs
  worker_node_flavor = var.worker_node_flavor

  operator_namespace = var.operator_namespace

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email

  // CP4D License Acceptance
  accept_cpd_license = var.accept_cpd_license

  // CP4D Info
  cpd_project_name = "zen"

  # OP_NAMESPACE="ibm-common-services"

  // IBM Cloud API Key
  ibmcloud_api_key          = var.ibmcloud_api_key

  region = var.region
  resource_group_name = var.resource_group_name
  cluster_id = var.cluster_id

  // Parameters to install submodules

  install_wsl         = var.install_wsl
  install_aiopenscale = var.install_aiopenscale
  install_wml         = var.install_wml
  install_wkc         = var.install_wkc
  install_dv          = var.install_dv
  install_spss        = var.install_spss
  install_cde         = var.install_cde
  install_spark       = var.install_spark
  install_dods        = var.install_dods
  install_ca          = var.install_ca
  install_ds          = var.install_ds
  install_db2oltp     = var.install_db2oltp
  install_db2wh       = var.install_db2wh
  install_big_sql     = var.install_big_sql
  install_wsruntime   = var.install_wsruntime
}

```

## Requirements

### Terraform plugins

- [Terraform](https://www.terraform.io/downloads.html) 0.13 (or later)
- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm) 1.34 (or later)

## Install

### Terraform

Be sure you have the correct Terraform version (0.13), you can choose the binary here:

- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm/releases) 1.34 (or later)
- [Terraform](https://releases.hashicorp.com/terraform/) 0.13 (or later)

For installation instructions, refer [here](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment/#install-terraform)

### Pre-commit hooks

Run the following command to execute the pre-commit hooks defined in .pre-commit-config.yaml file
```
pre-commit run -a
```
You can install pre-commit tool using

```
pip install pre-commit
```
or
```
pip3 install pre-commit
```

### Detect Secret hook

Used to detect secrets within a code base.

To create a secret baseline file run following command

```bash
detect-secrets scan --update .secrets.baseline
```

While running the pre-commit hook, if you encounter an error like

```console
WARNING: You are running an outdated version of detect-secrets.
Your version: 0.13.1+ibm.27.dss
Latest version: 0.13.1+ibm.46.dss
See upgrade guide at https://ibm.biz/detect-secrets-how-to-upgrade
```

run below command

```bash
pre-commit autoupdate
```

which upgrades all the pre-commit hooks present in .pre-commit.yaml file.

## How to input variable values through a file

To review the plan for the configuration defined (no resources actually provisioned)
```
terraform plan -var-file=./input.tfvars
```
To execute and start building the configuration defined in the plan (provisions resources)
```
terraform apply -var-file=./input.tfvars
```

To destroy the VPC and all related resources
```
terraform destroy -var-file=./input.tfvars
```

## Note

All optional parameters, by default, will be set to `null` in respective example's variable.tf file. You can also override these optional parameters.

