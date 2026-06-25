FROM debian:bookworm-slim

# Install dependencies including Rust and Node.js for building ffplayout
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    ffmpeg \
    pkg-config \
    libssl-dev \
    build-essential \
    git \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20 from NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Create ffplayout user
RUN useradd -r -s /bin/false ffpu

# Clone and build ffplayout from source
RUN git clone https://github.com/ffplayout/ffplayout.git /tmp/ffplayout && \
    cd /tmp/ffplayout && \
    cargo build --release && \
    cp target/release/ffplayout /usr/local/bin/ && \
    rm -rf /tmp/ffplayout

# Create necessary directories
RUN mkdir -p /etc/ffplayout /var/log/ffplayout /usr/share/ffplayout/public /tv-media /playlists

# Set ownership
RUN chown -R ffpu:ffpu /etc/ffplayout /var/log/ffplayout /usr/share/ffplayout /tv-media /playlists

# Copy public assets (if available)
COPY public/ /usr/share/ffplayout/public/

# Expose ports
EXPOSE 8787

# Switch to ffplayout user
USER ffpu

CMD ["ffplayout"]
