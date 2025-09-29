#!/bin/bash

# Transfer script for JNI libraries
set -e  # Exit on any error

echo "Transferring JNI libraries..."

# Define paths (updated for parent directory)
SOURCE_DIR="mopro-r0-example-app/MoproAndroidBindings/jniLibs/arm64-v8a"
TARGET_DIR="mopro-r0-example-app/flutter/android/app/src/main/jniLibs/arm64-v8a"

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory $SOURCE_DIR does not exist"
    exit 1
fi

# Remove existing target directory
if [ -d "$TARGET_DIR" ]; then
    echo "Removing existing target directory..."
    rm -rf "$TARGET_DIR"
fi

# Create target directory
echo "Creating target directory..."
mkdir -p "$TARGET_DIR"

# Copy files
echo "Copying JNI libraries..."
cp -r "$SOURCE_DIR"/* "$TARGET_DIR/"

# Sanity check
echo "Sanity check - files in target directory:"
ls -la "$TARGET_DIR"

echo "Transfer completed successfully!"
