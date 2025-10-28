using RealTimeTaskManager.Data;
using RealTimeTaskManager.Entities;

namespace RealTimeTaskManager.Services
{
    public class DataSeedingService : IDataSeedingService
    {
        private readonly ApplicationDbContext _dbContext;
        private readonly ILogger<DataSeedingService> _logger;

        public DataSeedingService(ApplicationDbContext dbContext, ILogger<DataSeedingService> logger)
        {
            _dbContext = dbContext;
            _logger = logger;
        }

        public async Task SeedDemoDataAsync()
        {
            try
            {
                // Only seed if database is empty
                if (_dbContext.Tasks.Any())
                {
                    _logger.LogInformation("Database already contains data, skipping seeding");
                    return;
                }

                _logger.LogInformation("Seeding demo data...");

                var demoTasks = CreateDemoTasks();
                await _dbContext.Tasks.AddRangeAsync(demoTasks);
                await _dbContext.SaveChangesAsync();

                // Add notes to some tasks
                var demoNotes = CreateDemoNotes(demoTasks);
                await _dbContext.Notes.AddRangeAsync(demoNotes);
                await _dbContext.SaveChangesAsync();

                _logger.LogInformation("Demo data seeded successfully. Added {TaskCount} tasks and {NoteCount} notes", 
                    demoTasks.Count, demoNotes.Count);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while seeding demo data");
                throw;
            }
        }

        public async Task ResetDemoDataAsync()
        {
            try
            {
                _logger.LogInformation("Resetting demo data...");

                // Clear existing data
                _dbContext.Notes.RemoveRange(_dbContext.Notes);
                _dbContext.Tasks.RemoveRange(_dbContext.Tasks);
                _dbContext.Activities.RemoveRange(_dbContext.Activities);
                await _dbContext.SaveChangesAsync();

                // Reseed with fresh demo data
                await SeedDemoDataAsync();

                _logger.LogInformation("Demo data reset successfully");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while resetting demo data");
                throw;
            }
        }

        private List<TaskEntity> CreateDemoTasks()
        {
            var now = DateTime.UtcNow;
            
            return new List<TaskEntity>
            {
                new TaskEntity
                {
                    Id = Guid.NewGuid(),
                    Title = "Welcome to SignalR Demo",
                    Description = "This is a sample task to demonstrate real-time updates. Try creating, editing, or completing tasks in multiple browser tabs!",
                    IsCompleted = false,
                    CreatedAt = now.AddMinutes(-30),
                    UpdatedAt = now.AddMinutes(-30)
                },
                new TaskEntity
                {
                    Id = Guid.NewGuid(),
                    Title = "Test Real-Time Collaboration",
                    Description = "Open this application in multiple browser tabs and watch updates happen in real-time across all tabs.",
                    IsCompleted = false,
                    CreatedAt = now.AddMinutes(-25),
                    UpdatedAt = now.AddMinutes(-25)
                },
                new TaskEntity
                {
                    Id = Guid.NewGuid(),
                    Title = "Add Notes to Tasks",
                    Description = "Try adding notes to this task and see them appear instantly in other browser tabs.",
                    IsCompleted = false,
                    CreatedAt = now.AddMinutes(-20),
                    UpdatedAt = now.AddMinutes(-20)
                },
                new TaskEntity
                {
                    Id = Guid.NewGuid(),
                    Title = "Toggle Task Completion",
                    Description = "Click the completion toggle and watch the dashboard statistics update in real-time.",
                    IsCompleted = true,
                    CreatedAt = now.AddMinutes(-15),
                    UpdatedAt = now.AddMinutes(-10)
                },
                new TaskEntity
                {
                    Id = Guid.NewGuid(),
                    Title = "Monitor Activity Feed",
                    Description = "Check the dashboard to see a live activity feed of all changes happening in the system.",
                    IsCompleted = false,
                    CreatedAt = now.AddMinutes(-10),
                    UpdatedAt = now.AddMinutes(-10)
                },
                new TaskEntity
                {
                    Id = Guid.NewGuid(),
                    Title = "Create Your Own Task",
                    Description = "Feel free to create your own tasks and notes to test the real-time functionality!",
                    IsCompleted = false,
                    CreatedAt = now.AddMinutes(-5),
                    UpdatedAt = now.AddMinutes(-5)
                }
            };
        }

        private List<NoteEntity> CreateDemoNotes(List<TaskEntity> tasks)
        {
            var now = DateTime.UtcNow;
            var notes = new List<NoteEntity>();

            // Add notes to the first task
            if (tasks.Count > 0)
            {
                notes.AddRange(new[]
                {
                    new NoteEntity
                    {
                        Id = Guid.NewGuid(),
                        Content = "This note was added during demo setup. Try adding your own notes!",
                        TaskId = tasks[0].Id,
                        CreatedAt = now.AddMinutes(-28)
                    },
                    new NoteEntity
                    {
                        Id = Guid.NewGuid(),
                        Content = "Notes update in real-time too! Open multiple tabs and add notes to see the magic happen.",
                        TaskId = tasks[0].Id,
                        CreatedAt = now.AddMinutes(-25)
                    }
                });
            }

            // Add notes to the third task
            if (tasks.Count > 2)
            {
                notes.AddRange(new[]
                {
                    new NoteEntity
                    {
                        Id = Guid.NewGuid(),
                        Content = "Here's an example note attached to this task.",
                        TaskId = tasks[2].Id,
                        CreatedAt = now.AddMinutes(-18)
                    },
                    new NoteEntity
                    {
                        Id = Guid.NewGuid(),
                        Content = "You can add multiple notes to each task. Each note will broadcast to all connected clients instantly!",
                        TaskId = tasks[2].Id,
                        CreatedAt = now.AddMinutes(-15)
                    },
                    new NoteEntity
                    {
                        Id = Guid.NewGuid(),
                        Content = "Try editing or deleting notes in one tab and watch the changes in another tab.",
                        TaskId = tasks[2].Id,
                        CreatedAt = now.AddMinutes(-12)
                    }
                });
            }

            return notes;
        }
    }
}