# ZK-kerberos mobile app


This app generates and verifies zero-knowledge proofs that interacts with zk-kerberos server, provoding ZK proofs

## Architecture

```
├── risc0-circuit/          # RISC0 zkVM ECDSA circuit
│   ├── src/main.rs         # Host program 
│   └── methods/guest/      # Guest program 
├── mopro-r0-example-app/   # Mopro FFI bindings
│   ├── src/lib.rs          # UniFFI exports for mobile 
│   └── flutter/            # Flutter app with ECDSA UI
└── Cargo.toml              # Rust workspace configuration
```

## Disclaimer
Only works for **"aarch64-linux-android 64-bit ARM devices (modern Android smartphones/tablets)"**
will not work for android emulators

## Prerequisites

Install required tools:

```bash
# Install the latest Mopro CLI
git clone git@github.com:zkmopro/mopro.git
cd cli && cargo install --path .

mopro --version
flutter --version
```

## Quick Start

1. **Clone and setup**:
```bash
# Clone this ECDSA example repository
cd zkk_app/mopro-r0-example-app
```

2. **Use make file**:
```bash
# Direct makeFile
make
```

**OR**

2. **Build native bindings**:
```bash
mopro build
```

3. **Update bindings**:
```bash
mopro update
```
4. **Transfer files**
why? becauce i cant find a better way
```bash
make transfer
```

6. **Run Flutter app**:
```bash
cd flutter
flutter pub get
flutter run

```
