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
