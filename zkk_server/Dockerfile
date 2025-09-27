# Build stage
FROM rust:1.75 as builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Cargo files first
COPY Cargo.toml Cargo.lock ./

# Build dependencies with a dummy main.rs (for caching)
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release || true

# Remove dummy and copy real source
RUN rm -rf src
COPY src/ src/

# Final build
RUN cargo build --release

# Runtime stage
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd --create-home --shell /bin/bash app
WORKDIR /app

# Copy binary from builder stage
# Make sure this name matches your Cargo.toml [package] name!
COPY --from=builder /app/target/release/zkk_server /app/zkk_server

# Change ownership and switch user
RUN chown -R app:app /app
USER app

# Expose server port
EXPOSE 7878

# Run the binary
CMD ["./zkk_server"]

