use risc0_zkvm::guest::env;

fn main() {

    let input: Vec<u8> = env::read();

    if input.len() < 21 {
        eprintln!("Invalid input! Needs at least 21 bytes.");
        return;
    }

    let user_id = String::from_utf8_lossy(&input[0..10]);

    let session_id = String::from_utf8_lossy(&input[11..21]);

    let password = String::from_utf8_lossy(&input[22..]);

    println!("UserID: {}", user_id);
    println!("SessionID: {}", session_id);
    println!("Password: {}", password);

    env::commit(&input);
}
