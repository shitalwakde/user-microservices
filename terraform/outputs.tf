output "dev_ec2_ip" {
  value = aws_instance.dev.public_ip
}

output "uat_ec2_ip" {
  value = aws_instance.uat.public_ip
}

output "prod_alb_dns" {
  value = aws_lb.prod.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "ssh_commands" {
  value = {
    dev = "ssh -i your-key.pem ubuntu@${aws_instance.dev.public_ip}",
    uat = "ssh -i your-key.pem ubuntu@${aws_instance.uat.public_ip}"
  }
}