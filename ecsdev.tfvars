region = "us-east-1"

availability_zones = ["us-east-1a", "us-east-1b"]

namespace = "ecstest"

stage = "dev"

name = "eks-ecs-mig-poc"

vpc_cidr_block = "172.16.0.0/16"

internal = false

http_enabled = true

http_redirect = false

access_logs_enabled = true

alb_access_logs_s3_bucket_force_destroy = true

alb_access_logs_s3_bucket_force_destroy_enabled = true

cross_zone_load_balancing_enabled = false

http2_enabled = true

idle_timeout = 60

ip_address_type = "ipv4"

deletion_protection_enabled = false

deregistration_delay = 15

health_check_path = "/"

health_check_timeout = 10

health_check_healthy_threshold = 2

health_check_unhealthy_threshold = 2

health_check_interval = 15

health_check_matcher = "200-399"

target_group_port = 80

target_group_target_type = "ip"

stickiness = {
  cookie_duration = 60
  enabled         = true
}

container_name = "nodejsapp"
container_image = "362231138751.dkr.ecr.us-east-1.amazonaws.com/frontend/reactnode:v1"
container_memory = 16384
container_memory_reservation = 1024
container_cpu = 8192
container_essential = true 

container_port_mappings = [
  {
    containerPort = 3080
    hostPort      = 3080
    protocol      = "tcp"
  },
  {
    containerPort = 443
    hostPort      = 443
    protocol      = "udp"
  }
]