variable "cluster_id" {
  description = "The ECS cluster ID"
  type        = string
}

variable "designated_subnets" {
  description = "The subnets for ECS service"
  type        = list
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}