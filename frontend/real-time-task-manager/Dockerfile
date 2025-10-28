# Multi-stage build for React application
# Stage 1: Build the application
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --production=false

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Stage 2: Serve the application with nginx
FROM nginx:alpine

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy built application from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Install curl for healthcheck
RUN apk add --no-cache curl

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:80/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]