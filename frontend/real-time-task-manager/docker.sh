#!/bin/bash

# Docker management script for Real-Time Task Management App

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="task-manager-frontend"
CONTAINER_NAME="task-manager-frontend-container"
PROD_PORT="3000"
DEV_PORT="5173"

# Functions
print_usage() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  build-prod     Build production Docker image"
    echo "  build-dev      Build development Docker image"
    echo "  run-prod       Run production container"
    echo "  run-dev        Run development container"
    echo "  start          Start with docker-compose (production)"
    echo "  start-dev      Start with docker-compose (development)"
    echo "  stop           Stop all containers"
    echo "  logs           Show logs"
    echo "  clean          Remove containers and images"
    echo "  health         Check container health"
    echo "  shell          Access container shell"
    echo ""
}

build_prod() {
    echo -e "${GREEN}Building production Docker image...${NC}"
    docker build -t $IMAGE_NAME .
    echo -e "${GREEN}Production image built successfully!${NC}"
}

build_dev() {
    echo -e "${GREEN}Building development Docker image...${NC}"
    docker build -f Dockerfile.dev -t $IMAGE_NAME-dev .
    echo -e "${GREEN}Development image built successfully!${NC}"
}

run_prod() {
    echo -e "${GREEN}Running production container...${NC}"
    docker run -d \
        --name $CONTAINER_NAME \
        -p $PROD_PORT:80 \
        --restart unless-stopped \
        $IMAGE_NAME
    echo -e "${GREEN}Production container started on port $PROD_PORT${NC}"
}

run_dev() {
    echo -e "${GREEN}Running development container...${NC}"
    docker run -d \
        --name $CONTAINER_NAME-dev \
        -p $DEV_PORT:5173 \
        -v $(pwd):/app \
        -v /app/node_modules \
        --restart unless-stopped \
        $IMAGE_NAME-dev
    echo -e "${GREEN}Development container started on port $DEV_PORT${NC}"
}

start_compose() {
    echo -e "${GREEN}Starting with docker-compose (production)...${NC}"
    docker-compose up -d
    echo -e "${GREEN}Application started on port $PROD_PORT${NC}"
}

start_compose_dev() {
    echo -e "${GREEN}Starting with docker-compose (development)...${NC}"
    docker-compose -f docker-compose.dev.yml up -d
    echo -e "${GREEN}Development server started on port $DEV_PORT${NC}"
}

stop_containers() {
    echo -e "${YELLOW}Stopping containers...${NC}"
    docker-compose down 2>/dev/null || true
    docker-compose -f docker-compose.dev.yml down 2>/dev/null || true
    docker stop $CONTAINER_NAME 2>/dev/null || true
    docker stop $CONTAINER_NAME-dev 2>/dev/null || true
    echo -e "${GREEN}Containers stopped${NC}"
}

show_logs() {
    echo -e "${GREEN}Showing logs...${NC}"
    if docker ps | grep -q $CONTAINER_NAME; then
        docker logs -f $CONTAINER_NAME
    elif docker-compose ps | grep -q "frontend"; then
        docker-compose logs -f
    else
        echo -e "${RED}No running containers found${NC}"
    fi
}

clean_all() {
    echo -e "${YELLOW}Cleaning up containers and images...${NC}"
    stop_containers
    docker rm $CONTAINER_NAME 2>/dev/null || true
    docker rm $CONTAINER_NAME-dev 2>/dev/null || true
    docker rmi $IMAGE_NAME 2>/dev/null || true
    docker rmi $IMAGE_NAME-dev 2>/dev/null || true
    docker builder prune -f
    echo -e "${GREEN}Cleanup completed${NC}"
}

check_health() {
    echo -e "${GREEN}Checking container health...${NC}"
    if docker ps | grep -q $CONTAINER_NAME; then
        docker exec $CONTAINER_NAME curl -f http://localhost:80/ || echo -e "${RED}Health check failed${NC}"
    else
        echo -e "${YELLOW}No production container running${NC}"
    fi
}

access_shell() {
    echo -e "${GREEN}Accessing container shell...${NC}"
    if docker ps | grep -q $CONTAINER_NAME; then
        docker exec -it $CONTAINER_NAME sh
    elif docker ps | grep -q $CONTAINER_NAME-dev; then
        docker exec -it $CONTAINER_NAME-dev sh
    else
        echo -e "${RED}No running containers found${NC}"
    fi
}

# Main script
case "${1}" in
    build-prod)
        build_prod
        ;;
    build-dev)
        build_dev
        ;;
    run-prod)
        run_prod
        ;;
    run-dev)
        run_dev
        ;;
    start)
        start_compose
        ;;
    start-dev)
        start_compose_dev
        ;;
    stop)
        stop_containers
        ;;
    logs)
        show_logs
        ;;
    clean)
        clean_all
        ;;
    health)
        check_health
        ;;
    shell)
        access_shell
        ;;
    *)
        print_usage
        exit 1
        ;;
esac