# AWS Containers Retail Store Application - Detailed Guide

## Table of Contents
1. [Application Overview](#application-overview)
2. [Architecture Deep Dive](#architecture-deep-dive)
3. [How the Application Runs](#how-the-application-runs)
4. [Containerization with Docker](#containerization-with-docker)
5. [Kubernetes Deployment](#kubernetes-deployment)
6. [CI/CD Implementation](#cicd-implementation)
7. [Infrastructure as Code with Terraform](#infrastructure-as-code-with-terraform)
8. [DevOps Best Practices](#devops-best-practices)
9. [Monitoring and Observability](#monitoring-and-observability)
10. [Security Considerations](#security-considerations)
11. [Scaling and Performance](#scaling-and-performance)

## Application Overview

The AWS Containers Retail Store is a microservices-based e-commerce application designed to demonstrate modern containerization and cloud-native practices. It's intentionally over-engineered to showcase various AWS services and deployment patterns.

### Key Features
- **Multi-language microservices**: Java, Go, Node.js
- **Multiple persistence backends**: MariaDB/MySQL, DynamoDB, Redis, MongoDB
- **Container orchestration**: Docker Compose, Kubernetes, ECS, App Runner
- **Multi-architecture support**: x86-64 and ARM64
- **Observability**: Prometheus metrics, OpenTelemetry tracing
- **Service mesh**: Istio support
- **Load testing**: Built-in load generator

## Architecture Deep Dive

### Microservices Components

| Service | Technology | Port | Database | Purpose |
|---------|------------|------|----------|---------|
| **UI** | Java (Spring Boot) | 8080 | None | Frontend web interface |
| **Catalog** | Go | 8080 | MySQL/MariaDB | Product catalog management |
| **Cart** | Java (Spring Boot) | 8080 | DynamoDB/MongoDB | Shopping cart operations |
| **Orders** | Java (Spring Boot) | 8080 | MySQL/MariaDB | Order processing |
| **Checkout** | Node.js (Express) | 8080 | None | Orchestrates checkout flow |

### Data Flow
1. **User Interface**: Serves the web frontend and handles user interactions
2. **Catalog Service**: Manages product information and inventory
3. **Cart Service**: Handles shopping cart operations (add/remove items)
4. **Checkout Service**: Orchestrates the checkout process
5. **Orders Service**: Processes and stores completed orders

### Communication Patterns
- **Synchronous**: REST APIs between services
- **Service Discovery**: Environment variables or Kubernetes DNS
- **Load Balancing**: Built into container orchestration platforms

## How the Application Runs

### Local Development Mode
```bash
# Single container mode (UI only)
docker run -p 8888:8080 public.ecr.aws/aws-containers/retail-store-sample-ui:1.0.0
```

### Full Application Stack
```bash
# Download and run with Docker Compose
wget https://github.com/aws-containers/retail-store-sample-app/releases/latest/download/docker-compose.yaml
DB_PASSWORD='secure_password' docker compose up
```

### Service Dependencies
- **UI Service**: Depends on all backend services
- **Checkout Service**: Depends on Cart and Orders services
- **Cart/Orders Services**: Depend on their respective databases
- **Catalog Service**: Depends on MySQL/MariaDB

## Containerization with Docker

### Container Images
All services are containerized with pre-built images available in AWS ECR Public Gallery:

```dockerfile
# Example Dockerfile structure for Java services
FROM openjdk:17-jre-slim
COPY target/app.jar /app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

### Multi-Architecture Support
- **x86-64**: Standard Intel/AMD processors
- **ARM64**: Apple Silicon, AWS Graviton processors

### Docker Compose Configuration
```yaml
version: '3.8'
services:
  ui:
    image: public.ecr.aws/aws-containers/retail-store-sample-ui:1.0.0
    ports:
      - "8888:8080"
    environment:
      - CATALOG_ENDPOINT=http://catalog:8080
      - CART_ENDPOINT=http://cart:8080
      - CHECKOUT_ENDPOINT=http://checkout:8080
      - ORDERS_ENDPOINT=http://orders:8080
```

### Container Best Practices Implemented
- **Multi-stage builds**: Reduce image size
- **Non-root users**: Enhanced security
- **Health checks**: Container health monitoring
- **Resource limits**: CPU and memory constraints
- **Secrets management**: Environment variables for sensitive data

## Kubernetes Deployment

### Deployment Options

#### 1. Simple Kubernetes Deployment
```bash
kubectl apply -f https://github.com/aws-containers/retail-store-sample-app/releases/latest/download/kubernetes.yaml
```

#### 2. Helm Charts (Recommended)
```bash
# Add the repository
helm repo add retail-store https://gallery.ecr.aws/aws-containers/

# Install individual services
helm install ui retail-store/retail-store-sample-ui-chart
helm install catalog retail-store/retail-store-sample-catalog-chart
```

### Kubernetes Resources Created
- **Deployments**: For each microservice
- **Services**: ClusterIP for internal communication, LoadBalancer for UI
- **ConfigMaps**: Application configuration
- **Secrets**: Database passwords and API keys
- **Ingress**: External traffic routing (optional)

### Advanced Kubernetes Features

#### Service Mesh with Istio
```yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: retail-store-istio
spec:
  values:
    global:
      meshID: retail-store
      network: retail-network
```

#### Horizontal Pod Autoscaling
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: ui-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ui
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## CI/CD Implementation

### GitHub Actions Pipeline Example
```yaml
name: CI/CD Pipeline
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Tests
        run: |
          # Run unit tests for each service
          cd src/ui && ./mvnw test
          cd ../catalog && go test ./...
          cd ../cart && ./mvnw test

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-west-2

      - name: Build and Push Images
        run: |
          # Build and push to ECR
          aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_REGISTRY
          docker build -t $ECR_REGISTRY/retail-ui:$GITHUB_SHA src/ui/
          docker push $ECR_REGISTRY/retail-ui:$GITHUB_SHA

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Deploy to EKS
        run: |
          aws eks update-kubeconfig --name retail-store-cluster
          kubectl set image deployment/ui ui=$ECR_REGISTRY/retail-ui:$GITHUB_SHA
```

### GitOps with ArgoCD
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: retail-store
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/retail-store-config
    targetRevision: HEAD
    path: k8s/overlays/production
  destination:
    server: https://kubernetes.default.svc
    namespace: retail-store
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## Infrastructure as Code with Terraform

### Available Terraform Modules

#### 1. Amazon EKS Deployment
```hcl
module "retail_store_eks" {
  source = "./terraform/eks/default"
  
  cluster_name = "retail-store"
  region       = "us-west-2"
  
  # Database configuration
  enable_rds      = true
  db_instance_class = "db.t3.medium"
  
  # DynamoDB for cart service
  enable_dynamodb = true
  
  # Redis for caching
  enable_elasticache = true
}
```

#### 2. Amazon ECS Deployment
```hcl
module "retail_store_ecs" {
  source = "./terraform/ecs/default"
  
  cluster_name = "retail-store-cluster"
  region       = "us-west-2"
  
  # VPC configuration
  vpc_cidr = "10.0.0.0/16"
  
  # Service configuration
  services = {
    ui = {
      cpu    = 512
      memory = 1024
      port   = 8080
    }
    catalog = {
      cpu    = 256
      memory = 512
      port   = 8080
    }
  }
}
```

#### 3. AWS App Runner Deployment
```hcl
module "retail_store_apprunner" {
  source = "./terraform/apprunner"
  
  region = "us-west-2"
  
  # App Runner services
  services = {
    ui = {
      image_uri = "public.ecr.aws/aws-containers/retail-store-sample-ui:1.0.0"
      port      = "8080"
    }
  }
}
```

### Infrastructure Components
- **VPC**: Network isolation
- **EKS/ECS Clusters**: Container orchestration
- **RDS**: Managed databases
- **DynamoDB**: NoSQL database
- **ElastiCache**: Redis caching
- **Application Load Balancer**: Traffic distribution
- **Route 53**: DNS management
- **CloudWatch**: Monitoring and logging

## DevOps Best Practices

### 1. Environment Management
```bash
# Development
terraform workspace new development
terraform apply -var-file="environments/dev.tfvars"

# Staging
terraform workspace new staging
terraform apply -var-file="environments/staging.tfvars"

# Production
terraform workspace new production
terraform apply -var-file="environments/prod.tfvars"
```

### 2. Secret Management
```yaml
# Using AWS Secrets Manager
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-secrets-manager
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-west-2
```

### 3. Configuration Management
```yaml
# Kustomization for different environments
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base
patchesStrategicMerge:
  - deployment-patch.yaml
images:
  - name: retail-ui
    newTag: v1.2.3
```

### 4. Database Migrations
```bash
# Flyway for Java services
flyway -url=jdbc:mysql://localhost:3306/catalog -user=root migrate

# Liquibase alternative
liquibase --changeLogFile=changelog.xml update
```

## Monitoring and Observability

### Prometheus Metrics
All services expose metrics at `/actuator/prometheus` (Java) or `/metrics` (Go/Node.js):

```yaml
# Prometheus configuration
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'retail-store'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
```

### OpenTelemetry Tracing
```yaml
# OTLP configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: otel-config
data:
  config.yaml: |
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317
    exporters:
      jaeger:
        endpoint: jaeger-collector:14250
```

### Grafana Dashboards
- **Application Performance**: Response times, error rates
- **Infrastructure**: CPU, memory, network usage
- **Business Metrics**: Orders, revenue, user activity

## Security Considerations

### 1. Container Security
```dockerfile
# Use specific versions
FROM openjdk:17.0.2-jre-slim

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser

# Scan for vulnerabilities
RUN apt-get update && apt-get upgrade -y
```

### 2. Kubernetes Security
```yaml
# Pod Security Standards
apiVersion: v1
kind: Namespace
metadata:
  name: retail-store
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

### 3. Network Policies
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: retail-store-netpol
spec:
  podSelector:
    matchLabels:
      app: retail-store
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: retail-store
```

## Scaling and Performance

### 1. Horizontal Scaling
```yaml
# HPA based on custom metrics
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: ui-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ui
  minReplicas: 3
  maxReplicas: 50
  metrics:
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: "100"
```

### 2. Vertical Scaling
```yaml
# VPA for automatic resource adjustment
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: ui-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ui
  updatePolicy:
    updateMode: "Auto"
```

### 3. Database Scaling
```hcl
# RDS with read replicas
resource "aws_db_instance" "catalog_replica" {
  count = 2
  
  identifier = "catalog-replica-${count.index}"
  replicate_source_db = aws_db_instance.catalog.id
  instance_class = "db.t3.medium"
  
  tags = {
    Name = "Catalog DB Replica ${count.index}"
  }
}
```

## Load Testing

### Built-in Load Generator
```bash
# Run load test
kubectl apply -f https://github.com/aws-containers/retail-store-sample-app/releases/latest/download/load-generator.yaml

# Monitor results
kubectl logs -f deployment/load-generator
```

### Custom Load Testing with K6
```javascript
import http from 'k6/http';
import { check } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 100 },
    { duration: '5m', target: 100 },
    { duration: '2m', target: 200 },
    { duration: '5m', target: 200 },
    { duration: '2m', target: 0 },
  ],
};

export default function () {
  let response = http.get('http://retail-store-ui/');
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
}
```

## Next Steps and Advanced Implementations

### 1. Service Mesh Implementation
- Deploy Istio for advanced traffic management
- Implement circuit breakers and retry policies
- Add mutual TLS between services

### 2. Advanced CI/CD
- Implement blue-green deployments
- Add canary releases with Flagger
- Integrate security scanning in pipeline

### 3. Multi-Region Deployment
- Deploy across multiple AWS regions
- Implement cross-region database replication
- Add global load balancing with Route 53

### 4. Cost Optimization
- Implement Spot instances for non-critical workloads
- Use AWS Fargate Spot for ECS tasks
- Implement resource right-sizing based on metrics

### 5. Disaster Recovery
- Implement automated backups
- Create disaster recovery runbooks
- Test recovery procedures regularly

This comprehensive guide provides a foundation for understanding and extending the retail store application with modern DevOps practices. Each section can be expanded based on specific requirements and use cases.
