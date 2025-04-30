# Use ubuntu:22.04 for multi-arch support (ARM64 and AMD64)
FROM ubuntu:22.04

# Set non-interactive frontend to avoid prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies for OpenVPN and MMT
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    build-essential \
    libpcap-dev \
    libconfuse-dev \
    libxml2-dev \
    net-tools \
    openssl \
    netcat-openbsd

# Clone and build mmt-dpi
RUN git clone https://github.com/Montimage/mmt-dpi.git /mmt-dpi && \
    cd /mmt-dpi/sdk && \
    make && make install

# Clone and build mmt-security
RUN git clone https://github.com/Montimage/mmt-security.git /mmt-security && \
    cd /mmt-security && \
    make && make install && make sample_rules

# Clone and build mmt-probe
RUN git clone https://github.com/Montimage/mmt-probe.git /mmt-probe && \
    cd /mmt-probe && \
    make SECURITY_MODULE=1 && make install

# Copy entrypoint script and make it executable
COPY mmt-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mmt-entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/mmt-entrypoint.sh"]