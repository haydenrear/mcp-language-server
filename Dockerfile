FROM alpine:3.20 AS builder

# Install system dependencies
RUN apk add --no-cache \
    bash \
    curl \
    git \
    openjdk21-jdk \
    python3 \
    python3-dev \
    py3-pip \
    nodejs \
    npm \
    cargo \
    ca-certificates

RUN npm install -g pyright

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk
ENV PATH="$JAVA_HOME/bin:$PATH"

# Install Rust toolchain properly
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && . ~/.cargo/env \
    && rustup component add rust-analyzer

# Add Rust to PATH
ENV PATH="/root/.cargo/bin:$PATH"

# Install Java language server (Eclipse JDT Language Server)
RUN curl -L -o jdt-language-server.tar.gz "https://www.eclipse.org/downloads/download.php?file=/jdtls/milestones/1.9.0/jdt-language-server-1.9.0-202203031534.tar.gz"
RUN mkdir -p /opt/jdt-language-server
RUN cp jdt-language-server.tar.gz /opt/jdt-language-server
RUN tar -xzf /jdt-language-server.tar.gz -C /opt/jdt-language-server

FROM golang:1.24-alpine AS go_builder
COPY --from=builder /opt/jdt-language-server /opt/jdt-language-server

# Install build dependencies
RUN apk add --no-cache git

# Set working directory
WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN go build -o mcp-language-server .

FROM alpine:3.20
COPY --from=go_builder /opt/jdt-language-server /opt/jdt-language-server
COPY --from=builder / /
COPY --from=go_builder /app /usr/local/bin


# Add Rust to PATH
ENV PATH="/root/.cargo/bin:$PATH"
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk
ENV PATH="$JAVA_HOME/bin:$PATH"
ENV PATH="/root/.cargo/bin:$PATH"
RUN . ~/.cargo/env \
    && rustup component add rust-analyzer

# Create workspace directory
RUN mkdir -p /workspace

# Set working directory
WORKDIR /workspace

# Default command
ENTRYPOINT ["/usr/local/bin/mcp-language-server"]
