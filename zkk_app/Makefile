# Makefile

# Environment for OpenSSL cross-compilation
export OPENSSL_STATIC=1
export PKG_CONFIG_ALLOW_CROSS=1

.PHONY: all mopro transfer flutter circuit clean

all: mopro transfer flutter

mopro:
	@echo "Running mopro build and update..."
	cd mopro-r0-example-app && mopro build
	cd mopro-r0-example-app && mopro update

transfer:
	@echo "Transferring JNI libraries..."
	@chmod +x transfer.sh
	@./transfer.sh

flutter:
	@echo "Running flutter pub get and build..."
	cd mopro-r0-example-app/flutter && flutter pub get && flutter run

circuit:
	@echo "Running RISC0 circuit..."
	cd risc0-circuit && RUST_LOG=debug cargo run

clean:
	@echo "Cleaning up..."
	rm -rf mopro-r0-example-app/flutter/android/app/src/main/jniLibs/arm64-v8a/
	cd mopro-r0-example-app/flutter && flutter clean
