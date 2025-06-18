#!/bin/bash
apt-get update -y
apt-get install -y nodejs npm git
npm install -g pm2

git clone https://github.com/shitalwakde/user-microservice.git /home/ubuntu/user-microservice
cd /home/ubuntu/user-microservice
npm install --production

export NODE_ENV=prod
aws ssm get-parameters-by-path --path "/prod/user-service/" --with-decryption --region us-east-1 | jq -r '.Parameters[] | "export \(.Name | split("/") | last | ascii_upcase)=\(.Value)"' >> /home/ubuntu/.env

source /home/ubuntu/.env
pm2 start ecosystem.config.js --env prod
pm2 save
pm2 startup