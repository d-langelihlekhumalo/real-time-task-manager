﻿using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Serilog;

namespace RealTimeTaskManager.Data
{
    public class DesignTimeDBContextFactory : IDesignTimeDbContextFactory<ApplicationDbContext>
    {
        public ApplicationDbContext CreateDbContext(string[] args)
        {
            Log.Information("DesignTimeDBContextFactory.CreateDbContext() called with args: {Args}", string.Join(", ", args));

            var optionsBuilder = new DbContextOptionsBuilder<ApplicationDbContext>();
            
            // Use environment variable first, then fall back to default for design-time
            var envConnectionString = Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection");
            var defaultConnectionString = "server=localhost;port=3306;user=root;password=root;database=RealTimeTaskManagerDB";
            
            Log.Information("DesignTimeDBContextFactory - Environment variable: {EnvConnString}", 
                string.IsNullOrEmpty(envConnectionString) ? "NOT SET" : "SET (length: " + envConnectionString.Length + ")");
            
            var connectionString = envConnectionString ?? defaultConnectionString;
            
            Log.Information("DesignTimeDBContextFactory - Using connection string from: {Source}", 
                envConnectionString != null ? "Environment Variable" : "Default fallback");
            Log.Information("DesignTimeDBContextFactory - Connection string: Server={Server}, Database={Database}", 
                ExtractServer(connectionString), ExtractDatabase(connectionString));
            
            optionsBuilder.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString));

            return new ApplicationDbContext(optionsBuilder.Options);
        }

        private static string ExtractServer(string connectionString)
        {
            try
            {
                var parts = connectionString.Split(';');
                var serverPart = parts.FirstOrDefault(p => p.Trim().StartsWith("server=", StringComparison.OrdinalIgnoreCase));
                return serverPart?.Split('=')[1] ?? "Unknown";
            }
            catch
            {
                return "Parse Error";
            }
        }

        private static string ExtractDatabase(string connectionString)
        {
            try
            {
                var parts = connectionString.Split(';');
                var dbPart = parts.FirstOrDefault(p => p.Trim().StartsWith("database=", StringComparison.OrdinalIgnoreCase));
                return dbPart?.Split('=')[1] ?? "Unknown";
            }
            catch
            {
                return "Parse Error";
            }
        }
    }
}
