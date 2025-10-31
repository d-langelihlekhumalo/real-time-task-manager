﻿using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace RealTimeTaskManager.Data
{
    public class SqlDBContextFactory : IDBContextFactory
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<SqlDBContextFactory> _logger;

        public SqlDBContextFactory(IConfiguration configuration, ILogger<SqlDBContextFactory> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        public ApplicationDbContext CreateDbContext()
        {
            _logger.LogInformation("SqlDBContextFactory.CreateDbContext() called");

            // Try environment variable first, then fall back to configuration
            var envConnectionString = Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection");
            var configConnectionString = _configuration.GetConnectionString("DefaultConnection");

            _logger.LogInformation("SqlDBContextFactory - Environment variable: {EnvConnString}", 
                string.IsNullOrEmpty(envConnectionString) ? "NOT SET" : "SET (length: " + envConnectionString.Length + ")");
            _logger.LogInformation("SqlDBContextFactory - Configuration: {ConfigConnString}", 
                string.IsNullOrEmpty(configConnectionString) ? "NOT SET" : "SET (length: " + configConnectionString.Length + ")");

            var connectionString = envConnectionString ?? configConnectionString;

            if (string.IsNullOrEmpty(connectionString))
            {
                _logger.LogError("SqlDBContextFactory - Database connection string is not configured. Env: {Env}, Config: {Config}", 
                    envConnectionString ?? "NULL", configConnectionString ?? "NULL");
                throw new InvalidOperationException("Database connection string is not configured");
            }

            _logger.LogInformation("SqlDBContextFactory - Using connection string from: {Source}", 
                envConnectionString != null ? "Environment Variable" : "Configuration");

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
