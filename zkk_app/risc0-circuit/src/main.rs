
mod keys;

use methods::{RISC0_CIRCUIT_ELF, RISC0_CIRCUIT_ID};
use risc0_zkvm::{default_prover, ExecutorEnv};
use risc0_zkvm::Receipt;
use rsa::Pkcs1v15Encrypt;
use std::net::TcpStream;
use bincode;
use serde::{Serialize, Deserialize};

use log::{info, debug};


#[derive(Debug, Serialize, Deserialize, bincode::Encode, bincode::Decode)]
struct MessageReceived {
    #[bincode(with_serde)]
    u_pk: rsa::RsaPublicKey,
    #[bincode(with_serde)]
    proof: Receipt,
}

#[derive(Debug, bincode::Encode, bincode::Decode)]
struct MessageSent {
    signature: [u8; 64],
    signature_data: SignBundle,
}

#[derive(Debug, bincode::Encode, bincode::Decode)]
struct SignBundle {
    ssk: String,
    hash: [u8; 32],
    timestamp: u64,
}


fn main() {

    tracing_subscriber::fmt()
        .with_env_filter(tracing_subscriber::EnvFilter::from_default_env())
        .init();

    let (private_key, public_key) = keys::generate_rsa_keypair().expect("Failed to generate RSA key pair");

    
    let input = b"1234567890 password12 session4";
    debug!("Initial input: {:?}", std::str::from_utf8(input).unwrap());


    println!("{:?}", RISC0_CIRCUIT_ID);
    let receipt = authenticate_user(input.to_vec());

    let m = MessageReceived{
        u_pk: public_key,
        proof: receipt,
    };

    let addr = "127.0.0.1:7878";
    let mut stream = TcpStream::connect(addr).expect("failed to connect");
    bincode::encode_into_std_write(m, &mut stream, bincode::config::standard()).expect("failed to serialize");
    println!("Sent proof to {}", addr);

    let res = bincode::decode_from_std_read::<Vec<u8>, _, _>(&mut stream, bincode::config::standard()).expect("failed to read/deserialize");

    println!("Received response: {:?}", res);
    if let Err(e) = stream.shutdown(std::net::Shutdown::Both) {
        eprintln!("Failed to disconnect: {}", e);
    } else {
        println!("Disconnected from {}", addr);
    }

    let plaintext = private_key
        .decrypt(Pkcs1v15Encrypt, &res)
        .expect("Failed to decrypt response");
    let (response, _): (MessageSent, _) =
        bincode::decode_from_slice(&plaintext, bincode::config::standard())
            .expect("Failed to deserialize decrypted response");
    
    println!("Decrypted response: {:?}", response);
}

pub fn authenticate_user(input: Vec<u8>) -> Receipt{
    let env = ExecutorEnv::builder()
        .write(&input).unwrap()
        .build().unwrap();

    let prover = default_prover();
    
    let receipt = prover.prove(env, RISC0_CIRCUIT_ELF).unwrap().receipt;

    receipt
}


