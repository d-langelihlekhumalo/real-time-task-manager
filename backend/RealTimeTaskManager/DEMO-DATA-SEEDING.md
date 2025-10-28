# Demo Data Seeding Guide

## Overview

The Real-Time Task Manager now includes automatic demo data seeding to provide a better demonstration experience. The system automatically populates the database with sample tasks and notes when the application starts up if the database is empty.

## Features

### Automatic Seeding on Startup

- When the application starts, it automatically checks if the database is empty
- If empty, it seeds the database with 6 sample tasks and 5 sample notes
- Demo data is designed to showcase SignalR real-time functionality

### Manual Demo Management

Three new API endpoints are available for managing demo data:

## API Endpoints

### 1. Get Demo Information

```
GET /api/demo/info
```

Returns information about the demo, including features and instructions.

**Response:**

```json
{
	"purpose": "SignalR Real-Time Task Management Demo",
	"features": [
		"Real-time task creation and updates",
		"Live note collaboration",
		"Instant dashboard statistics",
		"Multi-client synchronization",
		"Activity feed updates"
	],
	"instructions": [
		"Open multiple browser tabs to see real-time updates",
		"Create tasks and notes in one tab, watch them appear in others",
		"Toggle task completion to see dashboard statistics update",
		"Check the dashboard for live activity feed",
		"Use /api/demo/reset to clear data and start fresh"
	]
}
```

### 2. Seed Demo Data

```
POST /api/demo/seed
```

Manually seeds the database with demo data (only if database is currently empty).

**Response:**

```json
{
	"message": "Demo data seeded successfully"
}
```

### 3. Reset Demo Data

```
POST /api/demo/reset
```

Clears all existing data and reseeds with fresh demo data. Perfect for resetting between demonstrations.

**Response:**

```json
{
	"message": "Demo data reset successfully"
}
```

## Demo Data Content

### Sample Tasks (6 total)

1. **Welcome to SignalR Demo** - Introduction task explaining the demo
2. **Test Real-Time Collaboration** - Instructions for multi-tab testing
3. **Add Notes to Tasks** - Demonstrates note functionality
4. **Toggle Task Completion** - Shows completion status updates (pre-completed)
5. **Monitor Activity Feed** - Highlights dashboard features
6. **Create Your Own Task** - Encourages user interaction

### Sample Notes (5 total)

- 2 notes attached to the "Welcome" task
- 3 notes attached to the "Add Notes to Tasks" task
- Notes include instructions and tips for demo users

## Usage Scenarios

### For Live Demonstrations

1. **Fresh Demo**: Use `POST /api/demo/reset` to start with clean demo data
2. **Multi-Tab Demo**: Open multiple browser tabs to show real-time updates
3. **Interactive Demo**: Let users create their own tasks/notes while demo data provides context

### For Development/Testing

1. **First Run**: Demo data automatically seeds on startup
2. **Clean Slate**: Use reset endpoint to clear test data
3. **Consistent State**: Always have predictable demo data available

## Implementation Details

### DataSeedingService

- **Interface**: `IDataSeedingService`
- **Implementation**: `DataSeedingService`
- **Registration**: Automatically registered in DI container
- **Logging**: Comprehensive logging for all seeding operations

### Safety Features

- Only seeds if database is empty (prevents accidental overwrites)
- Proper error handling and logging
- Transactional operations to ensure data consistency
- Time-based creation dates for realistic demo data

### Demo Data Timestamps

- Tasks created at realistic intervals (5-30 minutes ago)
- Notes added after their parent tasks
- Completed task shows state change timing
- All timestamps use UTC for consistency

## Benefits for SignalR Demo

1. **Immediate Value**: Users see functionality without having to create data
2. **Real-Time Context**: Pre-existing data makes real-time updates more obvious
3. **Multi-Client Testing**: Multiple users can interact with shared demo data
4. **Reset Capability**: Easy to start fresh for new demonstrations
5. **Professional Appearance**: Polished demo experience with meaningful sample content

## Technical Notes

- Seeding runs during application startup after database creation
- All demo data uses proper entity relationships
- GUIDs are generated for realistic primary keys
- Creation times are offset to show chronological order
- Service integrates with existing logging and error handling systems
