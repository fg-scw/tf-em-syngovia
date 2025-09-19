output "vpc_id" {
  value       = scaleway_vpc.medinplus_vpc.id
  description = "ID of the created VPC."
}

output "public_gateway_ip" {
  value       = scaleway_vpc_public_gateway_ip.main_ip.address
  description = "Public IP address of the Gateway for NAT."
}

output "load_balancer_ip" {
  value       = scaleway_lb_ip.lb_ip.ip_address
  description = "Public IP address of the Load Balancer."
}

output "s3_bucket_endpoint" {
  value       = scaleway_object_bucket.main_bucket.endpoint
  description = "Endpoint of the S3 bucket."
}

output "application_api_access_key" {
  value       = nonsensitive(scaleway_iam_api_key.app_key.access_key)
  description = "Access key for the IAM application."
}

output "application_api_secret_key" {
  value       = nonsensitive(scaleway_iam_api_key.app_key.secret_key)
  description = "Secret key for the IAM application."
}

#value = nonsensitive(var.mysecret)