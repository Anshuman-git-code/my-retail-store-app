#!/bin/bash

# Simple startup script for local development
# This script makes it easy to start the retail store application

echo "🚀 Starting Retail Store Application Locally"
echo "============================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose is not installed. Please install Docker Compose."
    exit 1
fi

# Set default password if not provided
if [ -z "$DB_PASSWORD" ]; then
    export DB_PASSWORD="mypassword123"
    echo "📝 Using default database password: $DB_PASSWORD"
fi

echo "🔧 Starting all services..."
echo "   - UI (Frontend): http://localhost:8888"
echo "   - MySQL Database: localhost:3306"
echo "   - DynamoDB Local: localhost:8000"
echo ""

# Start the application
docker-compose -f docker-compose-simple.yml up

echo ""
echo "🛑 Application stopped."
echo "💡 To clean up completely, run: docker-compose -f docker-compose-simple.yml down -v"
