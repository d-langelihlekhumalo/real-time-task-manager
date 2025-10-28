#!/bin/bash

# Quick deployment script
# Run this on your server after setting up Docker

set -e

echo "🚀 Deploying Real-Time Task Manager..."

# Pull latest code
git pull origin main

# Copy environment file
cp .env.production .env

# Build and start services
docker-compose -f docker-compose.coolify.yml up -d --build

echo "✅ Deployment complete!"
echo "🌐 Application should be available at your configured domain"
echo "📊 Check status: docker-compose ps"
echo "📋 View logs: docker-compose logs -f"