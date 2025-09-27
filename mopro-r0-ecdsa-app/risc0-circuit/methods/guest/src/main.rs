use risc0_zkvm::guest::env;

fn main() {
    // Decode the verifying key, message, and signature from the inputs.
    // let (encoded_verifying_key, message, signature): (EncodedPoint, Vec<u8>, Signature) =
    //     env::read();
    // let verifying_key = VerifyingKey::from_encoded_point(&encoded_verifying_key).unwrap();

    // // Verify the signature, panicking if verification fails.
    // verifying_key
    //     .verify(&message, &signature)
    //     .expect("ECDSA signature verification failed");

    // // Commit to the journal the verifying key and message that was signed.
    // env::commit(&(encoded_verifying_key, message));


    let message: Vec<u8> = env::read();


    
    env::commit(&message);
}
