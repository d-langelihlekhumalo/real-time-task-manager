# Real-Time Task Management App - Frontend

A modern, responsive task management application built with React, TypeScript, and Material-UI. This frontend client provides an intuitive interface for managing tasks and notes in real-time.

## 🚀 Features

- **Dashboard Overview**: Get a quick summary of your tasks and recent activity
- **Task Management**: Create, edit, delete, and mark tasks as complete
- **Notes System**: Add detailed notes to tasks for better organization
- **Responsive Design**: Fully responsive interface that works on desktop and mobile
- **Real-time Updates**: Seamless synchronization with the backend API
- **Material Design**: Modern UI using Material-UI components
- **Toast Notifications**: User-friendly feedback for all actions
- **Error Handling**: Comprehensive error boundaries and user feedback

## 🛠 Technology Stack

- **React 19.1.1** - Modern React with hooks and functional components
- **TypeScript 5.9** - Type-safe development
- **Vite 7.1** - Fast build tool and development server
- **Material-UI 7.3** - React component library with Material Design
- **Axios 1.12** - HTTP client for API communication
- **Emotion** - CSS-in-JS styling solution

## 📋 Prerequisites

Before running this application, make sure you have:

- Node.js (version 18 or higher)
- npm or yarn package manager
- A running backend API server (see backend repository)

## 🚀 Getting Started

### Installation

1. Clone the repository:

```bash
git clone <repository-url>
cd real-time-task-management-app
```

2. Install dependencies:

```bash
npm install
```

3. Configure the environment:
   - Copy `.env.example` to `.env.development` for development settings
   - Update `VITE_API_BASE_URL` if your backend runs on a different URL
   - Default configuration expects backend running on `https://localhost:44355`

### Development

Start the development server:

```bash
npm run dev
```

The application will be available at `http://localhost:5173`

### Building for Production

Build the application:

```bash
npm run build
```

Preview the production build:

```bash
npm run preview
```

## 📁 Project Structure

```
src/
├── components/          # React components
│   ├── Dashboard.tsx   # Dashboard overview component
│   ├── Tasks.tsx       # Task management component
│   ├── Notes.tsx       # Notes management component
│   └── ErrorBoundary.tsx # Error boundary wrapper
├── contexts/           # React contexts
│   └── ToastContext.tsx # Toast notification provider
├── services/          # API service layer
│   └── api.ts         # Axios configuration and API calls
├── types/             # TypeScript type definitions
│   └── index.ts       # Task and Note interfaces
├── utils/             # Utility functions
├── styles/            # CSS and styling files
├── assets/            # Static assets
├── App.tsx            # Main application component
└── main.tsx          # Application entry point
```

## 🎯 Key Components

### Dashboard

- Overview of task statistics
- Recent task activity
- Quick navigation to tasks and notes

### Tasks

- Full CRUD operations for tasks
- Task filtering and pagination
- Completion status management
- Associated notes display

### Notes

- Create and manage notes linked to tasks
- Rich text support
- Task association management

## ⚙️ Configuration

### Environment Variables

The application uses environment variables for configuration. Available variables:

- `VITE_API_BASE_URL` - Backend API base URL (default: https://localhost:44355/api)
- `VITE_SIGNALR_HUB_URL` - SignalR hub URL for real-time updates (default: https://localhost:44355/taskManagerHub)

### Environment Files

- `.env.example` - Template with all available variables
- `.env.development` - Development environment settings
- `.env.production` - Production environment settings

Copy `.env.example` to `.env.development` and update the values as needed.

## 🔧 Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint

## 🌐 API Integration

The application communicates with a REST API backend. Key endpoints:

### Task Management

- `GET /api/Task` - Fetch all tasks
- `GET /api/Task/{id}` - Get specific task
- `POST /api/Task` - Create new task
- `PUT /api/Task/{id}` - Update task
- `DELETE /api/Task/{id}` - Delete task
- `PATCH /api/Task/{id}/toggle-completion` - Toggle task completion

### Note Management

- `GET /api/Note/task/{taskId}` - Get notes for a task
- `GET /api/Note/{id}` - Get specific note
- `POST /api/Note` - Create new note
- `PUT /api/Note/{id}` - Update note
- `DELETE /api/Note/{id}` - Delete note

### Dashboard

- `GET /api/Dashboard` - Get dashboard statistics
- `GET /api/Dashboard/{count}` - Get recent activities

## 🎨 Styling

The application uses Material-UI's theming system and Emotion for styling:

- Consistent Material Design principles
- Responsive breakpoints
- Dark/light theme ready (can be extended)
- Custom component styling with Emotion

## 🔒 Error Handling

- Error boundaries prevent application crashes
- Toast notifications for user feedback
- API error handling with user-friendly messages
- Loading states for better UX

## 🚀 Performance Considerations

- Optimized bundle with Vite
- Code splitting ready
- Efficient re-renders with proper React patterns
- Lazy loading capabilities

## 📱 Responsive Design

The application is fully responsive and works on:

- Desktop computers
- Tablets
- Mobile devices

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🔗 Related Projects

- Backend API Repository: [Link to backend repository]
- Documentation: [Link to project documentation]

## 📞 Support

For support and questions:

- Create an issue in the repository
- Contact the development team
- Check the documentation
