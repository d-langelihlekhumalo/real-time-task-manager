#!/bin/bash

# Script to create a backend-only deployment
# Run this if you want to deploy backend separately

echo "🚀 Creating backend-only deployment structure..."

# Create backend-only directory
mkdir -p backend-only
cd backend-only

# Copy backend files
cp -r ../backend/RealTimeTaskManager/* .

# Create simple docker-compose for backend
cat > docker-compose.yml << 'EOF'
version: "3.8"

services:
  backend:
    build: .
    ports:
      - "5000:5000"
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ASPNETCORE_URLS=http://+:5000
      - ConnectionStrings__DefaultConnection=${DATABASE_URL}
      - Cors__AllowedOrigins=*
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
EOF

echo "✅ Backend-only structure created in ./backend-only/"
echo "📋 Next steps:"
echo "1. Update your ConnectionString environment variable"
echo "2. Deploy using: docker-compose up -d"