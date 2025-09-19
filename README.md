# Terraform Medinplus Project

This repository contains the Terraform configuration files for deploying the Medinplus infrastructure on Scaleway.

-----

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed on your machine:

  * **[Terraform](https://www.terraform.io/downloads.html)**: The infrastructure as code tool.
  * **[Scaleway CLI](https://www.scaleway.com/en/cli/)**: Necessary for authentication.

-----

### Step 1: Clone the Repository

Clone this Git repository to your local machine.

```sh
git clone <repository_url>
cd <repository_name>
```

-----

### Step 2: Configure Scaleway Credentials

You need to set up your Scaleway API keys to allow Terraform to manage resources in your account. The most secure way is to set them as environment variables on your computer.

Your **API Access Key** and **Secret Key** can be found in your Scaleway console under **IAM** \> **Users or Application ** \> API Key.

This **API Access Key** need to have right permission to launch this deployment (OrganizationManager, VPCFullAccess, VPCGatewayFullAccess, LoadBalancersFullAccess, ElasticMetalFullAccess, ObjectStorageFullAccess)

```sh
export SCW_ACCESS_KEY="SCWxxxxxxxxxxxxxxxxxxxx"
export SCW_SECRET_KEY="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

*Note: Replace the placeholder values with your actual keys.*

-----

### Step 3: Configure Project Variables

Open the `terraform.tfvars` file and fill in the required values. These variables are specific to your project and environment.

  * [cite\_start]`scw_project_id`: Your Scaleway Project ID[cite: 1].
  * [cite\_start]`scw_organization_id`: Your Scaleway Organization ID[cite: 1].
  * [cite\_start]`authorized_ip`: Your public IP address to allow SSH and Load Balancer access[cite: 1]. You can find it by searching "What's my IP" on Google.
  * [cite\_start]`baremetal_offer_name`: The name of the Elastic Metal server offer you want to deploy[cite: 3].
  * [cite\_start]`bucket_name`: The name for your S3 bucket[cite: 1].
  * [cite\_start]`terraform_user_email`: The email of the IAM user running Terraform[cite: 4].

-----

### Step 4: Initialize and Apply Terraform

Navigate to the project directory in your terminal and run the following commands to initialize Terraform, review the plan, and apply the changes.

1.  **Initialize Terraform:**
    This command downloads the necessary Scaleway provider.

    ```sh
    terraform init
    ```

2.  **Plan the Deployment:**
    This command shows you what resources Terraform will create, update, or destroy. Always review this output before applying.

    ```sh
    terraform plan
    ```

3.  **Apply the Changes:**
    This command creates the infrastructure on Scaleway. You will be prompted to confirm by typing `yes`.

    ```sh
    terraform apply
    ```

-----

## 💡 Outputs

After a successful `terraform apply`, Terraform will output key information about your newly created infrastructure, such as:

  * [cite\_start]`public_gateway_ip`: The public IP of the gateway for NAT[cite: 27].
  * [cite\_start]`load_balancer_ip`: The public IP of the load balancer[cite: 28].
  * [cite\_start]`s3_bucket_endpoint`: The endpoint for your S3 bucket[cite: 29].
  * [cite\_start]`application_api_access_key` and `application_api_secret_key`: API keys for the IAM application[cite: 30, 31].

-----

## 🗑️ Cleanup

To destroy all the resources created by this configuration, run the following command. **Use with caution**, as this action is irreversible.

```sh
terraform destroy
```
