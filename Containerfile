# ==========================================
# STAGE 1: Shared System Dependencies
# ==========================================
FROM rust:1 AS base-env
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# ==========================================
# STAGE 2: Development Environment
# ==========================================
FROM base-env AS developmental
RUN rustup component add clippy rustfmt
# 1. Create a non-root user named 'spidrling' with a home directory
RUN useradd -m -s /bin/bash spidrling

# 2. Set up the workspace directory and give the 'spidrling' user full ownership
WORKDIR /workspace
RUN chown -R spidrling:spidrling /workspace

# 3. Tell the container to default to running as the 'spidrling' user
USER spidrling

# ==========================================
# STAGE 3: The Builder (Compiles everything)
# ==========================================
FROM developmental AS builder
COPY . .
# Compile the entire workspace for release
RUN cargo build --release

# ==========================================
# STAGE 4: Release Image for Service Alpha
# ==========================================
FROM gcr.io/distroless/cc-debian12 AS release-alpha
WORKDIR /app
COPY --from=builder /workspace/target/release/service-alpha /app/service-alpha
ENTRYPOINT ["/app/service-alpha"]

# ==========================================
# STAGE 5: Release Image for Service Beta
# ==========================================
FROM gcr.io/distroless/cc-debian12 AS release-beta
WORKDIR /app
COPY --from=builder /workspace/target/release/service-beta /app/service-beta
ENTRYPOINT ["/app/service-beta"]