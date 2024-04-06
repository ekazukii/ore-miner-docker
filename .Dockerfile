# Use the official Rust image as the base image
FROM rust:latest

# Set the working directory
WORKDIR /usr/src/app

# Install necessary packages for building and running Solana
RUN apt-get update && apt-get install -y \
    libssl-dev \
    libudev-dev \
    pkg-config \
    zlib1g-dev \
    llvm \
    clang \
    make \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Solana CLI tools
RUN sh -c "$(curl -sSfL https://release.solana.com/v1.18.4/install)"

# Add the Solana CLI tools to the PATH
ENV PATH="/root/.local/share/solana/install/active_release/bin:$PATH"

# Install ore-cli
RUN cargo install ore-cli

# Copy the start.sh script from the local directory to the container
COPY start.sh /usr/src/app/start.sh

# Give execution rights to the start.sh script
RUN chmod +x /usr/src/app/start.sh

# Set the script to run when the container starts
ENTRYPOINT ["/usr/src/app/start.sh"]

