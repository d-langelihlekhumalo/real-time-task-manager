# Docker management script for Real-Time Task Management App (PowerShell)
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("build-prod", "build-dev", "run-prod", "run-dev", "start", "start-dev", "stop", "logs", "clean", "health", "shell")]
    [string]$Command
)

# Configuration
$IMAGE_NAME = "task-manager-frontend"
$CONTAINER_NAME = "task-manager-frontend-container"
$PROD_PORT = "3000"
$DEV_PORT = "5173"

# Functions
function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Build-Production {
    Write-ColorOutput "Building production Docker image..." "Green"
    docker build -t $IMAGE_NAME .
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "Production image built successfully!" "Green"
    } else {
        Write-ColorOutput "Build failed!" "Red"
        exit 1
    }
}

function Build-Development {
    Write-ColorOutput "Building development Docker image..." "Green"
    docker build -f Dockerfile.dev -t "$IMAGE_NAME-dev" .
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "Development image built successfully!" "Green"
    } else {
        Write-ColorOutput "Build failed!" "Red"
        exit 1
    }
}

function Run-Production {
    Write-ColorOutput "Running production container..." "Green"
    docker run -d `
        --name $CONTAINER_NAME `
        -p "${PROD_PORT}:80" `
        --restart unless-stopped `
        $IMAGE_NAME
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "Production container started on port $PROD_PORT" "Green"
    }
}

function Run-Development {
    Write-ColorOutput "Running development container..." "Green"
    $currentPath = (Get-Location).Path
    docker run -d `
        --name "$CONTAINER_NAME-dev" `
        -p "${DEV_PORT}:5173" `
        -v "${currentPath}:/app" `
        -v "/app/node_modules" `
        --restart unless-stopped `
        "$IMAGE_NAME-dev"
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "Development container started on port $DEV_PORT" "Green"
    }
}

function Start-Compose {
    Write-ColorOutput "Starting with docker-compose (production)..." "Green"
    docker-compose up -d
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "Application started on port $PROD_PORT" "Green"
    }
}

function Start-ComposeDev {
    Write-ColorOutput "Starting with docker-compose (development)..." "Green"
    docker-compose -f docker-compose.dev.yml up -d
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "Development server started on port $DEV_PORT" "Green"
    }
}

function Stop-Containers {
    Write-ColorOutput "Stopping containers..." "Yellow"
    try {
        docker-compose down 2>$null
    } catch {}
    try {
        docker-compose -f docker-compose.dev.yml down 2>$null
    } catch {}
    try {
        docker stop $CONTAINER_NAME 2>$null
    } catch {}
    try {
        docker stop "$CONTAINER_NAME-dev" 2>$null
    } catch {}
    Write-ColorOutput "Containers stopped" "Green"
}

function Show-Logs {
    Write-ColorOutput "Showing logs..." "Green"
    $runningContainers = docker ps --format "table {{.Names}}"
    if ($runningContainers -match $CONTAINER_NAME) {
        docker logs -f $CONTAINER_NAME
    } elseif ((docker-compose ps) -match "frontend") {
        docker-compose logs -f
    } else {
        Write-ColorOutput "No running containers found" "Red"
    }
}

function Clean-All {
    Write-ColorOutput "Cleaning up containers and images..." "Yellow"
    Stop-Containers
    try {
        docker rm $CONTAINER_NAME 2>$null
    } catch {}
    try {
        docker rm "$CONTAINER_NAME-dev" 2>$null
    } catch {}
    try {
        docker rmi $IMAGE_NAME 2>$null
    } catch {}
    try {
        docker rmi "$IMAGE_NAME-dev" 2>$null
    } catch {}
    docker builder prune -f
    Write-ColorOutput "Cleanup completed" "Green"
}

function Check-Health {
    Write-ColorOutput "Checking container health..." "Green"
    $runningContainers = docker ps --format "table {{.Names}}"
    if ($runningContainers -match $CONTAINER_NAME) {
        docker exec $CONTAINER_NAME curl -f http://localhost:80/
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "Health check failed" "Red"
        }
    } else {
        Write-ColorOutput "No production container running" "Yellow"
    }
}

function Access-Shell {
    Write-ColorOutput "Accessing container shell..." "Green"
    $runningContainers = docker ps --format "table {{.Names}}"
    if ($runningContainers -match $CONTAINER_NAME) {
        docker exec -it $CONTAINER_NAME sh
    } elseif ($runningContainers -match "$CONTAINER_NAME-dev") {
        docker exec -it "$CONTAINER_NAME-dev" sh
    } else {
        Write-ColorOutput "No running containers found" "Red"
    }
}

# Main script execution
switch ($Command) {
    "build-prod" { Build-Production }
    "build-dev" { Build-Development }
    "run-prod" { Run-Production }
    "run-dev" { Run-Development }
    "start" { Start-Compose }
    "start-dev" { Start-ComposeDev }
    "stop" { Stop-Containers }
    "logs" { Show-Logs }
    "clean" { Clean-All }
    "health" { Check-Health }
    "shell" { Access-Shell }
    default {
        Write-ColorOutput "Invalid command. Available commands:" "Red"
        Write-ColorOutput "build-prod, build-dev, run-prod, run-dev, start, start-dev, stop, logs, clean, health, shell" "Yellow"
    }
}