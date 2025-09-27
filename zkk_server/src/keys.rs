use sha2::Sha256;
use ed25519_dalek::{Signer, SigningKey};
use once_cell::sync::Lazy;
use std::env;
use base64::Engine;


static KEY: Lazy<SigningKey> = Lazy::new(|| {
    let env_key = env::var("SERVER_SIGNING_KEY_B64").unwrap();
    println!("Decoded signing key: {}", &env_key);
    let b64: [u8; 32] = base64::engine::general_purpose::STANDARD.decode(env_key).expect("base64 decode").try_into().expect("32 bytes");
    SigningKey::from_bytes(&b64)
});


pub fn private_sign(data: &[u8]) -> [u8; 64] {
    KEY.sign(data).to_bytes()
}

use sha2::Digest;

pub fn gen_session_key() -> String {

    let key_bytes = KEY.to_bytes();
    let sess_key_bytes = get_session_key();

    let mut hasher = Sha256::new();
    hasher.update(&sess_key_bytes);
    hasher.update(&key_bytes);
    let out = hasher.finalize();

    let mut next = [0u8; 32];
    next.copy_from_slice(&out);
    let k = base64::engine::general_purpose::STANDARD.encode(&next);
    unsafe {
        env::set_var("SESSION_KEY", &k);
    }
    k
}

fn get_session_key() -> String {
    env::var("SESSION_KEY").unwrap()
}

