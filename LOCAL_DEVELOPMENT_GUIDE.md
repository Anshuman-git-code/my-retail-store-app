# Simple Local Development Guide

This guide will help you run the retail store application locally without any complex DevOps setup. Perfect for beginners who want to understand the application first before implementing DevOps practices.

## What You'll Learn
- How to run a microservices application locally
- Basic Docker concepts
- Simple database setup
- Service communication

## Prerequisites
- Docker and Docker Compose installed on your machine
- Basic understanding of command line

## Application Architecture (Simplified)

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│     UI      │    │   Catalog   │    │    Cart     │
│  (Frontend) │◄──►│ (Products)  │    │ (Shopping)  │
│   Port:8888 │    │  Port:8080  │    │  Port:8080  │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       │                   │                   │
       ▼                   ▼                   ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Checkout   │    │   Orders    │    │  Database   │
│(Orchestrate)│    │ (Purchase)  │    │   (MySQL)   │
│  Port:8080  │    │  Port:8080  │    │  Port:3306  │
└─────────────┘    └─────────────┘    └─────────────┘
```

## Quick Start (Easiest Way)

### Option 1: Single Container (UI Only)
This runs just the frontend with mock data - great for seeing the UI:

```bash
docker run -p 8888:8080 public.ecr.aws/aws-containers/retail-store-sample-ui:1.0.0
```

Open your browser: http://localhost:8888

### Option 2: Full Application (Recommended)
This runs all services with a real database:

1. **Download the simple docker-compose file:**
```bash
curl -o docker-compose-simple.yml https://raw.githubusercontent.com/aws-containers/retail-store-sample-app/main/docker-compose.yaml
```

2. **Start the application:**
```bash
DB_PASSWORD=mypassword123 docker-compose -f docker-compose-simple.yml up
```

3. **Open your browser:** http://localhost:8888

4. **Stop the application:**
```bash
# Press Ctrl+C in the terminal, then run:
docker-compose -f docker-compose-simple.yml down
```

## Understanding the Services

### 1. UI Service (Frontend)
- **What it does**: Serves the web interface
- **Technology**: Java (Spring Boot)
- **Port**: 8888 (mapped from 8080)
- **Access**: http://localhost:8888

### 2. Catalog Service (Product Management)
- **What it does**: Manages product information
- **Technology**: Go
- **Port**: 8080
- **Database**: MySQL
- **API Example**: http://localhost:8080/catalogue

### 3. Cart Service (Shopping Cart)
- **What it does**: Handles shopping cart operations
- **Technology**: Java (Spring Boot)
- **Port**: 8080 (different internal network)
- **Database**: DynamoDB (local version)

### 4. Orders Service (Order Processing)
- **What it does**: Processes completed orders
- **Technology**: Java (Spring Boot)
- **Port**: 8080 (different internal network)
- **Database**: MySQL

### 5. Checkout Service (Order Orchestration)
- **What it does**: Coordinates the checkout process
- **Technology**: Node.js
- **Port**: 8080 (different internal network)

## Local Development Workflow

### Step 1: Start the Application
```bash
# Start all services
DB_PASSWORD=mypassword123 docker-compose -f docker-compose-simple.yml up

# Or start in background
DB_PASSWORD=mypassword123 docker-compose -f docker-compose-simple.yml up -d
```

### Step 2: Test the Application
1. Open http://localhost:8888
2. Browse products
3. Add items to cart
4. Complete checkout process

### Step 3: View Logs
```bash
# View all logs
docker-compose -f docker-compose-simple.yml logs

# View specific service logs
docker-compose -f docker-compose-simple.yml logs ui
docker-compose -f docker-compose-simple.yml logs catalog
```

### Step 4: Stop the Application
```bash
# Stop services
docker-compose -f docker-compose-simple.yml down

# Stop and remove volumes (clears database)
docker-compose -f docker-compose-simple.yml down -v
```

## Troubleshooting

### Common Issues

1. **Port already in use**
   ```bash
   # Check what's using port 8888
   lsof -i :8888
   
   # Kill the process or change the port in docker-compose
   ```

2. **Services not starting**
   ```bash
   # Check service status
   docker-compose -f docker-compose-simple.yml ps
   
   # Check logs for errors
   docker-compose -f docker-compose-simple.yml logs [service-name]
   ```

3. **Database connection issues**
   ```bash
   # Restart just the database
   docker-compose -f docker-compose-simple.yml restart mysql
   ```

4. **Clear everything and start fresh**
   ```bash
   # Stop and remove everything
   docker-compose -f docker-compose-simple.yml down -v
   docker system prune -f
   
   # Start again
   DB_PASSWORD=mypassword123 docker-compose -f docker-compose-simple.yml up
   ```

## Understanding Docker Compose

The `docker-compose-simple.yml` file defines:
- **Services**: Each microservice and database
- **Networks**: How services communicate
- **Volumes**: Where data is stored
- **Environment Variables**: Configuration settings

### Key Concepts:
- **Container**: A running instance of a service
- **Image**: The blueprint for a container
- **Port Mapping**: How to access services from your computer
- **Environment Variables**: Configuration passed to containers

## Next Steps for DevOps Learning

Once you're comfortable running the application locally, you can start implementing DevOps practices:

### Phase 1: Basic DevOps
1. **Version Control**: Learn Git basics
2. **Docker**: Create your own Dockerfiles
3. **Environment Management**: Different configs for dev/prod

### Phase 2: Automation
1. **CI/CD**: Set up GitHub Actions
2. **Testing**: Add automated tests
3. **Code Quality**: Add linting and formatting

### Phase 3: Infrastructure
1. **Cloud Deployment**: Deploy to AWS
2. **Kubernetes**: Container orchestration
3. **Monitoring**: Add logging and metrics

### Phase 4: Advanced
1. **Infrastructure as Code**: Terraform
2. **Service Mesh**: Istio
3. **Security**: Implement security best practices

## Useful Commands

```bash
# View running containers
docker ps

# View all containers (including stopped)
docker ps -a

# View Docker images
docker images

# Clean up unused Docker resources
docker system prune

# View container resource usage
docker stats

# Execute command in running container
docker exec -it [container-name] /bin/bash

# View Docker Compose services
docker-compose -f docker-compose-simple.yml ps

# Scale a service (run multiple instances)
docker-compose -f docker-compose-simple.yml up --scale catalog=2
```

## Learning Resources

- **Docker**: https://docs.docker.com/get-started/
- **Docker Compose**: https://docs.docker.com/compose/
- **Microservices**: https://microservices.io/
- **DevOps Roadmap**: https://roadmap.sh/devops

## Support

If you encounter issues:
1. Check the logs first
2. Search for the error message online
3. Try restarting the services
4. Clear everything and start fresh

Remember: This is a learning environment, so don't worry about breaking things. Experiment and learn!
