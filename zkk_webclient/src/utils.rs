use wasm_bindgen::prelude::*;


#[wasm_bindgen]
extern "C" {
    #[wasm_bindgen(js_namespace = console)]
    fn log(s: &str);
}

pub fn console_log(s: &str) {
    log(s);
}

pub async fn generate_zk_proof(user_id: &str, service_id: &str, password: &str) -> Result<String, String> {


    // ToDo: Integrate with RISC0 SDK 


    console_log(&format!("Generating proof for user: {}, service: {}", user_id, service_id));
    
    // Simulate proof generation delay
    gloo_timers::future::TimeoutFuture::new(3000).await;   
    
    
    Ok(format!("proof_for_{}_{}", user_id, service_id))
}

pub fn get_avatar_text(name: &str) -> String {
    if name.contains(' ') {
        let parts: Vec<&str> = name.split(' ').collect();
        format!("{}{}", 
            parts[0].chars().next().unwrap_or('?'),
            parts.get(1).and_then(|s| s.chars().next()).unwrap_or(' ')
        )
    } else {
        name.chars().next().unwrap_or('?').to_string()
    }
}