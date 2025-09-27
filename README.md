# zk_kerberos
zero knowledge kerberos



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