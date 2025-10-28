# Docker Setup for Real-Time Task Management App

This directory contains Docker configuration files for running the React frontend application in containerized environments.

## Files Overview

- `Dockerfile` - Production-ready multi-stage build
- `Dockerfile.dev` - Development environment setup
- `docker-compose.yml` - Production deployment
- `docker-compose.dev.yml` - Development with hot reload
- `nginx.conf` - Nginx configuration for production
- `.dockerignore` - Files to exclude from Docker context

## Production Deployment

### Build and Run with Docker

```bash
# Build the production image
docker build -t task-manager-frontend .

# Run the container
docker run -p 3000:80 task-manager-frontend
```

### Using Docker Compose (Recommended)

```bash
# Build and start the application
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the application
docker-compose down
```

The application will be available at `http://localhost:3000`

## Development Environment

### Using Development Docker Setup

```bash
# Build and start development environment
docker-compose -f docker-compose.dev.yml up -d

# View logs
docker-compose -f docker-compose.dev.yml logs -f

# Stop development environment
docker-compose -f docker-compose.dev.yml down
```

The development server will be available at `http://localhost:5173` with hot reload enabled.

## Configuration

### Environment Variables

The application supports the following environment variables:

- `NODE_ENV` - Set to `production` or `development`
- `VITE_API_BASE_URL` - Backend API base URL (if different from default)

### Backend Configuration

Update the `nginx.conf` file to change the backend API endpoint:

```nginx
location /api/ {
    proxy_pass https://your-backend-server:port/api/;
    # ... other proxy settings
}
```

### SSL/HTTPS Configuration

For HTTPS deployment, update the nginx configuration to include SSL certificates:

```nginx
server {
    listen 443 ssl;
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    # ... rest of configuration
}
```

## Health Checks

Both production and development containers include health checks:

- **Production**: Checks nginx on port 80
- **Development**: Checks Vite dev server on port 5173

## Volumes (Development)

The development setup uses volumes for hot reload:

```yaml
volumes:
  - .:/app # Mount source code
  - /app/node_modules # Preserve node_modules
```

## Troubleshooting

### Build Issues

If you encounter build issues:

```bash
# Clear Docker cache
docker builder prune -a

# Rebuild without cache
docker build --no-cache -t task-manager-frontend .
```

### Permission Issues

On Linux/macOS, ensure proper permissions:

```bash
# Fix ownership if needed
sudo chown -R $USER:$USER .
```

### Node.js Version

The Docker images use Node.js 20 Alpine. If you need a different version, update the `FROM` directive in the Dockerfiles.

## Production Considerations

1. **Reverse Proxy**: Consider using a reverse proxy like Traefik or additional nginx instance for SSL termination
2. **Environment Variables**: Use Docker secrets or external configuration for sensitive data
3. **Logging**: Configure log aggregation for production monitoring
4. **Resources**: Set appropriate memory and CPU limits in production

```yaml
services:
  frontend:
    # ... other configuration
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
```
