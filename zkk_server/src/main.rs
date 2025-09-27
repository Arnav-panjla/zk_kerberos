use std::net::{TcpListener, TcpStream};
use std::thread;
use bincode;
use bincode::config::{Configuration};
use serde::{Serialize, Deserialize};
use risc0_zkvm::Receipt;
pub mod keys;


const METHOD_ID: [u32;8] = [1285717554, 1226703973, 3597931344, 4069461039, 4125557270, 1572380072, 1907810864, 1324534535];

fn handle_client(mut stream: TcpStream) {

    loop {
        client(&mut stream);
    }
}

fn main() {
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
}


#[derive(Debug, Serialize, Deserialize, bincode::Encode, bincode::Decode)]
struct MessageReceived {
    u_pk: [u8; 32],
    #[bincode(with_serde)]
    proof: Receipt,
    enc_id: Vec<u8>, //encrypted user_id + service_id which the server is only signing and returning
}

#[derive(Debug, bincode::Encode, bincode::Decode)]
struct MessageSent {
    signature: [u8; 64],
    #[bincode(with_serde)]
    ssk: String,
    timestamp: u64
}

#[derive(Debug, bincode::Encode, bincode::Decode)]
struct SignBundle {
    ssk: String,
    u_pk: [u8; 32],
    enc_id: Vec<u8>,
}

fn client(stream: &mut TcpStream) {

    let data = bincode::decode_from_std_read::<MessageReceived, Configuration, TcpStream>(stream, bincode::config::standard()).expect("failed to deserialize");
    
    println!("Received data: {:?}", data);

    data.proof.verify(METHOD_ID).expect("failed to verify proof");
    println!("Proof verified!");

    let bundle = SignBundle {
        ssk: keys::gen_session_key(),
        u_pk: data.u_pk,
        enc_id: data.enc_id.clone(),
    };
    let encoded: Vec<u8> = bincode::encode_to_vec(&bundle, bincode::config::standard()).expect("failed to serialize");
    let response = MessageSent {
        signature: keys::private_sign(&encoded),
        ssk: keys::gen_session_key(),
        timestamp: std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .expect("Time went backwards")
            .as_secs(),
    };
    bincode::encode_into_std_write(&response, stream, bincode::config::standard()).expect("failed to send response");
    println!("Response sent: {:?}", response);

}
