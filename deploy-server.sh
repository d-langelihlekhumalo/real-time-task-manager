#!/bin/bash

# Server deployment script for Real-Time Task Manager
# Run this on your Ubuntu/Debian server

set -e

echo "🚀 Installing Docker and Docker Compose..."

# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create application directory
sudo mkdir -p /opt/taskmanager
sudo chown $USER:$USER /opt/taskmanager
cd /opt/taskmanager

# Clone your repository
git clone https://github.com/d-langelihlekhumalo/real-time-task-manager.git .

echo "✅ Server setup complete!"
echo "Next steps:"
echo "1. Configure your .env file"
echo "2. Run: docker-compose up -d"