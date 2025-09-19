terraform {
  required_version = ">= 1.5.0"

  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.60.0"
    }
  }
}

provider "scaleway" {
  project_id = var.scw_project_id
  region     = var.region
  zone       = var.zone
}