use ecdsa_methods::{ECDSA_VERIFY_ELF, ECDSA_VERIFY_ID};
use rand_core::OsRng;
use risc0_zkvm::{ExecutorEnv, Receipt, default_prover};
use log::{info, debug};

fn main() {
    env_logger::init();

    let message = b"This is a message that will be signed, and verified within the zkVM";
    debug!("Message to sign: {:?}", std::str::from_utf8(message).unwrap());



    let env = ExecutorEnv::builder()
        .write(&message.to_vec())
        .unwrap()
        .build()
        .unwrap();

    let prover = default_prover();

    let receipt = prover.prove(env, ECDSA_VERIFY_ELF).unwrap().receipt;
    info!("zkVM execution completed, receipt generated");

    debug!("Verifying receipt with method ID");
    receipt.verify(ECDSA_VERIFY_ID).unwrap();
    info!("Receipt verification successful");

    // let receipt_message: Vec<u8> = receipt.journal.decode().unwrap();
    // debug!("Journal decoded successfully");


}
