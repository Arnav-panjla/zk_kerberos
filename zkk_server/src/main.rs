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
    let url = "https://gateway.lighthouse.storage/ipfs/bafkreic6cytux6kvw2dhjbeketjxuaskwh62iv4rs5gioija4mtazetvne";
    
    let mut response = reqwest::blocking::get(url).unwrap();

    let file_path = "New Document.txt";
    let mut file = File::create(file_path).unwrap();

    copy(&mut response, &mut file).unwrap();
}



const METHOD_ID: [u32;8] = [1836308647, 1743861648, 3803708556, 3291731199, 3589807800, 2583256414, 3562111121, 2460626041];
fn handle_client(mut stream: TcpStream) {
    // let mut buffer = [0u8; 1024]; // fixed-size buffer to store incoming data

    loop {
        client(&mut stream);
    }
}

fn main() {
    dotenv::dotenv().ok();
    let listener = TcpListener::bind("127.0.0.1:7878").expect("Failed to bind to address");
    println!("Server listening on 127.0.0.1:7878");

    for stream in listener.incoming() {
        match stream {
            Ok(stream) => {
                println!("New connection: {}", stream.peer_addr().unwrap());
                thread::spawn(move || {
                    handle_client(stream);
                });
            }
            Err(e) => {
                eprintln!("Error accepting connection: {}", e);
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

    let data = bincode::decode_from_std_read::<MessageReceived, Configuration, TcpStream>(stream, bincode::config::standard()).expect("failed to deserialize");
    // let ssk = keys::gen_session_key();
    let (existence, file_hash, id_hash) : (u8, [u8; 32], [u8; 32]) = data.proof.journal.decode().expect("failed to decode journal");
    // 0 -> bool , file_hash, u_id+ser_id hash
    // println!("hxh: {:?}", hxh);
    println!("Received data: {:?}", data);

    data.proof.verify(METHOD_ID).expect("failed to verify proof");


    println!("Proof verified!");
    if existence != 1 {
        println!("False proof. Why would you prove that?");
        return;
    }

    download();
    let file_data = std::fs::read("New Document.txt").expect("failed to read file");
    let mut hasher = Sha256::new();
    hasher.update(&file_data);
    let file_data_hash: [u8; 32] = hasher.finalize().into();

    if file_data_hash != file_hash {
        println!("File hash mismatch! Provided: {:?}, Actual: {:?}", file_hash, file_data_hash);
        return;
    }

    let bundle = SignBundle {
        ssk: keys::gen_session_key(),
        hash: id_hash.try_into().expect("slice with incorrect length"),
        timestamp: std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .expect("Time went backwards")
            .as_secs(),
    };

    let encoded: Vec<u8> = bincode::encode_to_vec(&bundle, bincode::config::standard()).expect("failed to serialize");
    let response = MessageSent {
        signature: keys::private_sign(&encoded),
        signature_data: bundle,
    };

    let plain = bincode::encode_to_vec(&response, bincode::config::standard())
        .expect("failed to serialize response for encryption");

    let mut rng = rand::rngs::OsRng;
    let encrypted = data.u_pk.encrypt(
        &mut rng,
        Pkcs1v15Encrypt,
        &plain,
    ).expect("failed to encrypt response");

    // shadow the original `response` so the subsequent write sends the ciphertext
    let response = encrypted;

    bincode::encode_into_std_write(&response, stream, bincode::config::standard()).expect("failed to send response");
    println!("Response sent: {:?}", response);

    if let Err(e) = stream.shutdown(std::net::Shutdown::Both) {
        eprintln!("Failed to shutdown connection: {}", e);
    }
}