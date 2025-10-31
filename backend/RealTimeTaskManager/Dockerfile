FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

# Set working directory
WORKDIR /src

# Copy csproj and restore as distinct layers
COPY ["RealTimeTaskManager.csproj", "./"]
RUN dotnet restore "RealTimeTaskManager.csproj"

# Copy everything else and publish
COPY . ./
RUN dotnet publish "RealTimeTaskManager.csproj" -c Release -o /app/out

## Runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Expose the port the app will listen on
ENV ASPNETCORE_URLS=http://*:5000
EXPOSE 5000

# Copy published output
COPY --from=build /app/out ./

# Create a non-root user and set permissions
RUN adduser --disabled-password --gecos '' appuser \
	&& chown -R appuser /app

USER appuser

# Start the app
ENTRYPOINT ["dotnet", "RealTimeTaskManager.dll"]