# Real-Time Task Manager

A full-stack real-time task management application demonstrating **SignalR** integration for live updates across multiple clients. This project showcases real-time communication patterns between a C# ASP.NET Core Web API backend and a React TypeScript frontend.

> **Note**: This is a demonstration project focused on SignalR real-time capabilities. It does not include authentication, user management, or multi-tenancy features.

## 🌟 Features

### Real-Time Capabilities

- **Live Task Updates**: See tasks created, updated, and deleted in real-time across all connected clients
- **Real-Time Notes**: Add and modify notes with instant synchronization
- **Activity Feed**: Live activity stream showing all actions as they happen
- **SignalR Hub**: WebSocket-based communication for low-latency updates

### Core Functionality

- **Task Management**: Full CRUD operations for tasks with completion tracking
- **Notes System**: Rich note-taking capabilities linked to tasks
- **Dashboard Analytics**: Real-time statistics and metrics
- **Responsive Design**: Mobile-friendly interface built with Material-UI

### Technical Features

- **Clean Architecture**: Separated concerns with proper layering
- **Entity Framework Core**: Database operations with MySQL support
- **AutoMapper**: Object-to-object mapping
- **Global Error Handling**: Comprehensive error management
- **Health Checks**: Built-in monitoring endpoints
- **Docker Support**: Full containerization for both services
- **Swagger Documentation**: Interactive API documentation

## 🏗️ Architecture Overview

```
┌─────────────────┐    SignalR/HTTP    ┌──────────────────┐
│   React Client  │ ◄─────────────────► │   ASP.NET API    │
│   (TypeScript)  │                     │   (C# .NET 8)    │
└─────────────────┘                     └──────────────────┘
         │                                        │
         │ HTTP REST API                          │
         │                                        │
         ▼                                        ▼
┌─────────────────┐                     ┌──────────────────┐
│  Material-UI    │                     │   MySQL Database │
│   Components    │                     │   (EF Core)      │
└─────────────────┘                     └──────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- [Git](https://git-scm.com/) for version control
- [Docker & Docker Compose](https://www.docker.com/get-started) (recommended)
- OR for local development:
  - [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
  - [Node.js 18+](https://nodejs.org/)
  - [MySQL 8.0+](https://www.mysql.com/downloads/)

### Option 1: Full-Stack Docker Deployment (Recommended)

1. **Clone the repository**

   ```bash
   git clone https://github.com/d-langelihlekhumalo/real-time-task-manager.git
   cd real-time-task-manager
   ```

2. **Configure environment**

   ```bash
   cp .env.example .env
   # Edit .env with your database credentials and configuration
   ```

3. **Start the entire application**

   ```bash
   docker-compose up -d
   ```

4. **Access the application**

   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8080
   - Swagger UI: http://localhost:8080/swagger
   - Health Check: http://localhost:8080/health

5. **View logs (optional)**

   ```bash
   docker-compose logs -f
   ```

6. **Stop the application**

   ```bash
   docker-compose down
   ```

### Option 2: Local Development

1. **Backend Setup**

   ```bash
   cd backend/RealTimeTaskManager

   # Restore packages
   dotnet restore

   # Update database connection in appsettings.Development.json
   # Run the API
   dotnet run
   ```

   Backend will be available at: https://localhost:7075

2. **Frontend Setup**

   ```bash
   cd frontend/real-time-task-manager

   # Install dependencies
   npm install

   # Start development server
   npm run dev
   ```

   Frontend will be available at: http://localhost:5173

## 🔧 Configuration

### Backend Configuration

**Environment Variables:**

```bash
# Database
ConnectionStrings__DefaultConnection=Server=localhost;Database=TaskManagerDB;User=root;Password=yourpassword;

# CORS (comma-separated)
Cors__AllowedOrigins=http://localhost:3000,https://localhost:3000

# SignalR (optional - for scaling)
SignalR__RedisConnectionString=localhost:6379
```

**Key Configuration Files:**

- `appsettings.json` - Base configuration
- `appsettings.Development.json` - Development overrides
- `appsettings.Production.json` - Production settings

### Frontend Configuration

**Environment Variables:**

```bash
# API Endpoints
VITE_API_BASE_URL=https://localhost:7075/api
VITE_SIGNALR_HUB_URL=https://localhost:7075/taskManagerHub

# Development
VITE_NODE_ENV=development
```

## 📡 SignalR Integration

### Backend Hub Implementation

```csharp
public class TaskManagerHub : Hub
{
    // Real-time events sent to clients:
    // - TaskCreated(TaskCreatedMessage)
    // - TaskUpdated(TaskUpdatedMessage)
    // - TaskDeleted(TaskDeletedMessage)
    // - NoteAdded(NoteAddedMessage)
    // - NoteUpdated(NoteUpdatedMessage)
    // - NoteDeleted(NoteDeletedMessage)
    // - ActivityUpdate(ActivityResponse)
}
```

### Frontend SignalR Client

```typescript
import * as signalR from '@microsoft/signalr'

const connection = new signalR.HubConnectionBuilder()
	.withUrl('/taskManagerHub')
	.build()

// Listen for real-time updates
connection.on('TaskCreated', (task) => {
	// Update UI with new task
})

connection.on('TaskUpdated', (task) => {
	// Update existing task in UI
})
```

## 📊 API Endpoints

### Tasks

- `GET /api/Task` - Get all tasks
- `GET /api/Task/{id}` - Get specific task
- `POST /api/Task` - Create new task
- `PUT /api/Task/{id}` - Update task
- `DELETE /api/Task/{id}` - Delete task
- `PATCH /api/Task/{id}/toggle-completion` - Toggle completion

### Notes

- `GET /api/Note/task/{taskId}` - Get notes for task
- `POST /api/Note` - Create note
- `PUT /api/Note/{id}` - Update note
- `DELETE /api/Note/{id}` - Delete note

### Dashboard

- `GET /api/Dashboard` - Get statistics
- `GET /api/Dashboard/{count}` - Get recent activities

### Health & Monitoring

- `GET /health` - Health check endpoint
- `GET /swagger` - API documentation

## 🗂️ Project Structure

```
RealTimeTaskManager/
├── backend/
│   └── RealTimeTaskManager/
│       ├── Controllers/          # API controllers
│       ├── Hubs/                # SignalR hubs
│       ├── Services/            # Business logic services
│       ├── Data/                # Entity Framework context
│       ├── Entities/            # Database entities
│       ├── DTOs/                # Data transfer objects
│       ├── Models/              # Request/response models
│       ├── Configuration/       # App configuration
│       ├── Middleware/          # Custom middleware
│       └── docker-compose.yml   # Docker configuration
│
├── frontend/
│   └── real-time-task-manager/
│       ├── src/
│       │   ├── components/      # React components
│       │   ├── services/        # API services
│       │   ├── types/           # TypeScript types
│       │   └── contexts/        # React contexts
│       ├── docker-compose.yml   # Docker configuration
│       └── nginx.conf           # Production web server
│
└── README.md                    # This file
```

## 🐳 Docker Support

Both backend and frontend include comprehensive Docker support:

### Backend Docker Features

- Multi-stage builds for optimization
- MySQL database integration
- Environment-based configuration
- Health checks and monitoring
- Production-ready deployment scripts

### Frontend Docker Features

- Development and production Dockerfiles
- Nginx-based production serving
- Hot reload for development
- Optimized build pipeline

## 🧪 Testing the Real-Time Features

1. **Open Multiple Browser Windows/Tabs** pointing to the application
2. **Create a Task** in one window - watch it appear instantly in others
3. **Update Task Status** - see completion status sync across all clients
4. **Add Notes** - observe real-time note additions
5. **Check Activity Feed** - view live activity stream updates

## 🚀 Deployment

### Production Deployment Steps

1. **Prepare Environment**

   ```bash
   # Backend
   cd backend/RealTimeTaskManager
   cp .env.example .env
   # Configure production database and settings

   # Frontend
   cd frontend/real-time-task-manager
   # Update environment variables for production API endpoints
   ```

2. **Deploy Backend**

   ```bash
   cd backend/RealTimeTaskManager
   ./deploy.sh -e production
   ```

3. **Deploy Frontend**
   ```bash
   cd frontend/real-time-task-manager
   docker-compose up -d
   ```

### Environment-Specific Configurations

- **Development**: Full debugging, detailed errors, Swagger UI enabled
- **Staging**: Production-like with enhanced logging
- **Production**: Optimized performance, security headers, error logging only

## 🔍 Monitoring & Health Checks

### Backend Monitoring

- Health check endpoint: `/health`
- Structured logging with Serilog
- Database connectivity monitoring
- SignalR connection tracking

### Frontend Monitoring

- Error boundaries for crash prevention
- Performance metrics (can be extended)
- Real-time connection status

## 🛡️ Security Features

- **HTTPS Enforcement** in production
- **CORS Configuration** for allowed origins
- **Security Headers** (HSTS, X-Frame-Options, etc.)
- **Input Validation** on all API endpoints
- **SQL Injection Prevention** through EF Core parameterized queries

## 🔧 Development

### Backend Development

```bash
cd backend/RealTimeTaskManager

# Run in development mode
dotnet run

# Run tests (if available)
dotnet test

# Generate EF migrations
dotnet ef migrations add MigrationName
dotnet ef database update
```

### Frontend Development

```bash
cd frontend/real-time-task-manager

# Start development server
npm run dev

# Run linting
npm run lint

# Build for production
npm run build

# Run type checking
npm run type-check
```

## 📈 Performance Considerations

### Backend Optimizations

- **Connection Pooling**: Database connections are pooled
- **Entity Framework**: Optimized queries with proper includes
- **SignalR Scaling**: Ready for Redis backplane for multiple instances
- **Async/Await**: All operations are asynchronous

### Frontend Optimizations

- **Vite Build Tool**: Fast development and optimized production builds
- **Code Splitting**: Ready for route-based code splitting
- **Efficient Re-renders**: Proper React patterns to minimize re-renders
- **Bundle Analysis**: Tools available for bundle size monitoring

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Test thoroughly (both services)
5. Commit your changes: `git commit -m 'Add amazing feature'`
6. Push to the branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **SignalR Team** for the excellent real-time communication framework
- **React Team** for the robust frontend framework
- **Material-UI** for the beautiful component library
- **Entity Framework Core** for the powerful ORM

## 📞 Support & Questions

- **Issues**: Create an issue in this repository
- **Documentation**: Check the individual README files in backend/ and frontend/ directories
- **API Documentation**: Available at `/swagger` when running the backend

---

**Built with ❤️ to demonstrate real-time web application capabilities using SignalR**
