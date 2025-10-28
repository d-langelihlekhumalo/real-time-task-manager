# SignalR Integration Documentation

## Overview

This document outlines the SignalR integration implemented for the Real-Time Task Manager application.

## SignalR Hub Endpoint

- **URL**: `/taskManagerHub`
- **Hub Class**: `TaskManagerHub`

## Client-Side Event Listeners

Connect to the SignalR hub and listen for the following events:

### Task Events

1. **TaskCreated** - Triggered when a new task is created

   ```javascript
   connection.on('TaskCreated', (message) => {
   	// message: TaskCreatedMessage
   	// Properties: Id, Title, Description, CreatedAt
   })
   ```

2. **TaskUpdated** - Triggered when a task is updated (excluding completion changes)

   ```javascript
   connection.on('TaskUpdated', (message) => {
   	// message: TaskUpdatedMessage
   	// Properties: Id, Title, Description, IsCompleted, UpdatedAt
   })
   ```

3. **TaskDeleted** - Triggered when a task is deleted

   ```javascript
   connection.on('TaskDeleted', (message) => {
   	// message: TaskDeletedMessage
   	// Properties: TaskId
   })
   ```

4. **TaskCompletionChanged** - Triggered when task completion status changes
   ```javascript
   connection.on('TaskCompletionChanged', (message) => {
   	// message: TaskCompletionChangedMessage
   	// Properties: Id, Title, IsCompleted, UpdatedAt
   })
   ```

### Note Events

5. **NoteAdded** - Triggered when a new note is added to a task

   ```javascript
   connection.on('NoteAdded', (message) => {
   	// message: NoteAddedMessage
   	// Properties: Id, TaskId, Content, CreatedAt
   })
   ```

6. **NoteUpdated** - Triggered when a note is updated

   ```javascript
   connection.on('NoteUpdated', (message) => {
   	// message: NoteUpdatedMessage
   	// Properties: Id, TaskId, Content, UpdatedAt
   })
   ```

7. **NoteDeleted** - Triggered when a note is deleted
   ```javascript
   connection.on('NoteDeleted', (message) => {
   	// message: NoteDeletedMessage
   	// Properties: Id, TaskId
   })
   ```

### Activity Feed Events

8. **ActivityUpdate** - Triggered for real-time activity feed updates
   ```javascript
   connection.on('ActivityUpdate', (activity) => {
   	// activity: ActivityResponse
   	// Properties: Id, Action, EntityType, EntityId, EntityTitle, Description, CreatedAt, ActionDisplayName
   })
   ```

## API Endpoints that Trigger SignalR Events

### Task Endpoints

- `POST /api/Task` → Triggers `TaskCreated`
- `PUT /api/Task/{id}` → Triggers `TaskUpdated` or `TaskCompletionChanged`
- `DELETE /api/Task/{id}` → Triggers `TaskDeleted`
- `PATCH /api/Task/{id}/toggle-completion` → Triggers `TaskCompletionChanged`

### Note Endpoints

- `POST /api/Note` → Triggers `NoteAdded`
- `PUT /api/Note/{id}` → Triggers `NoteUpdated`
- `DELETE /api/Note/{id}` → Triggers `NoteDeleted`

## Implementation Details

### Backend Architecture

- **Hub**: `TaskManagerHub` - Handles client connections and disconnections
- **Service Interface**: `ITaskManagerHubService` - Defines SignalR notification methods
- **Service Implementation**: `TaskManagerHubService` - Implements SignalR notifications using `IHubContext<TaskManagerHub>`
- **Integration**: Services (`TaskService`, `NoteService`) call hub service methods after database operations

### Message Models

- `TaskCreatedMessage`
- `TaskUpdatedMessage`
- `TaskDeletedMessage`
- `TaskCompletionChangedMessage`
- `NoteAddedMessage`
- `NoteUpdatedMessage`
- `NoteDeletedMessage`

### Error Handling

- All SignalR operations are wrapped in try-catch blocks
- Errors are logged but don't affect the main business logic
- Application continues to function even if SignalR fails

### Logging

- Connection/disconnection events are logged
- SignalR notification events are logged with relevant information
- Errors in SignalR operations are logged with full exception details

## Client-Side Connection Example (JavaScript)

```javascript
// Establish connection
const connection = new signalR.HubConnectionBuilder()
	.withUrl('/taskManagerHub')
	.build()

// Start connection
connection
	.start()
	.then(function () {
		console.log('Connected to TaskManager SignalR Hub')
	})
	.catch(function (err) {
		console.error('Error connecting to SignalR Hub: ', err.toString())
	})

// Listen for events
connection.on('TaskCreated', (message) => {
	console.log('New task created:', message)
	// Update UI accordingly
})

connection.on('TaskUpdated', (message) => {
	console.log('Task updated:', message)
	// Update UI accordingly
})

// ... additional event listeners
```

## Benefits

1. **Real-time Updates**: All connected clients receive immediate updates
2. **Improved UX**: Users see changes instantly without page refresh
3. **Activity Monitoring**: Real-time activity feed for better collaboration
4. **Scalable**: Supports multiple concurrent users
5. **Reliable**: Graceful error handling ensures app stability
