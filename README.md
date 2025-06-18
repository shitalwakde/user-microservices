#Key Features:
#Multi-environment setup:
Dev: 1x t2.micro
UAT: 1x t2.small
Prod: 3x t2.medium behind ALB

#Smart defaults:

hcl
default = {
  dev = { instance_count = 1 },
  prod = { instance_count = 3 }
}

#Safety controls:
Prod has auto-scaling (min 3, max 5)
ALB only for prod
SSH open (restrict this in production!)

#Shared resources:
Single VPC for all environments
Common security group
Shared RDS database

#How to Deploy:

#Initialize:
terraform init

#Plan (see what will be created):
terraform plan -var="ssh_key_name=your-key" -var="db_password=yourPassword123"

#Apply:
terraform apply -var="ssh_key_name=your-key" -var="db_password=yourPassword123"

#Destroy (when done):
terraform destroy

#Outputs You'll Get:
Environment	Resource	Access Method
Dev	EC2	ssh ubuntu@<dev_ip>
UAT	EC2	ssh ubuntu@<uat_ip>
Prod	ALB	http://<alb_dns>
This gives you a complete 3-tier environment with proper isolation between Dev/UAT/Prod!
