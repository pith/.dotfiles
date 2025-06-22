#!/usr/bin/env zsh

install_rust_if_needed() {
    # Check if Rust is already installed
    if command -v rustc &> /dev/null; then
        return 0
    fi
    
    echo "Rust not found. Installing..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    
    # Source the cargo environment
    source ~/.cargo/env
    
    echo "Rust installation complete!"
    rustc --version
    cargo --version
}

install_rust_if_needed

