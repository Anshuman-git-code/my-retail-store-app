# Retail Store - Local Development Setup

A simplified version of the AWS Containers Retail Store application for local development and DevOps learning.

## 🎯 Purpose

This setup removes all complex DevOps configurations and provides a clean foundation for:
- Understanding microservices architecture
- Learning Docker and containerization
- Practicing DevOps implementation step by step

## 🚀 Quick Start

### Prerequisites
- Docker Desktop installed and running
- Basic command line knowledge

### Option 1: Super Simple (UI Only)
```bash
docker run -p 8888:8080 public.ecr.aws/aws-containers/retail-store-sample-ui:1.0.0
```
Open: http://localhost:8888

### Option 2: Full Application (Recommended)
```bash
# Easy way - use the startup script
./start-local.sh

# Manual way
DB_PASSWORD=mypassword123 docker-compose -f docker-compose-simple.yml up
```
Open: http://localhost:8888

## 📁 Project Structure

```
my-retail-store-app/
├── src/                          # Source code (microservices)
│   ├── ui/                       # Frontend (Java/Spring Boot)
│   ├── catalog/                  # Product catalog (Go)
│   ├── cart/                     # Shopping cart (Java/Spring Boot)
│   ├── orders/                   # Order processing (Java/Spring Boot)
│   └── checkout/                 # Checkout orchestration (Node.js)
├── docker-compose-simple.yml     # Simple local setup
├── start-local.sh               # Easy startup script
├── init-scripts/                # Database initialization
├── LOCAL_DEVELOPMENT_GUIDE.md   # Detailed local dev guide
└── README-LOCAL.md              # This file
```

## 🛠 Services Overview

| Service | Technology | Port | Purpose |
|---------|------------|------|---------|
| UI | Java (Spring Boot) | 8888 | Web frontend |
| Catalog | Go | 8080* | Product management |
| Cart | Java (Spring Boot) | 8080* | Shopping cart |
| Orders | Java (Spring Boot) | 8080* | Order processing |
| Checkout | Node.js | 8080* | Checkout orchestration |
| MySQL | MySQL 8.0 | 3306 | Database for catalog/orders |
| DynamoDB | DynamoDB Local | 8000 | Database for cart |

*Internal ports - accessed through UI

## 🎓 Learning Path

### Phase 1: Understand the Application
1. Run the application locally
2. Explore the UI and functionality
3. Check service logs
4. Understand service communication

### Phase 2: Basic DevOps
1. **Version Control**: Initialize Git repository
2. **Docker**: Understand the docker-compose file
3. **Environment Management**: Create dev/staging configs
4. **Documentation**: Improve README files

### Phase 3: Automation
1. **CI/CD**: Set up GitHub Actions
2. **Testing**: Add unit and integration tests
3. **Code Quality**: Add linting and formatting
4. **Build Automation**: Create build scripts

### Phase 4: Infrastructure
1. **Cloud Deployment**: Deploy to AWS/Azure/GCP
2. **Container Orchestration**: Learn Kubernetes
3. **Infrastructure as Code**: Use Terraform
4. **Monitoring**: Add logging and metrics

## 🔧 Common Commands

```bash
# Start application
./start-local.sh

# Start in background
DB_PASSWORD=mypassword123 docker-compose -f docker-compose-simple.yml up -d

# View logs
docker-compose -f docker-compose-simple.yml logs

# Stop application
docker-compose -f docker-compose-simple.yml down

# Clean up everything (including data)
docker-compose -f docker-compose-simple.yml down -v

# View running containers
docker ps

# Check service health
docker-compose -f docker-compose-simple.yml ps
```

## 🐛 Troubleshooting

### Port Already in Use
```bash
# Find what's using port 8888
lsof -i :8888

# Kill the process or change port in docker-compose-simple.yml
```

### Services Won't Start
```bash
# Check logs for specific service
docker-compose -f docker-compose-simple.yml logs ui
docker-compose -f docker-compose-simple.yml logs catalog

# Restart specific service
docker-compose -f docker-compose-simple.yml restart ui
```

### Database Issues
```bash
# Restart database
docker-compose -f docker-compose-simple.yml restart mysql

# Clear database and start fresh
docker-compose -f docker-compose-simple.yml down -v
DB_PASSWORD=mypassword123 docker-compose -f docker-compose-simple.yml up
```

### Complete Reset
```bash
# Stop everything
docker-compose -f docker-compose-simple.yml down -v

# Clean Docker system
docker system prune -f

# Start fresh
./start-local.sh
```

## 📚 Next Steps

1. **Read the detailed guide**: `LOCAL_DEVELOPMENT_GUIDE.md`
2. **Explore the source code**: Check out the `src/` directory
3. **Experiment**: Try modifying configurations
4. **Learn Docker**: Understand the docker-compose file
5. **Plan DevOps**: Choose which practices to implement first

## 🎯 DevOps Practice Ideas

Start with these beginner-friendly practices:

1. **Git Workflow**: Create feature branches, pull requests
2. **Environment Variables**: Externalize configuration
3. **Health Checks**: Add container health checks
4. **Logging**: Centralize log collection
5. **Monitoring**: Add basic metrics
6. **Testing**: Write simple tests
7. **Documentation**: Improve project documentation

## 💡 Tips for Beginners

- Start simple and add complexity gradually
- Always check logs when something doesn't work
- Use `docker ps` and `docker logs` frequently
- Don't be afraid to restart services
- Clean up regularly with `docker system prune`
- Document your learning journey

## 🆘 Getting Help

1. Check the logs first: `docker-compose logs [service-name]`
2. Search for error messages online
3. Try restarting the problematic service
4. Ask questions in DevOps communities
5. Practice on a separate branch

Happy learning! 🚀
