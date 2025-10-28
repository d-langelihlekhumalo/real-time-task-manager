@echo off
REM Real Time Task Manager - Windows Deployment Script

setlocal enabledelayedexpansion

echo [INFO] Real Time Task Manager - Windows Deployment
echo.

REM Default values
set ENVIRONMENT=production
set BUILD_ONLY=false
set SKIP_TESTS=false

REM Parse command line arguments
:parse_args
if "%1"=="" goto :validate_env
if "%1"=="-e" (
    set ENVIRONMENT=%2
    shift
    shift
    goto :parse_args
)
if "%1"=="--environment" (
    set ENVIRONMENT=%2
    shift
    shift
    goto :parse_args
)
if "%1"=="-b" (
    set BUILD_ONLY=true
    shift
    goto :parse_args
)
if "%1"=="--build-only" (
    set BUILD_ONLY=true
    shift
    goto :parse_args
)
if "%1"=="-s" (
    set SKIP_TESTS=true
    shift
    goto :parse_args
)
if "%1"=="--skip-tests" (
    set SKIP_TESTS=true
    shift
    goto :parse_args
)
if "%1"=="-h" goto :help
if "%1"=="--help" goto :help
echo [ERROR] Unknown option: %1
goto :error

:help
echo Usage: deploy.bat [options]
echo Options:
echo   -e, --environment    Set environment (development, staging, production)
echo   -b, --build-only     Only build, don't run containers
echo   -s, --skip-tests     Skip running tests
echo   -h, --help          Show this help message
goto :end

:validate_env
echo [INFO] Starting deployment for environment: !ENVIRONMENT!

REM Check if .env file exists
if not exist .env (
    if exist .env.example (
        echo [WARNING] .env file not found. Copying from .env.example
        copy .env.example .env
        echo [WARNING] Please edit .env file with your actual configuration values
        pause
    ) else (
        echo [ERROR] .env file not found and no .env.example available
        goto :error
    )
)

REM Check Docker
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not installed or not in PATH
    goto :error
)

docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker Compose is not installed or not in PATH
    goto :error
)

REM Run tests unless skipped
if "!SKIP_TESTS!"=="false" (
    echo [INFO] Running tests...
    dotnet --version >nul 2>&1
    if not errorlevel 1 (
        dotnet test --no-restore --verbosity minimal
        if errorlevel 1 (
            echo [ERROR] Tests failed. Deployment aborted.
            goto :error
        )
        echo [INFO] All tests passed!
    ) else (
        echo [WARNING] dotnet CLI not found. Skipping tests.
    )
)

REM Build the application
echo [INFO] Building Docker images...
docker-compose build
if errorlevel 1 (
    echo [ERROR] Docker build failed
    goto :error
)

echo [INFO] Docker images built successfully

REM If build-only flag is set, exit here
if "!BUILD_ONLY!"=="true" (
    echo [INFO] Build completed successfully. Exiting (build-only mode)
    goto :end
)

REM Stop existing containers
echo [INFO] Stopping existing containers...
docker-compose down

REM Start the services
echo [INFO] Starting services...
docker-compose up -d
if errorlevel 1 (
    echo [ERROR] Failed to start services
    goto :error
)

REM Wait for services to be healthy
echo [INFO] Waiting for services to be healthy...
timeout /t 10 /nobreak >nul

REM Check if services are running
docker-compose ps | findstr "Up" >nul
if not errorlevel 1 (
    echo [INFO] Services started successfully!
    echo [INFO] API available at: http://localhost:8080
    echo [INFO] Health check: http://localhost:8080/health
    echo [INFO] Swagger UI: http://localhost:8080/swagger
    echo.
    echo [INFO] Running containers:
    docker-compose ps
    echo.
    echo [INFO] Deployment completed successfully!
) else (
    echo [ERROR] Services failed to start properly
    echo [ERROR] Check logs with: docker-compose logs
    goto :error
)

goto :end

:error
echo [ERROR] Deployment failed!
exit /b 1

:end
endlocal