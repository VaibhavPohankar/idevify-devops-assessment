# DevOps Setup and Deployment Guide

## 1. Project Overview

This project containerizes a full-stack application consisting of:

- **Frontend:** React, Vite and TypeScript
- **Backend:** Django 6.0 API
- **Web Server:** Nginx
- **Containerization:** Docker
- **Orchestration:** Docker Compose
- **CI/CD:** Jenkins and GitHub Actions
- **Container Registry:** Docker Hub
- **Infrastructure as Code:** Terraform
- **Cloud Deployment:** AWS EC2

The objective is to build, publish and deploy the frontend and backend using containerization and CI/CD practices.

## 2. Architecture

1. Source code is maintained in GitHub.
2. Jenkins checks out the latest source code.
3. Jenkins builds separate frontend and backend Docker images.
4. Jenkins authenticates with Docker Hub and publishes both images.
5. Jenkins updates the local Docker Compose deployment.
6. GitHub Actions provides an additional automated image build and publishing workflow.
7. Terraform provisions AWS EC2 infrastructure and its security group.
8. Docker Compose runs the application containers on EC2.

The AWS deployment currently uses a manual image pull and Docker Compose update. Jenkins is not configured to deploy directly to EC2.

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
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── .gitignore
├── .github/
│   └── workflows/
│       └── docker-build-push.yml
├── Screenshots/
├── docker-compose.yml
├── docker-compose.prod.yml
├── Jenkinsfile
├── README.md
└── DEVOPS.md
```

## 4. Docker Implementation

### Backend

- Uses a multi-stage Docker build.
- Python dependencies are installed in a builder stage.
- Uses a lightweight Python runtime image.
- Runs the application as a non-root `django` user.
- Exposes port 8000 internally.

### Frontend

- Uses a multi-stage Docker build.
- Builds the React application using Node.js.
- Serves the production build through Nginx.
- Uses an unprivileged Nginx image.
- Runs as a non-root user.
- Exposes port 8080 inside the container.

### Docker Compose

Docker Compose manages the frontend and backend services.

| Service | Container port | Local port |
|---|---:|---:|
| Backend | 8000 | 8000 |
| Frontend | 8080 | 8082 |

Nginx acts as a reverse proxy, forwarding `/api/` requests to the Django backend through the Docker Compose network.

### Local Deployment

Prerequisites:
- Docker
- Docker Compose

1. Clone the repository.
2. Configure the backend environment file at `backend/.env`.
3. Start the application:

```bash
docker compose up -d --build
```

4. Check containers:

```bash
docker compose ps
```

5. Access:
   - Frontend: http://localhost:8082/
   - Backend API: http://localhost:8082/api/hello/

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
6. **Deploy Locally:** Pulls the published images and updates the local Docker Compose application.

### Docker Hub repositories

- `dockervibh/idevify-backend:latest`
- `dockervibh/idevify-frontend:latest`

### Jenkins credentials

| Credential ID | Type | Purpose |
|---|---|---|
| `dockerhub-credentials` | Username with password | Docker Hub authentication |
| `backend-env-file` | Secret file | Backend environment configuration |

### Automatic triggering

Jenkins uses Poll SCM to check the GitHub repository for changes.

Configured schedule:

```text
H/2 * * * *
```

This checks for changes approximately every two minutes.

## 6. GitHub Actions

The workflow is located at:

`.github/workflows/docker-build-push.yml`

It automatically builds and pushes the frontend and backend Docker images to Docker Hub when changes are pushed to the `main` branch.

Required GitHub repository secrets:

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

GitHub Actions handles image publishing; it does not currently deploy the application to EC2.

## 7. AWS EC2 Deployment

The application is deployed on an Ubuntu 24.04 EC2 instance in the AWS Mumbai region (`ap-south-1`).

### Infrastructure

- Instance type: `t3.micro`
- Operating system: Ubuntu 24.04
- Container runtime: Docker
- Orchestration: Docker Compose
- Public application port: 80

### Production deployment

The production Compose configuration uses the published Docker Hub images.

Pull the latest images:

```bash
sudo docker compose -f docker-compose.prod.yml pull
```

Start or update the application:

```bash
sudo docker compose -f docker-compose.prod.yml up -d
```

Check deployment status:

```bash
sudo docker compose -f docker-compose.prod.yml ps
```

The backend environment file is maintained separately at `backend/.env` on the EC2 instance.

### Application URLs

- Frontend: http://3.108.215.41/
- Backend API: http://3.108.215.41/api/hello/

The frontend is publicly accessible through Nginx on port 80. The backend is accessible internally through the Docker Compose network.

The deployment currently uses HTTP. TLS termination and HTTPS are not configured.

## 8. Infrastructure as Code – Terraform

Terraform configuration is maintained in the `terraform/` directory.

It provisions:

- Ubuntu 24.04 EC2 instance (`t3.micro`)
- AWS security group
- SSH ingress restricted through a configurable CIDR
- HTTP ingress on port 80
- HTTPS ingress on port 443

### Initialize and deploy

```bash
cd terraform
terraform init
terraform validate
terraform plan -var="allowed_ssh_cidr=YOUR_PUBLIC_IP/32"
terraform apply -var="allowed_ssh_cidr=YOUR_PUBLIC_IP/32"
```

### Destroy infrastructure

When the deployment is no longer required:

```bash
terraform destroy -var="allowed_ssh_cidr=YOUR_PUBLIC_IP/32"
```

Terraform state files, provider directories and variable files containing local configuration are excluded from Git.

## 9. Security Practices

- Separate frontend and backend Docker images.
- Multi-stage builds to reduce runtime image size.
- Non-root users in application containers.
- `.dockerignore` files to exclude unnecessary build-context files.
- Environment variables for backend configuration.
- Secrets excluded from Git.
- Jenkins credentials used for Docker Hub authentication.
- Backend is not directly exposed to the public internet.
- SSH access is restricted through a configurable CIDR.

HTTPS is not currently configured, despite the security group allowing inbound port 443.

## 10. Troubleshooting Log

### Issue 1: Nginx returned 404 for API requests

**Cause:** The custom Nginx configuration was not copied into the frontend Docker image.

**Resolution:** Added the Nginx configuration file to the frontend Dockerfile and rebuilt the image. The frontend could then successfully communicate with the backend.

### Issue 2: Docker Hub image pull failure

**Cause:** Docker Compose referenced local image names instead of the published Docker Hub repositories.

**Resolution:** Updated the image references to:

```text
dockervibh/idevify-backend:latest
dockervibh/idevify-frontend:latest
```

### Issue 3: Port 8000 already allocated during Jenkins deployment

**Cause:** Jenkins created a separate Compose project, attempting to start another backend container while the existing local backend already occupied port 8000.

**Resolution:** Updated the Jenkins deployment commands to use the existing Compose project name:

```bash
docker compose -p idevifyapp pull
docker compose -p idevifyapp up -d --no-build
```

### Issue 4: Django DisallowedHost error on EC2

**Cause:** The EC2 public IP was not included in Django's `ALLOWED_HOSTS` configuration.

**Resolution:** Added the EC2 public IP to `ALLOWED_HOSTS` in the backend environment file and recreated the containers.

## 11. Verification

The following checks were performed:

- Backend API returned a successful JSON response.
- Frontend successfully displayed the application.
- Both Docker Compose services were running on EC2.
- Backend ran as a non-root `django` user.
- Frontend ran as a non-root Nginx user.
- Docker images were successfully pushed to Docker Hub.
- Jenkins pipeline completed successfully.
- GitHub Actions workflow completed successfully.
- AWS EC2 deployment was accessible through the public IP.
- Terraform configuration was initialized and validated.
