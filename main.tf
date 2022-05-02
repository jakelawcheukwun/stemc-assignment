locals {
  name        = "assignment-ecs"
  environment = "dev"

  # This is the convention we use to know what belongs to each other
  ec2_resources_name = "${local.name}-${local.environment}"
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name

  cidr = "10.1.0.0/16"

  azs             = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets  = ["10.1.11.0/24", "10.1.12.0/24"]

  enable_nat_gateway = false

  tags = {
    Environment = local.environment
    Name        = local.name
  }
}

#------- ECS --------

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  version = "~> 3.5"
  name               = local.name
  container_insights = true

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy = [{
    capacity_provider = "FARGATE"
    weight            = "1"
  }]

  tags = {
    Environment = local.environment
  }
}

#----- ECS  Services--------
module "service-http-container" {
  source = "./modules/service-http-container"

  cluster_id = module.ecs.ecs_cluster_id
  designated_subnets = module.vpc.public_subnets
  vpc_id = module.vpc.vpc_id
}

