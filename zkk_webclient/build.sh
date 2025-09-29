#!/bin/bash

# Build script for the zk-Kerberos WebClient

echo "Building zk-Kerberos WebClient..."

# Check if wasm-pack is installed
if ! command -v wasm-pack &> /dev/null; then
    echo "wasm-pack is not installed. Installing..."
    curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh
fi

# Build the WASM package
echo "Building WASM package..."
wasm-pack build --target web --out-dir pkg

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo "You can now serve the application using a local server."
    echo "For example:"
    echo "  python3 -m http.server 8000"
    echo "  # or"
    echo "  npx serve ."
    echo ""
    echo "Then open http://localhost:8000 in your browser."
else
    echo "Build failed!"
    exit 1
fi