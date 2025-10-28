# Use the official .NET 8.0 SDK image for building
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

# Set the working directory
WORKDIR /app

# Copy the project file and restore dependencies
COPY *.csproj ./
RUN dotnet restore

# Copy the rest of the application files
COPY . ./

# Build the application
RUN dotnet publish -c Release -o out

# Use the official .NET 8.0 runtime image for running
FROM mcr.microsoft.com/dotnet/aspnet:8.0

# Set the working directory
WORKDIR /app

# Copy the built application from the build stage
COPY --from=build /app/out .

# Expose the port that the application will run on
EXPOSE 5000

# Set environment variables
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://*:5000

# Create a non-root user for security
RUN adduser --disabled-password --gecos '' appuser && chown -R appuser /app
USER appuser

# Set the entry point
ENTRYPOINT ["dotnet", "RealTimeTaskManager.dll"]