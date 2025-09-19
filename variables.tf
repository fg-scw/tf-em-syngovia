# --- Identifiants Scaleway ---
variable "scw_project_id" {
  type        = string
  description = "The Scaleway Project ID to deploy resources in."
}

variable "scw_organization_id" {
  type        = string
  description = "The Scaleway Organization ID."
}

# --- Configuration Générale ---
variable "project_name" {
  type        = string
  description = "Nom du projet, utilisé pour nommer les ressources."
  default     = "medinplus"
}

variable "environment" {
  type        = string
  description = "Environnement de déploiement (ex: poc, dev, prod)."
  default     = "poc"
}

# --- Configuration de la Localisation ---
variable "region" {
  type        = string
  description = "The Scaleway region to deploy resources in."
  default     = "fr-par"
}

variable "zone" {
  type        = string
  description = "The Scaleway zone to deploy resources in."
  default     = "fr-par-2"
}

# --- Configuration Réseau ---
variable "vpc_name" {
  type        = string
  description = "Nom du VPC."
  default     = "medinplus-vpc-poc"
}

variable "proxmox_pn_cidr" {
  type        = string
  description = "Bloc CIDR pour le réseau privé Proxmox."
  default     = "172.16.0.0/24"
}

variable "app_pn_cidr" {
  type        = string
  description = "Bloc CIDR pour le réseau privé applicatif."
  default     = "172.16.1.0/24"
}

variable "authorized_ip" {
  type        = string
  description = "The source IP address authorized to access the LB and S3 bucket."
}

variable "rdp_target_private_ip" {
  type        = string
  description = "The private IP of the server for the RDP NAT rule."
}

# --- Configuration du Gateway ---
variable "gateway_type" {
  type        = string
  description = "Type de l'offre pour le Public Gateway."
  default     = "VPC-GW-S"
}

variable "bastion_port" {
  type        = number
  description = "Port à utiliser pour le bastion du Gateway."
  default     = 61000
}

# --- Configuration du Load Balancer ---
variable "lb_type" {
  type        = string
  description = "Type de l'offre pour le Load Balancer."
  default     = "LB-S"
}

variable "lb_private_ip_address" {
  type        = string
  description = "Adresse IP privée statique pour le Load Balancer."
  default     = "172.16.0.100"
}

# --- Configuration du Serveur & Bucket ---
variable "bucket_name" {
  type        = string
  description = "The Name of the Bucket"
}

variable "baremetal_offer_name" {
  type        = string
  description = "The commercial name of the Bare Metal offer to use (e.g., 'EM-B112X-SSD')."
}

# --- Configuration IAM ---
variable "terraform_user_email" {
  type        = string
  description = "The email of the IAM user running Terraform to grant S3 bucket access."
}

variable "iam_app_name" {
  type        = string
  description = "Nom de l'application IAM."
  default     = "medinplus-poc-app"
}