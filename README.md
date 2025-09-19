nfrastructure Terraform pour Medinplus sur Scaleway
Ce projet Terraform déploie une infrastructure complète sur Scaleway. Il a pour but de mettre en place un environnement sécurisé et fonctionnel comprenant un VPC, un serveur Bare Metal, un Load Balancer, un bucket S3 et les politiques IAM nécessaires.

Prérequis
Avant de commencer, assurez-vous d'avoir les éléments suivants :

Terraform : Version 1.5.0 ou supérieure installée sur votre machine.

Compte Scaleway : Un compte Scaleway actif.

Clés d'API Scaleway : Votre access_key et secret_key IAM. Celles-ci sont essentielles pour que Terraform puisse s'authentifier auprès de l'API Scaleway.

Configuration
Suivez ces étapes pour configurer et déployer l'infrastructure.

1. Clés d'API Scaleway (Secret)
Pour des raisons de sécurité, vos clés d'API ne doivent jamais être écrites directement dans les fichiers de configuration. La méthode recommandée est d'utiliser des variables d'environnement.

Méthode Recommandée : Variables d'Environnement
Le provider Scaleway pour Terraform recherche automatiquement ces variables. Vous n'aurez rien d'autre à configurer si vous utilisez cette méthode.

Sur Linux ou macOS :

Bash

export SCW_ACCESS_KEY="VOTRE_ACCESS_KEY"
export SCW_SECRET_KEY="VOTRE_SECRET_KEY"
Sur Windows (PowerShell) :

PowerShell

$env:SCW_ACCESS_KEY="VOTRE_ACCESS_KEY"
$env:SCW_SECRET_KEY="VOTRE_SECRET_KEY"
Vous pouvez également définir la variable SCW_DEFAULT_PROJECT_ID pour cibler votre projet par défaut, bien que celui-ci soit déjà défini dans le fichier terraform.tfvars.

⚠️ Méthode Alternative (Non Recommandée)
Si vous ne pouvez pas utiliser les variables d'environnement, vous pouvez ajouter vos clés au fichier terraform.tfvars. Si vous faites cela, assurez-vous que ce fichier est inclus dans votre .gitignore pour ne jamais l'envoyer sur un dépôt de code !

Terraform

# terraform.tfvars

scw_access_key = "VOTRE_ACCESS_KEY"
scw_secret_key = "VOTRE_SECRET_KEY"
2. Personnaliser le fichier terraform.tfvars
Vous devez compléter le fichier terraform.tfvars avec les informations spécifiques à votre projet.

Ouvrez le fichier terraform.tfvars et remplissez les variables suivantes :


scw_project_id: L'ID de votre projet Scaleway.


scw_organization_id: L'ID de votre organisation Scaleway.

authorized_ip: Votre adresse IP publique. C'est crucial pour autoriser l'accès au bastion SSH et au Load Balancer.


rdp_target_private_ip: L'adresse IP privée de la VM Windows à laquelle vous souhaitez accéder via RDP.


baremetal_offer_name: Le nom commercial de l'offre de serveur Bare Metal que vous souhaitez (ex: "EM-T220E-L40S").

terraform_user_email: L'adresse e-mail de l'utilisateur IAM qui exécute Terraform. Cela est utilisé pour garantir que le créateur du bucket S3 en conserve l'accès complet.


Déploiement
Une fois la configuration terminée, suivez les étapes de déploiement standards de Terraform.

Initialisation
Lancez cette commande pour télécharger les dépendances nécessaires, notamment le provider Scaleway.

Bash

terraform init
Planification
Cette commande vous montre un aperçu de toutes les ressources qui seront créées. C'est une étape de vérification importante.

Bash

terraform plan
Application
Si le plan vous convient, appliquez-le pour créer réellement les ressources sur Scaleway.

Bash

terraform apply
Terraform vous demandera une confirmation. Tapez yes et validez.

Après le Déploiement
Une fois l'exécution de terraform apply terminée, les sorties (outputs) définies dans le fichier outputs.tf seront affichées à l'écran. Vous y trouverez des informations importantes comme :

L'ID du VPC (

vpc_id) 

L'adresse IP publique de la passerelle (

public_gateway_ip) 

L'adresse IP publique du Load Balancer (

load_balancer_ip) 

L'endpoint du bucket S3 (

s3_bucket_endpoint) 

Les clés d'accès (

application_api_access_key et application_api_secret_key) pour l'application IAM qui a été créée.

Nettoyage
Pour supprimer toutes les ressources créées par ce projet et éviter des coûts inutiles, utilisez la commande suivante :

Bash

terraform destroy
