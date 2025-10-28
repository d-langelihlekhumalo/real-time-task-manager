using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

namespace RealTimeTaskManager.Data
{
    public class SqlDBContextFactory : IDBContextFactory
    {
        private readonly IConfiguration _configuration;

        public SqlDBContextFactory(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public ApplicationDbContext CreateDbContext()
        {
            // Try environment variable first, then fall back to configuration
            var connectionString = Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection") 
                                 ?? _configuration.GetConnectionString("DefaultConnection");

            if (string.IsNullOrEmpty(connectionString))
            {
                throw new InvalidOperationException("Database connection string is not configured");
            }

            var options = new DbContextOptionsBuilder<ApplicationDbContext>()
                .UseMySql(connectionString, ServerVersion.AutoDetect(connectionString), mySqlOptions =>
                {
                    mySqlOptions.CommandTimeout(180);
                    mySqlOptions.EnableRetryOnFailure(maxRetryCount: 3, maxRetryDelay: TimeSpan.FromSeconds(30), errorNumbersToAdd: null);
                })
                .Options;

            return new ApplicationDbContext(options);
        }
    }
}
