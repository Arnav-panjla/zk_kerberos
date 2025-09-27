use rsa::{RsaPrivateKey, RsaPublicKey};
use rsa::rand_core::OsRng;
use std::error::Error;

pub fn generate_rsa_keypair() -> Result<(RsaPrivateKey, RsaPublicKey), Box<dyn Error>> {
    let mut rng = OsRng;
    
    let private_key = RsaPrivateKey::new(&mut rng, 2048)?;
    let public_key = RsaPublicKey::from(&private_key);
    
    Ok((private_key, public_key))
}