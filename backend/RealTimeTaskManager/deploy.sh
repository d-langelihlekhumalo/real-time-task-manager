#!/bin/bash

# Real Time Task Manager - Deployment Script
# This script helps deploy the application in different environments

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Default values
ENVIRONMENT="production"
BUILD_ONLY=false
SKIP_TESTS=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -b|--build-only)
            BUILD_ONLY=true
            shift
            ;;
        -s|--skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  -e, --environment    Set environment (development, staging, production)"
            echo "  -b, --build-only     Only build, don't run containers"
            echo "  -s, --skip-tests     Skip running tests"
            echo "  -h, --help          Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

print_status "Starting deployment for environment: $ENVIRONMENT"

# Check if .env file exists
if [[ ! -f .env ]]; then
    if [[ -f .env.example ]]; then
        print_warning ".env file not found. Copying from .env.example"
        cp .env.example .env
        print_warning "Please edit .env file with your actual configuration values"
    else
        print_error ".env file not found and no .env.example available"
        exit 1
    fi
fi

# Load environment variables
if [[ -f .env ]]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

# Validate required environment variables
required_vars=("MYSQL_ROOT_PASSWORD" "MYSQL_DATABASE" "MYSQL_USER" "MYSQL_PASSWORD")
for var in "${required_vars[@]}"; do
    if [[ -z "${!var}" ]]; then
        print_error "Required environment variable $var is not set"
        exit 1
    fi
done

# Run tests unless skipped
if [[ "$SKIP_TESTS" != true ]]; then
    print_status "Running tests..."
    if command -v dotnet &> /dev/null; then
        dotnet test --no-restore --verbosity minimal
        if [[ $? -ne 0 ]]; then
            print_error "Tests failed. Deployment aborted."
            exit 1
        fi
        print_status "All tests passed!"
    else
        print_warning "dotnet CLI not found. Skipping tests."
    fi
fi

# Build the application
print_status "Building Docker images..."
docker-compose build

if [[ $? -ne 0 ]]; then
    print_error "Docker build failed"
    exit 1
fi

print_status "Docker images built successfully"

# If build-only flag is set, exit here
if [[ "$BUILD_ONLY" == true ]]; then
    print_status "Build completed successfully. Exiting (build-only mode)"
    exit 0
fi

# Stop existing containers
print_status "Stopping existing containers..."
docker-compose down

# Start the services
print_status "Starting services..."
docker-compose up -d

if [[ $? -ne 0 ]]; then
    print_error "Failed to start services"
    exit 1
fi

# Wait for services to be healthy
print_status "Waiting for services to be healthy..."
sleep 10

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    print_status "Services started successfully!"
    print_status "API available at: http://localhost:8080"
    print_status "Health check: http://localhost:8080/health"
    print_status "Swagger UI: http://localhost:8080/swagger"
    
    # Show running containers
    print_status "Running containers:"
    docker-compose ps
else
    print_error "Services failed to start properly"
    print_error "Check logs with: docker-compose logs"
    exit 1
fi

print_status "Deployment completed successfully!"