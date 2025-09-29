# Makefile

# Environment for OpenSSL cross-compilation
export OPENSSL_STATIC=1
export PKG_CONFIG_ALLOW_CROSS=1

.PHONY: all mopro transfer flutter circuit clean

all: mopro transfer flutter

mopro:
	@echo "Running mopro build and update..."
	mopro build
	mopro update

transfer:
	@echo "Transferring JNI libraries..."
	@chmod +x transfer.sh
	@./transfer.sh

flutter:
	@echo "Running flutter pub get and build..."
	cd flutter && flutter pub get && flutter run

circuit:
	@echo "Running RISC0 circuit..."
	cd .. && RUST_LOG=debug cargo run

clean:
	@echo "Cleaning up..."
	rm -rf flutter/android/app/src/main/jniLibs/arm64-v8a/
	cd flutter && flutter clean
