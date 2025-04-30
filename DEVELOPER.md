# MMT on Docker - Developer Guide

This document contains information for developers who need to build and maintain the MMT Docker image. For user instructions, please see the [README.md](README.md).

## Building the Image

Build the Docker image with the default name and tag (`montimage/mmt:latest`):

```bash
docker build -t montimage/mmt:latest .
```

Build a multi-architecture image (amd64/arm64):

```bash
docker buildx create --name mybuilder --use
docker buildx build --platform linux/amd64,linux/arm64 -t montimage/mmt:latest .
```

Push the multi-architecture image to a Docker registry:

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t montimage/mmt:v1.0 --push .
```

## Automated Docker Builds with GitHub Actions

This repository includes a GitHub Actions workflow that automatically builds and publishes the Docker image to GitHub Container Registry (GHCR) whenever:

1. Changes are pushed to the main branch that affect the `Dockerfile` or `mmt-entrypoint.sh`
2. A new release is published
3. The workflow is manually triggered

### Accessing the Published Images

The Docker images are published to GitHub Container Registry and can be pulled using:

```bash
docker pull ghcr.io/{owner}/{repo}:latest
```

Replace `{owner}` and `{repo}` with your GitHub username/organization and repository name.

### Available Tags

- `latest`: Points to the most recent build from the default branch
- `v1.0.0`, `v2.0.0`, etc.: When releases are tagged with semantic versioning
- Branch-based tags: Images built from specific branches

### Customizing the Workflow

The workflow configuration is located in `.github/workflows/docker-build.yml`. You can customize it to:

- Change build triggers
- Modify image tags
- Add additional build arguments
- Configure multi-platform builds

## Publishing to Docker Hub

### Step-by-Step Guide

Here's a complete workflow for making changes and publishing a new image to Docker Hub:

1. **Make your changes**:
   ```bash
   # Edit Dockerfile, mmt-entrypoint.sh, or other files as needed
   vim Dockerfile
   vim mmt-entrypoint.sh
   ```

2. **Test your changes locally**:
   ```bash
   # Build a test image
   docker build -t montimage/mmt:test .
   
   # Run and test the container
   docker run -d --name mmt-test montimage/mmt:test
   docker logs mmt-test
   docker exec -it mmt-test /bin/sh  # For interactive testing
   docker stop mmt-test
   ```

3. **Commit your changes to Git**:
   ```bash
   # Add modified files
   git add Dockerfile mmt-entrypoint.sh
   
   # Commit with a descriptive message
   git commit -m "Description of your changes"
   ```

4. **Create a version tag** (optional but recommended):
   ```bash
   # Format: v1.0.0, v1.1.0, etc.
   git tag -a v1.0.0 -m "Version 1.0.0"
   ```

5. **Push changes to GitHub**:
   ```bash
   # Push commits
   git push origin main
   
   # Push tags if you created any
   git push origin --tags
   ```

6. **Log in to Docker Hub**:
   ```bash
   docker login
   # Enter your Docker Hub username and password when prompted
   ```

7. **Build and push the image to Docker Hub**:
   ```bash
   # For single architecture
   docker build -t montimage/mmt:latest -t montimage/mmt:v1.0.0 .
   docker push montimage/mmt:latest
   docker push montimage/mmt:v1.0.0
   
   # For multi-architecture build
   docker buildx create --name mmt-builder --use
   docker buildx build --platform linux/amd64,linux/arm64 \
     -t montimage/mmt:latest -t montimage/mmt:v1.0.0 \
     --push .
   ```

8. **Verify the published image**:
   - Visit [Docker Hub](https://hub.docker.com/) and check your repository
   - Pull and test the image from a different machine:
     ```bash
     docker pull montimage/mmt:latest
     ```

### Automated Publishing to Docker Hub

To set up automated builds to Docker Hub (in addition to GitHub Container Registry):

1. Add Docker Hub credentials to GitHub repository secrets:
   - Go to repository Settings → Secrets → Actions
   - Add `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets

2. Update the GitHub Actions workflow file (`.github/workflows/docker-build.yml`) to include Docker Hub:
   ```yaml
   - name: Log in to Docker Hub
     uses: docker/login-action@v2
     with:
       username: ${{ secrets.DOCKERHUB_USERNAME }}
       password: ${{ secrets.DOCKERHUB_TOKEN }}
   
   - name: Build and push
     uses: docker/build-push-action@v4
     with:
       context: .
       platforms: linux/amd64,linux/arm64
       push: true
       tags: |
         montimage/mmt:latest
         montimage/mmt:${{ steps.meta.outputs.version }}
         ghcr.io/${{ env.IMAGE_NAME }}:latest
         ghcr.io/${{ env.IMAGE_NAME }}:${{ steps.meta.outputs.version }}
   ```

## Project Structure

The project consists of the following key files:

- `Dockerfile`: Defines how the MMT container image is built
- `mmt-entrypoint.sh`: Entry point script that sets up and runs the MMT probe
- `README.md`: User documentation

## Customization

You can modify the following files:

- `Dockerfile`: Customize the build process
- `mmt-entrypoint.sh`: Change how MMT is executed inside the container

## How It Works

The container uses `netcat` to receive network traffic from the host machine on port 12345, and then pipes that to the `mmt-probe` application for analysis.

The container can operate in two modes:
1. **Host Network Interface Mode**: When launched with `--interface=INTERFACE_NAME`, the container will directly capture traffic from the specified host network interface. This requires running with `--net=host` privileges.
2. **Netcat Mode**: By default, the container captures traffic from the host machine through a netcat connection on port 12345. The traffic is then analyzed by MMT tools inside the container.

In both modes, analysis results are stored in the mounted reports directory.

## License

This project is distributed under the terms of the license covering Montimage products.

## Contributing

For any issues or improvements, please contact Montimage.
