# DevOps Assessment – Full-Stack Application

A containerized full-stack application built using Django and React, deployed on AWS EC2 using Docker Compose.

## Live Deployment

- **Frontend:** http://3.108.215.41/
- **Backend API:** http://3.108.215.41/api/hello/
- **Cloud:** AWS EC2 – Mumbai (`ap-south-1`)
- **Container Registry:** Docker Hub

## Technology Stack

| Component | Technology |
|---|---|
| Backend | Django 6.0 |
| Frontend | React, Vite, TypeScript |
| Web Server | Nginx |
| Containers | Docker, Docker Compose |
| CI/CD | Jenkins, GitHub Actions |
| Container Registry | Docker Hub |
| Infrastructure as Code | Terraform |
| Cloud Provider | AWS EC2 |

## Architecture

1. React frontend is served through Nginx.
2. Nginx forwards `/api/` requests to the Django backend.
3. Django exposes the `/api/hello/` endpoint.
4. Docker Compose manages frontend and backend containers.
5. Docker Hub stores the application images.
6. Jenkins automates image building and publishing.
7. GitHub Actions provides an additional automated build and push workflow.
8. Terraform provisions AWS EC2 infrastructure and its security group.

## Docker Images

- Backend: `dockervibh/idevify-backend:latest`
- Frontend: `dockervibh/idevify-frontend:latest`

## Local Deployment

Prerequisites:
- Docker
- Docker Compose

Configure the backend environment file at `backend/.env`.

Start the application:

```bash
docker compose up -d --build
```

Access:
- Frontend: http://localhost:8082/
- Backend API: http://localhost:8082/api/hello/

Stop the application:

```bash
docker compose down
```

## AWS Deployment

The application is deployed on an Ubuntu EC2 instance using Docker Compose.

Production deployment uses the prebuilt Docker Hub images:

```bash
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d
```

The backend environment file must be configured at `backend/.env` on the EC2 instance.

Access the application through the public EC2 IP listed above.

## Infrastructure as Code

Terraform configuration is available in the `terraform/` directory.

It provisions:
- Ubuntu 24.04 EC2 instance (`t3.micro`)
- Security group
- SSH access restricted by configurable CIDR
- HTTP (80) and HTTPS (443) inbound rules

Initialize and deploy:

```bash
cd terraform
terraform init
terraform plan -var="allowed_ssh_cidr=YOUR_PUBLIC_IP/32"
terraform apply -var="allowed_ssh_cidr=YOUR_PUBLIC_IP/32"
```

Destroy infrastructure when no longer required:

```bash
terraform destroy -var="allowed_ssh_cidr=YOUR_PUBLIC_IP/32"
```

## CI/CD

### Jenkins
The Jenkins pipeline performs:
- Source code checkout
- Backend and frontend image builds
- Docker Hub authentication
- Image publishing
- Local Docker Compose deployment

### GitHub Actions
The workflow in `.github/workflows/docker-build-push.yml` automatically builds and pushes both Docker images when changes are pushed to `main`.

Required GitHub repository secrets:
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

## Repository Structure

```text
.
├── backend/
├── frontend/
├── terraform/
├── .github/workflows/
├── Screenshots/
├── Dockerfile
├── docker-compose.yml
├── docker-compose.prod.yml
├── Jenkinsfile
├── DEVOPS.md
└── README.md
```

## Security Notes

- Backend environment variables are excluded from Git.
- Terraform state and local provider files are excluded from Git.
- EC2 SSH access is restricted through a configurable CIDR.
- Backend is not directly exposed to the public internet.
- HTTPS ingress is configured in the security group, but TLS termination is not yet configured.

## Screenshots

See the `Screenshots/` directory for application, Docker, Jenkins, and GitHub Actions evidence.
