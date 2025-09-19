# terraform.tfvars

# --- Identifiants Scaleway (À Remplir) ---
scw_project_id      = "c96fe71c-xxxx-xxxx-xxxx-eb37baeb627e"
scw_organization_id = "e97e853d-xxxx-xxxx-xxxx-ec5d6abc8fa8"

# --- Configuration de la Localisation ---
region = "fr-par"
zone   = "fr-par-2"

# --- Configuration Réseau & Sécurité (À Remplir)---
# REMPLACEZ CECI par votre véritable adresse IP publique afin qu'elle soit autorisée à se connecter au bastion SSH & Load Balancer "ACL"
authorized_ip = "1.2.3.4"

# L'adresse IP privée de la VM Windows cible pour la règle NAT du RDP.
rdp_target_private_ip = "172.16.0.12"

# --- Configuration du Serveur (À Remplir)---
# Le nom commercial de l'offre Elastic Metal que vous souhaitez déployer.
baremetal_offer_name = "EM-T220E-L40S"
bucket_name          = "test-s3-bucket-syngovia-test"

# --- Configuration Utilisateur (À Remplir)---
# REMPLACEZ CECI par l'e-mail de l'utilisateur IAM qui exécute Terraform.
terraform_user_email = "test@scaleway.com"