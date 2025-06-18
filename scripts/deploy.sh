#!/bin/bash

# Navigate to project directory
cd /home/ubuntu/user-microservice

# Install dependencies (if not already present)
npm install

# Load environment variables (if using .env)
export NODE_ENV=production

# Start the application
pm2 start npm --name "user-service" -- start
# Alternative: pm2 start src/server.js

# Save PM2 process list
pm2 save

# Ensure PM2 starts on system reboot
pm2 startup