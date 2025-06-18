# This Terraform configuration sets up a multi-environment architecture on AWS
# for a user microservice application. It includes a VPC, public subnets, security groups,    

# 1. VPC for all environments
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.app_name}-vpc"
  }
}

# 2. Public Subnets (one per AZ)
resource "aws_subnet" "public" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = element(["us-east-1a", "us-east-1b", "us-east-1c"], count.index)
  tags = {
    Name = "${var.app_name}-public-${count.index}"
  }
}

# 3. Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.app_name}-igw"
  }
}

# 4. Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.app_name}-public-rt"
  }
}

# 5. Security Group for All Instances
resource "aws_security_group" "instances" {
  name        = "${var.app_name}-instances-sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict to your IP in production!
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 6. EC2 Instances for Each Environment
resource "aws_instance" "servers" {
  for_each = var.envs

  ami                    = "ami-0c55b159cbfafe1f0" # Ubuntu 22.04 LTS
  instance_type          = each.value.instance_type
  vpc_security_group_ids = [aws_security_group.instances.id]
  subnet_id              = aws_subnet.public[0].id # All in first AZ for demo
  key_name               = var.ssh_key_name

  tags = {
    Name = "${var.app_name}-${each.key}"
    Env  = each.key
  }

  # Only create specified number of instances
  count = each.key == "prod" ? 1 : each.value.instance_count 
  # (Prod uses ASG instead)
}

# 7. ALB for Production Only
resource "aws_lb" "prod" {
  count              = var.envs["prod"].enable_alb ? 1 : 0
  name               = "${var.app_name}-prod-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.instances.id]
  subnets            = aws_subnet.public[*].id
}

# 8. Auto Scaling Group for Production
resource "aws_autoscaling_group" "prod" {
  count               = var.envs["prod"].enable_alb ? 1 : 0
  name                = "${var.app_name}-prod-asg"
  min_size            = var.envs["prod"].instance_count
  max_size            = var.envs["prod"].instance_count + 2
  desired_capacity    = var.envs["prod"].instance_count
  vpc_zone_identifier = aws_subnet.public[*].id
  target_group_arns   = [aws_lb_target_group.prod[0].arn]

  launch_template {
    id      = aws_launch_template.prod[0].id
    version = "$Latest"
  }
}

# 9. RDS Database (Shared across environments)
resource "aws_db_instance" "main" {
  allocated_storage    = 20
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  db_name              = "${var.app_name}_db"
  username             = "admin"
  password             = var.db_password
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.instances.id]
  db_subnet_group_name = aws_db_subnet_group.main.name
}