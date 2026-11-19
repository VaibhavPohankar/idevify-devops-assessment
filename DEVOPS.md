# DevOps Setup and Deployment Guide

## 1. Project Overview

This project containerizes a full-stack application consisting of:

- **Frontend:** React, Vite and TypeScript
- **Backend:** Django 6.0 REST API
- **Containerization:** Docker
- **Orchestration:** Docker Compose
- **CI/CD:** Jenkins
- **Container Registry:** Docker Hub
- **Deployment:** Local machine using Docker Compose

The objective is to build, publish and deploy the frontend and backend through an automated CI/CD pipeline.

## 2. Architecture

1. Developers push code to the GitHub `main` branch.
2. Jenkins checks out the latest source code.
3. Jenkins builds separate frontend and backend Docker images.
4. Jenkins authenticates with Docker Hub.
5. Jenkins pushes both images to Docker Hub.
6. Jenkins pulls the published images and deploys them using Docker Compose.

## 3. Project Structure

```text
IDEVIFY APP/
├── backend/
│   ├── Dockerfile
│   ├── .dockerignore
│   └── Django application files
├── frontend/
│   ├── Dockerfile
│   ├── .dockerignore
│   ├── nginx.conf
│   └── React application files
├── docker-compose.yml
├── Jenkinsfile
├── .gitignore
└── DEVOPS.md
```

## 4. Docker Implementation

### Backend

- Uses a multi-stage Docker build.
- Python dependencies are installed in a builder stage.
- Uses a lightweight Python runtime image.
- Runs the application as a non-root `django` user.
- Exposes port `8000`.

### Frontend

- Uses a multi-stage Docker build.
- Builds the React application using Node.js.
- Serves the production build through Nginx.
- Uses the unprivileged Nginx image.
- Runs as a non-root user.
- Exposes port `8080` inside the container.

### Docker Compose

Docker Compose manages both services.

| Service | Container port | Local port |
|---|---:|---:|
| Backend | 8000 | 8000 |
| Frontend | 8080 | 8082 |

The frontend uses Nginx as a reverse proxy to communicate with the Django backend through the Docker Compose network.

### Running Locally

Prerequisites:
- Docker Desktop
- Docker Compose

1. Clone the repository.
2. Create the backend environment file at `backend/.env` with the required Django configuration.
3. Start the application:

```bash
docker compose up -d --build
```

4. Check running containers:

```bash
docker compose ps
```

5. Access the application:

```text
http://localhost:8082
```

6. Stop the application:

```bash
docker compose down
```

Do not commit `.env` files or expose secret values in source control.

## 5. Jenkins CI/CD Pipeline

The Jenkins pipeline is defined in the root `Jenkinsfile`.

### Pipeline stages

1. **Checkout:** Retrieves source code from GitHub.
2. **Build Backend:** Builds the Django Docker image.
3. **Build Frontend:** Builds the React Docker image.
4. **Login to Docker Hub:** Uses Jenkins credentials.
5. **Push Images:** Publishes both images to Docker Hub.
6. **Deploy Locally:** Retrieves the published images and updates the running Docker Compose application.

### Docker Hub repositories

- `dockervibh/idevify-backend`
- `dockervibh/idevify-frontend`

Both images are currently published using the `latest` tag.

### Jenkins credentials

The pipeline uses Jenkins credentials rather than hardcoding authentication details:

| Credential ID | Type | Purpose |
|---|---|---|
| `dockerhub-credentials` | Username with password | Docker Hub authentication |
| `backend-env-file` | Secret file | Backend environment configuration |

### Automatic triggering

Jenkins uses Poll SCM to check the GitHub repository for changes to the `main` branch.

Configured schedule:

```text
H/2 * * * *
```

This checks for changes approximately every two minutes.

## 6. Security Practices

- Separate frontend and backend Docker images.
- Multi-stage builds to reduce runtime image size.
- Non-root users in both containers.
- `.dockerignore` files to exclude unnecessary files from build contexts.
- Environment variables for backend configuration.
- Secrets are excluded from Git using `.gitignore`.
- Jenkins credentials are used for Docker Hub authentication and backend environment configuration.

## 7. Troubleshooting Log

### Issue 1: Nginx returned 404 for API requests

**Cause:** The custom Nginx configuration was not copied into the frontend Docker image.

**Resolution:** Added the Nginx configuration file to the frontend Dockerfile and rebuilt the image. The frontend could then successfully communicate with the backend.

### Issue 2: Docker Hub image pull failure

**Cause:** The Docker Compose file referenced local image names instead of the published Docker Hub repositories.

**Resolution:** Updated the image references to:

```text
dockervibh/idevify-backend:latest
dockervibh/idevify-frontend:latest
```

Committed and pushed the changes to GitHub.

### Issue 3: Port 8000 already allocated during Jenkins deployment

**Cause:** Jenkins created a separate Compose project, attempting to start another backend container while the existing local backend already occupied port 8000.

**Resolution:** Updated the Jenkins deployment commands to use the existing Compose project name:

```bash
docker compose -p idevifyapp pull
docker compose -p idevifyapp up -d --no-build
```

This allowed Jenkins to update the existing deployment rather than creating a second set of containers.

## 8. Verification

The following checks were performed:

- Backend API returned a successful response.
- React frontend displayed the Django API response.
- Both Docker Compose services were running.
- Backend ran as the non-root `django` user.
- Frontend ran as the non-root `nginx` user.
- Docker images were successfully pushed to Docker Hub.
- Jenkins pipeline completed successfully.
- Jenkins deployment updated the running local application.

## 9. Deployment Scope and Future Improvements

The current implementation uses local Docker Compose deployment through Jenkins.

Cloud deployment to AWS EC2 is a potential extension. If implemented, Terraform will be used to provision the EC2 instance and its security group, and Jenkins will deploy the Docker Hub images to that instance.

HTTPS and a production-grade Django application server can also be introduced as further improvements.