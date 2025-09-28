use std::net::{TcpListener, TcpStream};
use std::thread;
use bincode;
use bincode::config::{Configuration};
use serde::{Serialize, Deserialize};
use risc0_zkvm::Receipt;
use rsa::{RsaPublicKey, Pkcs1v15Encrypt};
use sha2::{Sha256, Digest};
use dotenv;
pub mod keys;

use reqwest;
use std::fs::File;
use std::io::copy;

pub fn download() {
    println!("[DEBUG] Starting file download process");
    let url = "https://gateway.lighthouse.storage/ipfs/bafkreic6cytux6kvw2dhjbeketjxuaskwh62iv4rs5gioija4mtazetvne";
    println!("[DEBUG] Download URL: {}", url);
    
    println!("[DEBUG] Making HTTP request to download file");
    let mut response = reqwest::blocking::get(url).unwrap();
    println!("[DEBUG] HTTP request successful, response received");

    let file_path = "New Document.txt";
    println!("[DEBUG] Creating local file: {}", file_path);
    let mut file = File::create(file_path).unwrap();
    println!("[DEBUG] Local file created successfully");

    println!("[DEBUG] Copying response data to local file");
    copy(&mut response, &mut file).unwrap();
    println!("[DEBUG] File download completed successfully");
}



const METHOD_ID: [u32;8] = [1836308647, 1743861648, 3803708556, 3291731199, 3589807800, 2583256414, 3562111121, 2460626041];

fn handle_client(mut stream: TcpStream) {
    println!("[DEBUG] Starting client handler for connection: {:?}", stream.peer_addr().unwrap_or("unknown".parse().unwrap()));
    loop {
        println!("[DEBUG] Entering client processing loop");
        client(&mut stream);
        println!("[DEBUG] Client processing iteration completed");
    }
}

fn main() {
    println!("[DEBUG] Starting ZK Kerberos server");
    dotenv::dotenv().ok();
    println!("[DEBUG] Environment variables loaded");
    
    println!("[DEBUG] Attempting to bind to address 127.0.0.1:7878");
    let listener = TcpListener::bind("127.0.0.1:7878").expect("Failed to bind to address");
    println!("Server listening on 127.0.0.1:7878");
    println!("[DEBUG] TCP listener successfully bound and listening");

    println!("[DEBUG] Starting to accept incoming connections");
    for stream in listener.incoming() {
        match stream {
            Ok(stream) => {
                let peer_addr = stream.peer_addr().unwrap();
                println!("New connection: {}", peer_addr);
                println!("[DEBUG] Spawning new thread for client: {}", peer_addr);
                thread::spawn(move || {
                    handle_client(stream);
                });
                println!("[DEBUG] Thread spawned successfully for client: {}", peer_addr);
            }
            Err(e) => {
                eprintln!("Error accepting connection: {}", e);
                eprintln!("[DEBUG] Connection acceptance failed with error: {:?}", e);
            }
        }
    }
    // {
    //     // generate an ed25519 signing key and verifying key and print keys as hex
    //     let mut csprng = rand::rngs::OsRng{};
    //     let signing_key = ed25519_dalek::SigningKey::generate(&mut csprng);
    //     let verifying_key = signing_key.verifying_key();

    //     let pub_b64 = base64::encode(verifying_key.to_bytes());
    //     println!("Public key (base64): {}", pub_b64);

    //     let sec_b64 = base64::encode(signing_key.to_bytes());
    //     println!("Secret key (base64): {}", sec_b64);
    // }
}


#[derive(Debug, Serialize, Deserialize, bincode::Encode, bincode::Decode)]
struct MessageReceived {
    #[bincode(with_serde)]
    u_pk: RsaPublicKey,
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

fn client(stream: &mut TcpStream) {
    println!("[DEBUG] Starting client processing");
    
    println!("[DEBUG] Attempting to deserialize incoming message");
    let data = bincode::decode_from_std_read::<MessageReceived, Configuration, TcpStream>(stream, bincode::config::standard()).expect("failed to deserialize");
    println!("[DEBUG] Message successfully deserialized");
    
    println!("[DEBUG] Decoding proof journal");
    let (existence, file_hash, id_hash) : (u8, [u8; 32], [u8; 32]) = data.proof.journal.decode().expect("failed to decode journal");
    println!("[DEBUG] Journal decoded - existence: {}, file_hash: {:?}, id_hash: {:?}", existence, file_hash, id_hash);
    
    println!("Received data: {:?}", data);

    println!("[DEBUG] Starting proof verification with METHOD_ID: {:?}", METHOD_ID);
    data.proof.verify(METHOD_ID).expect("failed to verify proof");

    println!("Proof verified!");
    println!("[DEBUG] Zero-knowledge proof verification successful");
    
    if existence != 1 {
        println!("False proof. Why would you prove that?");
        println!("[DEBUG] Proof indicates non-existence (existence = {}), terminating processing", existence);
        return;
    }
    println!("[DEBUG] Existence proof validated (existence = {})", existence);

    println!("[DEBUG] Starting file download process");
    download();
    println!("[DEBUG] File download completed, reading file data");
    
    let file_data = std::fs::read("New Document.txt").expect("failed to read file");
    println!("[DEBUG] File data read successfully, length: {} bytes", file_data.len());
    
    println!("[DEBUG] Computing SHA256 hash of file data");
    let mut hasher = Sha256::new();
    hasher.update(&file_data);
    let file_data_hash: [u8; 32] = hasher.finalize().into();
    println!("[DEBUG] File data hash computed: {:?}", file_data_hash);

    if file_data_hash != file_hash {
        println!("File hash mismatch! Provided: {:?}, Actual: {:?}", file_hash, file_data_hash);
        println!("[DEBUG] Hash verification failed, terminating processing");
        return;
    }
    println!("[DEBUG] File hash verification successful");

    println!("[DEBUG] File hash verification successful");

    println!("[DEBUG] Generating session key");
    let session_key = keys::gen_session_key();
    println!("[DEBUG] Session key generated successfully");
    
    println!("[DEBUG] Getting current timestamp");
    let timestamp = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .expect("Time went backwards")
        .as_secs();
    println!("[DEBUG] Current timestamp: {}", timestamp);
    
    println!("[DEBUG] Creating SignBundle");
    let bundle = SignBundle {
        ssk: session_key,
        hash: id_hash.try_into().expect("slice with incorrect length"),
        timestamp,
    };
    println!("[DEBUG] SignBundle created: {:?}", bundle);

    println!("[DEBUG] Serializing SignBundle for signing");
    let encoded: Vec<u8> = bincode::encode_to_vec(&bundle, bincode::config::standard()).expect("failed to serialize");
    println!("[DEBUG] SignBundle serialized, length: {} bytes", encoded.len());
    
    println!("[DEBUG] Generating private signature");
    let signature = keys::private_sign(&encoded);
    println!("[DEBUG] Private signature generated: {:?}", signature);
    
    println!("[DEBUG] Creating response message");
    let response = MessageSent {
        signature,
        signature_data: bundle,
    };
    println!("[DEBUG] Response message created: {:?}", response);

    println!("[DEBUG] Serializing response message for encryption");
    let plain = bincode::encode_to_vec(&response, bincode::config::standard())
        .expect("failed to serialize response for encryption");
    println!("[DEBUG] Response serialized, length: {} bytes", plain.len());

    println!("[DEBUG] Initializing RNG for encryption");
    let mut rng = rand::rngs::OsRng;
    println!("[DEBUG] Starting RSA encryption with client's public key");
    let encrypted = data.u_pk.encrypt(
        &mut rng,
        Pkcs1v15Encrypt,
        &plain,
    ).expect("failed to encrypt response");
    println!("[DEBUG] RSA encryption completed, encrypted length: {} bytes", encrypted.len());

    // shadow the original `response` so the subsequent write sends the ciphertext
    let response = encrypted;

    println!("[DEBUG] Sending encrypted response to client");
    bincode::encode_into_std_write(&response, stream, bincode::config::standard()).expect("failed to send response");
    println!("Response sent: {:?}", response);
    println!("[DEBUG] Response sent successfully");

    println!("[DEBUG] Shutting down connection");
    if let Err(e) = stream.shutdown(std::net::Shutdown::Both) {
        eprintln!("Failed to shutdown connection: {}", e);
        eprintln!("[DEBUG] Connection shutdown failed: {:?}", e);
    } else {
        println!("[DEBUG] Connection shutdown successful");
    }
    println!("[DEBUG] Client processing completed");
}