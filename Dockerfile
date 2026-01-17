# Use Ubuntu as base image
FROM ubuntu:24.04

# Install required dependencies
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    bash \
    tar \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Cursor CLI
RUN curl https://cursor.com/install -fsS | bash

# Download Gitea MCP Server
RUN mkdir -p /tmp/gitea-mcp && \
    cd /tmp/gitea-mcp && \
    curl -L "https://gitea.com/gitea/gitea-mcp/releases/download/v0.7.0/gitea-mcp_Linux_x86_64.tar.gz" -o gitea-mcp.tar.gz && \
    tar -xzf gitea-mcp.tar.gz && \
    chmod +x gitea-mcp && \
    rm gitea-mcp.tar.gz

# Copy the run script and make it executable
COPY scripts/run-cursor-docker.sh /usr/local/bin/run-cursor.sh
RUN chmod +x /usr/local/bin/run-cursor.sh

# Set environment variables
ENV PATH="$PATH:/root/.local/bin"
ENV HOME=/root

# Set working directory
WORKDIR /workspace

RUN mkdir -p "$HOME/.cursor"

ENTRYPOINT ["/usr/local/bin/run-cursor.sh"]