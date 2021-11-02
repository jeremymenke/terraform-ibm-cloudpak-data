#####################################################
# activity tracker as a service
# Copyright 2020 IBM
#####################################################

terraform {
  required_version = ">=0.13"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.34"
    }
    external = {
      source = "hashicorp/external"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}