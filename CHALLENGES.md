# Challenges Faced and Resolutions

During the DevOps assignment, I encountered the following issues:

### 1. Nginx API 404 Error
**Issue:** The frontend could not access the Django API because the custom Nginx configuration was missing from the frontend image.

**Resolution:** Updated the frontend Dockerfile to copy the custom Nginx configuration and rebuilt the image.

### 2. Docker Hub Image Pull Error
**Issue:** Docker Compose returned an access-denied error while pulling images.

**Resolution:** Updated the image references in `docker-compose.yml` to use the complete Docker Hub repository names.

### 3. Port 8000 Already Allocated
**Issue:** Jenkins deployment failed because another Compose project was attempting to use port 8000.

**Resolution:** Used the existing Compose project name `idevifyapp` and deployed using `docker compose -p idevifyapp up -d --no-build`.

### Conclusion
These issues helped me understand Docker image configuration, container networking, Nginx reverse proxy configuration, and managing deployments through Docker Compose and Jenkins.