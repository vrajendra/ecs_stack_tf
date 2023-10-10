provider "aws" {
  region = var.region
}

module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git"
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  delimiter  = var.delimiter
  attributes = var.attributes
  ipv4_primary_cidr_block = var.vpc_cidr_block
  tags       = var.tags
}

module "subnets" {
  source               = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git"
  availability_zones   = var.availability_zones
  namespace            = var.namespace
  stage                = var.stage
  name                 = var.name
  attributes           = var.attributes
  delimiter            = var.delimiter
  vpc_id               = module.vpc.vpc_id
  igw_id               = [module.vpc.igw_id]
  ipv4_cidr_block      = [module.vpc.vpc_cidr_block]
  nat_gateway_enabled  = true
  nat_instance_enabled = false
  tags                 = var.tags
}

resource "aws_ecs_cluster" "default" {
  name = module.label.id
  tags = module.label.tags
}

module "container_definition" {
  source                       = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git"
  container_name               = var.container_name
  container_image              = var.container_image
  container_memory             = var.container_memory
  container_memory_reservation = var.container_memory_reservation
  container_cpu                = var.container_cpu
  essential                    = var.container_essential
  readonly_root_filesystem     = var.container_readonly_root_filesystem
  port_mappings                = var.container_port_mappings
 # environment                  = var.container_environment
  log_configuration            =  {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-create-group": "true",
                    "awslogs-group": "awslogs-nodejsapp",
                    "awslogs-region": "us-east-1",
                    "awslogs-stream-prefix": "awslogs-njsapp"
                }
            }
}

module "ecs_alb_service_task" {
  depends_on = [ module.alb ]
  source = "git::https://github.com/vrajendra/terraform-aws-ecs-alb-service-task.git"
  # Cloud Posse recommends pinning every module to a specific version
  # version = "x.x.x"
  namespace                          = var.namespace
  stage                              = var.stage
  name                               = var.name
  attributes                         = var.attributes
  delimiter                          = var.delimiter
  alb_security_group                 = module.vpc.vpc_default_security_group_id
  container_definition_json          = module.container_definition.json_map_encoded_list
  ecs_cluster_arn                    = aws_ecs_cluster.default.arn
  launch_type                        = "FARGATE"
  vpc_id                             = module.vpc.vpc_id
  security_group_ids                 = [module.vpc.vpc_default_security_group_id]
  subnet_ids                         = module.subnets.public_subnet_ids
  tags                               = var.tags
  ignore_changes_task_definition     = true
 # runtime_platform                   = {"LINUX"}
  network_mode                       = "awsvpc"
  assign_public_ip                   = true
 # propagate_tags                     = var.propagate_tags
  health_check_grace_period_seconds  = 0
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  deployment_controller_type         = "ECS"
  desired_count                      = 2
  task_memory                        = 16384
  task_cpu                           = 8192
  ecs_load_balancers                =  [{ container_name = var.container_name
                                        target_group_arn = module.alb.default_target_group_arn 
                                        container_port = 3080
                                        elb_name      = null
                                          
  }
  ]
}





















