using Microsoft.EntityFrameworkCore;
using NetCore.AutoRegisterDi;
using RealTimeTaskManager.AutoMapper;
using RealTimeTaskManager.Configuration;
using RealTimeTaskManager.Data;
using RealTimeTaskManager.Hubs;
using RealTimeTaskManager.Middleware;
using RealTimeTaskManager.Services;
using Serilog;
using System.Reflection;

var builder = WebApplication.CreateBuilder(args);

// Configure Serilog
Log.Logger = new LoggerConfiguration()
    .ReadFrom.Configuration(builder.Configuration)
    .WriteTo.Console()
    .WriteTo.File("logs/log-.txt", rollingInterval: RollingInterval.Day)
    .CreateLogger();

builder.Host.UseSerilog();

// Configuration sections
var corsConfig = builder.Configuration.GetSection("Cors").Get<CorsConfiguration>() ?? new CorsConfiguration();
var healthChecksConfig = builder.Configuration.GetSection("HealthChecks").Get<HealthChecksConfiguration>() ?? new HealthChecksConfiguration();
var swaggerConfig = builder.Configuration.GetSection("SwaggerUI").Get<SwaggerConfiguration>() ?? new SwaggerConfiguration();

// Add services to the container.
builder.Services.AddScoped<IDBContextFactory, SqlDBContextFactory>();

var assembliesToScan = new[] { Assembly.GetExecutingAssembly(), Assembly.Load("RealTimeTaskManager") };
var registration = builder.Services.RegisterAssemblyPublicNonGenericClasses(assembliesToScan)
                           .Where(type => type.Namespace != null && type.Namespace.Contains("RealTimeTaskManager.Services"))
                           .AsPublicImplementedInterfaces(ServiceLifetime.Transient);

// Get connection string from environment variable or configuration
var connectionString = Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection") 
                      ?? builder.Configuration.GetConnectionString("DefaultConnection");

if (string.IsNullOrEmpty(connectionString))
{
    throw new InvalidOperationException("Database connection string is not configured. Please set ConnectionStrings__DefaultConnection environment variable or add it to appsettings.json");
}

// Add DbContext with connection pooling
builder.Services.AddDbContextPool<ApplicationDbContext>(options =>
    options.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString),
        mySqlOptions =>
        {
            mySqlOptions.CommandTimeout(180);
            mySqlOptions.EnableRetryOnFailure(maxRetryCount: 3, maxRetryDelay: TimeSpan.FromSeconds(30), errorNumbersToAdd: null);
        }));

// Add AutoMapper
builder.Services.AddAutoMapper(x => x.AddProfile<MappingProfile>());

// Add CORS
if (corsConfig.AllowedOrigins.Length > 0)
{
    builder.Services.AddCors(options =>
    {
        options.AddPolicy("DefaultCorsPolicy", policy =>
        {
            policy.WithOrigins(corsConfig.AllowedOrigins)
                  .AllowAnyMethod()
                  .AllowAnyHeader();
            
            if (corsConfig.AllowCredentials)
            {
                policy.AllowCredentials();
            }
        });
    });
}
else
{
    // Fallback CORS policy for development
    builder.Services.AddCors(options =>
    {
        options.AddPolicy("DefaultCorsPolicy", policy =>
        {
            policy.AllowAnyOrigin()
                  .AllowAnyMethod()
                  .AllowAnyHeader();
        });
    });
}

// Add Health Checks
if (healthChecksConfig.Enabled)
{
    builder.Services.AddHealthChecks()
        .AddDbContextCheck<ApplicationDbContext>()
        .AddMySql(connectionString);
}

// Add SignalR
builder.Services.AddSignalR();

// Register SignalR Hub Service
builder.Services.AddScoped<ITaskManagerHubService, TaskManagerHubService>();

// Register Data Seeding Service
builder.Services.AddScoped<IDataSeedingService, DataSeedingService>();

// Add security headers
builder.Services.AddHsts(options =>
{
    options.Preload = true;
    options.IncludeSubDomains = true;
    options.MaxAge = TimeSpan.FromDays(365);
});

builder.Services.AddControllers();

// Configure Swagger/OpenAPI
builder.Services.AddEndpointsApiExplorer();
if (swaggerConfig.Enabled)
{
    builder.Services.AddSwaggerGen(c =>
    {
        c.SwaggerDoc("v1", new() { 
            Title = "Real Time Task Manager API", 
            Version = "v1",
            Description = "A real-time task management API with SignalR support for managing tasks and notes in real-time"
        });
        
        // Include XML comments
        var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
        var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
        if (File.Exists(xmlPath))
        {
            c.IncludeXmlComments(xmlPath);
        }
    });
}

var app = builder.Build();

// Configure the HTTP request pipeline.
app.UseMiddleware<GlobalExceptionHandlingMiddleware>();

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}
else
{
    app.UseHsts();
}

// Add security headers
app.Use(async (context, next) =>
{
    context.Response.Headers.Add("X-Frame-Options", "DENY");
    context.Response.Headers.Add("X-Content-Type-Options", "nosniff");
    context.Response.Headers.Add("Referrer-Policy", "strict-origin-when-cross-origin");
    context.Response.Headers.Add("X-XSS-Protection", "1; mode=block");
    
    await next();
});

// Configure Swagger UI
if (swaggerConfig.Enabled)
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Real Time Task Manager API v1");
        c.RoutePrefix = "swagger";
    });
}

app.UseHttpsRedirection();

// Use CORS
app.UseCors("DefaultCorsPolicy");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

// Map SignalR Hub
app.MapHub<TaskManagerHub>("/taskManagerHub");

// Map Health Checks
if (healthChecksConfig.Enabled)
{
    app.MapHealthChecks("/health", new Microsoft.AspNetCore.Diagnostics.HealthChecks.HealthCheckOptions
    {
        ResponseWriter = async (context, report) =>
        {
            context.Response.ContentType = "application/json";
            var response = new
            {
                status = report.Status.ToString(),
                checks = healthChecksConfig.DetailedErrors ? report.Entries.Select(e => new
                {
                    name = e.Key,
                    status = e.Value.Status.ToString(),
                    exception = e.Value.Exception?.Message,
                    duration = e.Value.Duration.ToString()
                }) : null
            };
            await context.Response.WriteAsync(System.Text.Json.JsonSerializer.Serialize(response));
        }
    });
}

// Ensure database is created and seed demo data
using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    var dataSeedingService = scope.ServiceProvider.GetRequiredService<IDataSeedingService>();
    
    try
    {
        dbContext.Database.EnsureCreated();
        Log.Information("Database connection verified successfully");
        
        // Seed demo data on startup
        await dataSeedingService.SeedDemoDataAsync();
        Log.Information("Demo data seeding completed");
    }
    catch (Exception ex)
    {
        Log.Fatal(ex, "Failed to connect to the database or seed demo data");
        throw;
    }
}

Log.Information("Starting Real Time Task Manager API");

app.Run();
