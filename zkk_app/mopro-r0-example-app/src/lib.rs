#![allow(unexpected_cfgs)]

use ecdsa_methods::{ECDSA_VERIFY_ELF, ECDSA_VERIFY_ID};
use risc0_zkvm::{default_prover, ExecutorEnv, Receipt};

mopro_ffi::app!();

#[derive(uniffi::Error, thiserror::Error, Debug)]
pub enum Risc0Error {
    #[error("Failed to prove: {0}")]
    ProveError(String),
    #[error("Failed to serialize receipt: {0}")]
    SerializeError(String),
    #[error("Failed to verify: {0}")]
    VerifyError(String),
    #[error("Failed to decode journal: {0}")]
    DecodeError(String),
}

#[derive(uniffi::Record, Clone)]
pub struct Risc0ProofOutput {
    pub receipt: Vec<u8>,
}

#[derive(uniffi::Record, Clone)]
pub struct Risc0VerifyOutput {
    pub is_valid: bool,
    pub verified_message: String,
}

#[uniffi::export]
pub fn risc0_prove(message: String) -> Result<Risc0ProofOutput, Risc0Error> {

    let message_bytes = message.as_bytes();

    let env = ExecutorEnv::builder()
        .write(&message_bytes)
        .map_err(|e| Risc0Error::ProveError(format!("Failed to write input: {}", e)))?
        .build()
        .map_err(|e| {
            Risc0Error::ProveError(format!("Failed to build executor environment: {}", e))
        })?;

    // Get the default prover
    let prover = default_prover();

    // Generate proof
    let prove_info = prover
        .prove(env, ECDSA_VERIFY_ELF)
        .map_err(|e| Risc0Error::ProveError(format!("Failed to generate proof: {}", e)))?;

    // Extract receipt
    let receipt = prove_info.receipt;

    // Serialize receipt to bytes
    let receipt_bytes = bincode::serialize(&receipt)
        .map_err(|e| Risc0Error::SerializeError(format!("Failed to serialize receipt: {}", e)))?;

    Ok(Risc0ProofOutput {
        receipt: receipt_bytes,
    })

}

#[uniffi::export]
pub fn risc0_verify(receipt_bytes: Vec<u8>) -> Result<Risc0VerifyOutput, Risc0Error> {
    // Deserialize receipt from bytes
    let receipt: Receipt = bincode::deserialize(&receipt_bytes)
        .map_err(|e| Risc0Error::SerializeError(format!("Failed to deserialize receipt: {}", e)))?;

    // Verify the receipt
    receipt
        .verify(ECDSA_VERIFY_ID)
        .map_err(|e| Risc0Error::VerifyError(format!("Failed to verify receipt: {}", e)))?;

    // Extract output from journal
    let output_value: Vec<u8> = receipt
        .journal
        .decode()
        .map_err(|e| Risc0Error::DecodeError(format!("Failed to decode journal: {}", e)))?;

    // Convert Vec<u8> → String
    let verified_message = String::from_utf8(output_value)
        .map_err(|e| Risc0Error::DecodeError(format!("Invalid UTF-8 in journal: {}", e)))?;

    Ok(Risc0VerifyOutput {
        is_valid: true,
        verified_message,
    })
}


