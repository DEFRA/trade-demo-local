# CDP Trade Demo Local

Centralized infrastructure and service orchestration for local development of the CDP Trade Demo services.

## Overview

This project provides a flexible Docker Compose setup that allows you to:

1. Run all infrastructure dependencies (LocalStack, PostgreSQL, MongoDB, Redis, DEFRA ID stub)
2. Run infrastructure + backend services (trade-demo-backend, trade-commodity-codes)
3. Work on individual backend services independently

## Architecture

All services connect via a shared Docker network (`cdp-tenant`), which prevents duplicate containers and port conflicts. Infrastructure is centrally managed here, and individual service projects reference it as external.

## Prerequisites

- Docker and Docker Compose
- For full stack development: Node.js/npm (for frontend)

## Quick Start

### Infrastructure Only

Start all infrastructure dependencies in the background:

```bash
docker compose --profile infra up -d
```

This starts:
- LocalStack (AWS services simulation)
- PostgreSQL (for trade-commodity-codes)
- MongoDB (for trade-demo-backend)
- Redis
- DEFRA ID stub

### Infrastructure + Backend Services

Start everything with fresh builds:

```bash
docker compose --profile services up --build
```

Or run in the background:

```bash
docker compose --profile services up -d
```

This starts all infrastructure plus:
- trade-commodity-codes (with Liquibase migrations)
- trade-demo-backend

### Stop Services

```bash
docker compose down
```

To also remove volumes (fresh start):

```bash
docker compose down -v
```

## Development Workflows

### Full Stack Development

Start infrastructure and backend services, then run the frontend locally:

```bash
# Start everything
cd trade-demo-local
docker compose --profile services up -d

# In another terminal, start the frontend
cd ../trade-demo-frontend
npm run dev
```

### Single Service Development

When working on just one backend service, start infrastructure centrally, then the service individually:

```bash
# Start infrastructure
cd trade-demo-local
docker compose --profile infra up -d

# In another terminal, start your service
cd ../trade-demo-backend  # or ../trade-commodity-codes
docker compose up
```

This allows quick rebuilds of a single service without affecting others:

```bash
# Rebuild and restart just this service
docker compose up --build
```

### Testing Backend Services

Test both backends together without the frontend:

```bash
cd trade-demo-local
docker compose --profile services up --build
```

## Service Ports

### Infrastructure
- LocalStack: 4566 (gateway), 4510-4559 (service range)
- PostgreSQL: 5432
- MongoDB: 27017
- Redis: 6379
- DEFRA ID Stub: 3200

### Backend Services
- trade-demo-backend: 8085 (app), 5006 (debug)
- trade-commodity-codes: 8086 (app), 5005 (debug)

### Frontend (runs outside Docker)
- trade-demo-frontend: 3000 (typical)

## Individual Service Projects

Both `trade-demo-backend` and `trade-commodity-codes` can be run independently:

```bash
# Assumes infrastructure is already running from trade-demo-local
cd trade-demo-backend
docker compose up
```

These projects reference the shared infrastructure via the external `cdp-tenant` network. They will:
- Connect to existing infrastructure if it's running
- Fail with connection errors if infrastructure isn't running (clear feedback to start infra first)
- Never try to create duplicate infrastructure containers

## Environment Variables

Infrastructure services use environment variables from `../compose/aws.env`:
- AWS region, credentials (dummy values for LocalStack)
- LocalStack endpoint configuration

Backend services get environment variables from both:
- `../compose/aws.env` (AWS/LocalStack config)
- Service-specific environment variables defined in compose.yml

## Troubleshooting

### Port conflicts

If you see port binding errors, check for existing services:

```bash
docker ps
lsof -i :4566  # or other port number
```

Stop conflicting containers:

```bash
docker compose down
```

### Network already exists

The `cdp-tenant` network is shared. If you see "network already exists" warnings, this is expected and harmless.

### Services can't connect to infrastructure

Ensure infrastructure is running:

```bash
cd trade-demo-local
docker compose --profile infra ps
```

Check service health:

```bash
docker compose --profile infra ps
```

All infrastructure services should show "healthy" status.

### Fresh start

To completely reset (removes all data):

```bash
docker compose down -v
docker network rm cdp-tenant
docker compose --profile infra up -d
```

## Notes

- Backend services require rebuild for code changes (no hot reload in Docker)
- For faster backend development, consider running services directly with `mvn spring-boot:run`
- Frontend always runs outside Docker with npm for hot reload
- The `--build` flag only rebuilds application services, not infrastructure images
