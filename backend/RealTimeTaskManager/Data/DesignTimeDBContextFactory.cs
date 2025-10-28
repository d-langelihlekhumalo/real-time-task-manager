using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace RealTimeTaskManager.Data
{
    public class DesignTimeDBContextFactory : IDesignTimeDbContextFactory<ApplicationDbContext>
    {
        public ApplicationDbContext CreateDbContext(string[] args)
        {
            var optionsBuilder = new DbContextOptionsBuilder<ApplicationDbContext>();
            
            // Use environment variable first, then fall back to default for design-time
            var connectionString = Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection") 
                                 ?? "server=localhost;port=3306;user=root;password=root;database=RealTimeTaskManagerDB";
            
            optionsBuilder.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString));

            return new ApplicationDbContext(optionsBuilder.Options);
        }
    }
}
