# Real Time Task Manager - Deployment Guide

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose installed
- .NET 8.0 SDK (for development)
- Git

### Environment Setup

1. **Clone and Navigate**

   ```bash
   git clone <your-repo-url>
   cd real-time-task-manager
   ```

2. **Configure Environment**

   ```bash
   cp .env.example .env
   # Edit .env with your actual database credentials
   ```

3. **Deploy**

   ```bash
   # Linux/Mac
   chmod +x deploy.sh
   ./deploy.sh

   # Windows
   deploy.bat
   ```

## 📋 Available Endpoints

Once deployed, your API will be available at:

- **API Base URL**: `http://localhost:8080`
- **Health Check**: `http://localhost:8080/health`
- **Swagger UI**: `http://localhost:8080/swagger` (dev/staging only)
- **SignalR Hub**: `ws://localhost:8080/taskManagerHub`

### API Endpoints

#### Tasks

- `GET /api/task` - Get all tasks
- `GET /api/task/{id}` - Get task by ID
- `POST /api/task` - Create new task
- `PUT /api/task/{id}` - Update task
- `DELETE /api/task/{id}` - Delete task
- `PATCH /api/task/{id}/toggle-completion` - Toggle task completion

#### Notes

- `GET /api/note/task/{taskId}` - Get notes for a task
- `GET /api/note/{id}` - Get note by ID
- `POST /api/note` - Create new note
- `PUT /api/note/{id}` - Update note
- `DELETE /api/note/{id}` - Delete note

#### Dashboard

- `GET /api/dashboard` - Get dashboard statistics

#### Health

- `GET /health` - API health status

## 🔧 Configuration

### Environment Variables

Required environment variables (set in `.env` file):

```bash
# Database Configuration
MYSQL_ROOT_PASSWORD=YourSecureRootPassword123!
MYSQL_DATABASE=RealTimeTaskManagerDB
MYSQL_USER=taskmanager
MYSQL_PASSWORD=YourSecurePassword123!

# Application Environment
ASPNETCORE_ENVIRONMENT=Production
```

### CORS Configuration

Configure allowed origins in `appsettings.json`:

```json
{
	"Cors": {
		"AllowedOrigins": ["https://yourdomain.com", "https://www.yourdomain.com"],
		"AllowCredentials": true
	}
}
```

## 🏗️ Deployment Options

### Option 1: Docker Compose (Recommended)

```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Option 2: Manual Deployment

1. **Build the application**

   ```bash
   dotnet publish -c Release -o ./publish
   ```

2. **Set up MySQL database separately**

3. **Configure connection string**

   ```bash
   export ConnectionStrings__DefaultConnection="Server=your-mysql-server;Port=3306;Database=RealTimeTaskManagerDB;Uid=your-user;Pwd=your-password;"
   ```

4. **Run the application**
   ```bash
   cd publish
   dotnet RealTimeTaskManager.dll
   ```

## 🔍 Monitoring & Health Checks

### Health Check Endpoint

The `/health` endpoint provides detailed health information:

```json
{
	"status": "Healthy",
	"checks": [
		{
			"name": "ApplicationDbContext",
			"status": "Healthy",
			"duration": "00:00:00.0234567"
		},
		{
			"name": "mysql",
			"status": "Healthy",
			"duration": "00:00:00.0123456"
		}
	]
}
```

### Logging

Logs are written to:

- Console (structured JSON in production)
- Files in `logs/` directory (if configured)

## 🔒 Security Features

### Implemented Security Measures

- ✅ CORS configuration
- ✅ Security headers (X-Frame-Options, X-Content-Type-Options, etc.)
- ✅ HTTPS redirection
- ✅ Global exception handling
- ✅ Input validation
- ✅ Connection string environment variables
- ✅ Non-root Docker user

### Production Security Checklist

- [ ] Configure proper CORS origins (remove wildcard)
- [ ] Set up HTTPS with valid SSL certificates
- [ ] Implement authentication/authorization
- [ ] Set up rate limiting
- [ ] Configure database firewall rules
- [ ] Enable database SSL/TLS
- [ ] Set up monitoring and alerting
- [ ] Regular security updates

## 🚨 Troubleshooting

### Common Issues

1. **Database Connection Failed**

   ```bash
   # Check if MySQL is running
   docker-compose ps

   # Check database logs
   docker-compose logs mysql

   # Verify connection string
   echo $ConnectionStrings__DefaultConnection
   ```

2. **Port Already in Use**

   ```bash
   # Check what's using port 8080
   netstat -tulpn | grep 8080

   # Kill process or change port in docker-compose.yml
   ```

3. **Permission Denied (Linux)**
   ```bash
   # Make deploy script executable
   chmod +x deploy.sh
   ```

### Logs and Debugging

```bash
# View all logs
docker-compose logs

# View specific service logs
docker-compose logs api
docker-compose logs mysql

# Follow logs in real-time
docker-compose logs -f
```

## 📊 Performance Considerations

### Database Optimization

- Connection pooling is enabled
- Entity Framework retry logic configured
- Proper indexing on frequently queried fields

### Caching (Future Enhancement)

Consider adding Redis for:

- Session storage
- Response caching
- SignalR backplane (for multiple instances)

## 🔄 CI/CD Integration

### GitHub Actions Example

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Docker
        uses: docker/setup-docker@v2

      - name: Deploy
        run: |
          echo "MYSQL_ROOT_PASSWORD=${{ secrets.MYSQL_ROOT_PASSWORD }}" > .env
          echo "MYSQL_PASSWORD=${{ secrets.MYSQL_PASSWORD }}" >> .env
          ./deploy.sh -e production
```

## 📝 Development

### Running in Development

```bash
# Set development environment
export ASPNETCORE_ENVIRONMENT=Development

# Run with hot reload
dotnet watch run
```

### Database Migrations

```bash
# Add migration
dotnet ef migrations add MigrationName

# Update database
dotnet ef database update
```

---

For more information or support, please check the API documentation at `/swagger` when running in development mode.
