# --- Réseau (VPC & Private Networks) ---

resource "scaleway_vpc" "medinplus_vpc" {
  name   = var.vpc_name
  region = var.region
  tags   = ["env:${var.environment}", "project:${var.project_name}"]
}

resource "scaleway_vpc_private_network" "proxmox_pn" {
  name   = "proxmox-private-network"
  vpc_id = scaleway_vpc.medinplus_vpc.id
  region = var.region
  tags   = ["env:${var.environment}", "project:${var.project_name}", "network:proxmox"]
  ipv4_subnet {
    subnet = var.proxmox_pn_cidr
  }
}

resource "scaleway_vpc_private_network" "app_pn" {
  name   = "app-medinplus-private-network"
  vpc_id = scaleway_vpc.medinplus_vpc.id
  region = var.region
  tags   = ["env:${var.environment}", "project:${var.project_name}", "network:app"]
  ipv4_subnet {
    subnet = var.app_pn_cidr
  }
}

# --- Public Gateway & Règle NAT ---

resource "scaleway_vpc_public_gateway_ip" "main_ip" {
  zone = var.zone
  tags = ["env:${var.environment}", "project:${var.project_name}"]
}

resource "scaleway_vpc_public_gateway" "main_gw" {
  name              = "${var.project_name}-gateway"
  type              = var.gateway_type
  bastion_enabled   = true
  bastion_port      = var.bastion_port
  allowed_ip_ranges = [var.authorized_ip]
  ip_id             = scaleway_vpc_public_gateway_ip.main_ip.id
  zone              = var.zone
  tags              = ["env:${var.environment}", "project:${var.project_name}"]
}

resource "scaleway_vpc_gateway_network" "gw_network_attachment" {
  gateway_id         = scaleway_vpc_public_gateway.main_gw.id
  private_network_id = scaleway_vpc_private_network.proxmox_pn.id
  zone               = var.zone
}

resource "scaleway_vpc_public_gateway_pat_rule" "rdp_rule" {
  gateway_id   = scaleway_vpc_public_gateway.main_gw.id
  public_port  = 3389
  private_ip   = var.rdp_target_private_ip
  private_port = 3389
  protocol     = "tcp"
  zone         = var.zone
  depends_on   = [scaleway_vpc_gateway_network.gw_network_attachment]
}

# --- Serveur Elastic Metal ---

data "scaleway_baremetal_option" "private_network_option" {
  zone = var.zone
  name = "Private Network"
}

data "scaleway_baremetal_offer" "main_offer" {
  zone = var.zone
  name = var.baremetal_offer_name
}

resource "scaleway_baremetal_server" "main_server" {
  name                     = "em-server-${var.environment}"
  zone                     = var.zone
  offer                    = data.scaleway_baremetal_offer.main_offer.offer_id
  install_config_afterward = true
  tags                     = ["env:${var.environment}", "project:${var.project_name}"]

  lifecycle {
    create_before_destroy = true
  }

  options {
    id = data.scaleway_baremetal_option.private_network_option.option_id
  }

  private_network {
    id = scaleway_vpc_private_network.proxmox_pn.id
  }
}

# --- Load Balancer & ACL ---

resource "scaleway_lb_ip" "lb_ip" {
  zone = var.zone
  tags = ["env:${var.environment}", "project:${var.project_name}"]
}

resource "scaleway_ipam_ip" "lb_private_ip" {
  address = var.lb_private_ip_address
  source {
    private_network_id = scaleway_vpc_private_network.proxmox_pn.id
  }
  tags = ["env:${var.environment}", "project:${var.project_name}"]
}

resource "scaleway_lb" "main_lb" {
  name        = "${var.project_name}-lb-${var.environment}"
  ip_ids      = [scaleway_lb_ip.lb_ip.id]
  type        = var.lb_type
  zone        = var.zone
  description = "Load Balancer for ${var.project_name} ${var.environment}"
  tags        = ["env:${var.environment}", "project:${var.project_name}"]

  lifecycle {
    create_before_destroy = true
  }

  private_network {
    private_network_id = scaleway_vpc_private_network.proxmox_pn.id
    ipam_ids           = [scaleway_ipam_ip.lb_private_ip.id]
  }
}

resource "scaleway_lb_backend" "https_backend" {
  lb_id            = scaleway_lb.main_lb.id
  name             = "https-backend"
  forward_protocol = "tcp"
  forward_port     = 443
  proxy_protocol   = "none"
}

resource "scaleway_lb_backend" "rdp_backend" {
  lb_id            = scaleway_lb.main_lb.id
  name             = "rdp-backend"
  forward_protocol = "tcp"
  forward_port     = 3389
  proxy_protocol   = "none"
}

resource "scaleway_lb_frontend" "https_frontend" {
  lb_id        = scaleway_lb.main_lb.id
  backend_id   = scaleway_lb_backend.https_backend.id
  name         = "https-frontend"
  inbound_port = 443
}

resource "scaleway_lb_frontend" "rdp_frontend" {
  lb_id        = scaleway_lb.main_lb.id
  backend_id   = scaleway_lb_backend.rdp_backend.id
  name         = "rdp-frontend"
  inbound_port = 3389
}

resource "scaleway_lb_acl" "ip_filter_https" {
  frontend_id = scaleway_lb_frontend.https_frontend.id
  name        = "Allow-Specific-IP-HTTPS"
  index       = 0
  action {
    type = "allow"
  }
  match {
    ip_subnet = ["${var.authorized_ip}/32"]
  }
}

resource "scaleway_lb_acl" "ip_filter_rdp" {
  frontend_id = scaleway_lb_frontend.rdp_frontend.id
  name        = "Allow-Specific-IP-RDP"
  index       = 0
  action {
    type = "allow"
  }
  match {
    ip_subnet = ["${var.authorized_ip}/32"]
  }
}

# --- Bucket S3 & Politique d'accès ---

resource "scaleway_object_bucket" "main_bucket" {
  name          = var.bucket_name
  region        = var.region
  force_destroy = true
  tags          = { "env" = var.environment, "project" = var.project_name }
}

data "scaleway_iam_user" "current" {
  email = var.terraform_user_email
}

resource "scaleway_object_bucket_policy" "main_policy" {
  bucket = scaleway_object_bucket.main_bucket.name
  region = scaleway_object_bucket.main_bucket.region
  policy = jsonencode({
    Version = "2023-04-17",
    Statement = [
      {
        Sid    = "AllowAppFromSpecificIP",
        Effect = "Allow",
        Principal = {
          "SCW" : [
            "application_id:${scaleway_iam_application.medinplus_app.id}"
          ]
        },
        Action   = "s3:*",
        Resource = [
          scaleway_object_bucket.main_bucket.name,
          "${scaleway_object_bucket.main_bucket.name}/*"
        ],
        Condition = {
          IpAddress = {
            "aws:SourceIp" = "${var.authorized_ip}/32"
          }
        }
      },
      {
        Sid       = "AllowOwnerFullAccess",
        Effect    = "Allow",
        Principal = {
          "SCW" : [
            "user_id:${data.scaleway_iam_user.current.id}"
          ]
        },
        Action   = "s3:*",
        Resource = [
          scaleway_object_bucket.main_bucket.name,
          "${scaleway_object_bucket.main_bucket.name}/*"
        ]
      }
    ]
  })
}

# --- IAM (Application & Clé API) ---

resource "scaleway_iam_application" "medinplus_app" {
  name        = var.iam_app_name
  description = "Application for ${var.project_name} ${var.environment}"
}

resource "scaleway_iam_policy" "app_policy" {
  name           = "${var.project_name}-${var.environment}-app-policy"
  application_id = scaleway_iam_application.medinplus_app.id
  description    = "Permissions for ${var.project_name} ${var.environment} application"
  rule {
    # CORRECTION: Application du principe de moindre privilège.
    # On ne donne que les permissions strictement nécessaires.
    permission_set_names = [
      "ObjectStorageFullAccess"
    ]
    project_ids = [var.scw_project_id]
  }
}

resource "scaleway_iam_api_key" "app_key" {
  application_id = scaleway_iam_application.medinplus_app.id
  description    = "API key for ${var.project_name} ${var.environment} application"
}