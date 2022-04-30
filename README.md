# Stemcell devops assignment

## Design
This Terraform deployment consists of 3 main components: 
1. VPC
2. ECS cluster
3. ECS service

These 3 components are structured as independent modules in the code.
When successfully applied in Terraform, the http server container can be reached at the public IP of the ENI of the running ECS task.

## Usage

To run this terraform code you need to execute:

```bash
terraform init
terraform plan
terraform apply
```

## Improvements

Possible further iterations for this implementation:

* Load balancer in front of service
* TLS/HTTPS connection
* Elastic IP for easier discovery
* Private subnets with NAT gateway


## Sources
These resources provided guides and tools for this implementation
* <https://github.com/terraform-aws-modules/terraform-aws-ecs>
* <https://github.com/terraform-aws-modules/terraform-aws-vpc>
* <https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_AWSCLI_Fargate.html#ECS_AWSCLI_Fargate_register_task_definition>

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.74 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.74 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs"></a> [ecs](#module\_ecs) | terraform-aws-modules/ecs/aws | ~> 3.5 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 3.0 |
| <a name="module_http_container"></a> [http_container](#modules\_http\_container) | modules/service-http-container | n/a |



