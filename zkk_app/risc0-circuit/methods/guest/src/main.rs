#![no_main]
use risc0_zkvm::guest::env;
use sha2::{Sha256, Digest};

#[no_mangle]
fn main() {

    let input : Vec<u8> = env::read();
    
    if input.len() < 29 {
        eprintln!("Invalid input! Needs at least 29 bytes.");
        return;
    }

    let user_id = String::from_utf8_lossy(&input[0..10]);

    let service_id = String::from_utf8_lossy(&input[11..21]);

    let password = String::from_utf8_lossy(&input[22..]);

    let file_data = include_bytes!("../../../New Document.txt");
    
    let mut hasher = Sha256::new();

    hasher.update(user_id.as_bytes());
    hasher.update(password.as_bytes());
    hasher.update(service_id.as_bytes());

    let check_hash: [u8; 32] = hasher.finalize().into();

    let target_hash = hex::encode(&check_hash);
    let target_hash_hex = target_hash.as_bytes();

    let mut hasher = Sha256::new();
    hasher.update(password.as_bytes());
    hasher.update(service_id.as_bytes());

    let pass_hash: [u8; 32] = hasher.finalize().into();
    
    let hash_exists = file_data
        .windows(target_hash_hex.len())
        .any(|window| window == target_hash_hex);

    let hash_exists_bytes = if hash_exists { [1u8; 1] } else { [0u8; 1] };


    let mut hasher = Sha256::new();
    hasher.update(&file_data);
    let file_data_hash: [u8; 32] = hasher.finalize().into();

    let mut hasher = Sha256::new();
    hasher.update(user_id.as_bytes());
    hasher.update(service_id.as_bytes());
    let id_hash: [u8; 32] = hasher.finalize().into();

    env::commit(&(hash_exists_bytes, file_data_hash, id_hash, pass_hash));

}