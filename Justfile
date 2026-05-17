# Set standard bash as the execution shell for just recipes
set shell := ["/bin/bash", "-c"]

# Set a default recipe if someone just types `just`
default:
    @just --list

# -----------------------------------------------------------------------------
# Development & Execution
# -----------------------------------------------------------------------------

# Run a specific service (e.g., `just run api_service`)
run service:
    cargo run --bin {{service}}

# Run all services concurrently for local integration testing
run-all:
    @echo "Starting all microservices concurrently..."
    cargo run --bin service-alpha & \
    cargo run --bin service-beta & \
    wait

# Watch a specific service and hot-reload on save
watch service:
    cargo watch -x "run --bin {{service}}"

# Watch all services simultaneously using concurrently
watch-all:
    concurrently \
        --names "API,WORKER" \
        --prefix "name" \
        --prefix-colors "cyan,magenta" \
        "cargo watch -x 'run --bin service-alpha'" \
        "cargo watch -x 'run --bin service-beta'"

# -----------------------------------------------------------------------------
# Testing & Code Quality
# -----------------------------------------------------------------------------

# Run the test suite using the fast nextest runner
test:
    cargo nextest run

# Run clippy linter and check for idiomatic compiler warnings
lint:
    cargo clippy --all-targets -- -D warnings

# Check code formatting across the entire workspace
fmt:
    cargo fmt --all -- --check

# -----------------------------------------------------------------------------
# Podman & Production Builds
# -----------------------------------------------------------------------------

# Build the release image targeting the production stage
build-image:
    podman build -t rust-service-prod:latest -f Containerfile .

# Clean target directory and purge container build caches
nuke:
    cargo clean
    podman system prune -f