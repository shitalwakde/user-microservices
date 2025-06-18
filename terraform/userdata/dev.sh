#!/bin/bash
apt-get update -y
apt-get install -y nodejs npm git
npm install -g pm2

git clone https://github.com/shitalwakde/user-microservice.git /home/ubuntu/user-microservice
cd /home/ubuntu/user-microservice
npm install

# Load environment variables from SSM
export NODE_ENV=dev
aws ssm get-parameters-by-path --path "/dev/user-service/" --with-decryption --region us-east-1 | jq -r '.Parameters[] | "export \(.Name | split("/") | last | ascii_upcase)=\(.Value)"' >> /home/ubuntu/.env

source /home/ubuntu/.env
pm2 start ecosystem.config.js --env dev
pm2 save
pm2 startup