use yew::prelude::*;
use yew_router::prelude::*;
use wasm_bindgen_futures::spawn_local;
use gloo_storage::{LocalStorage, Storage};

use crate::app::Route;
use crate::models::{SettingsModel, UserCredentials};

#[derive(Clone, PartialEq)]
enum ProofStatus {
    Checking,
    Ready,
    Generating,
    Failed,
    NotFound,
}

#[function_component(AuthenticationPage)]
pub fn authentication_page() -> Html {
    let navigator = use_navigator().unwrap();
    let settings = use_context::<UseStateHandle<SettingsModel>>().unwrap();
    
    let service_name = use_state(|| {
        LocalStorage::get::<String>("selected_service").unwrap_or_else(|_| "Unknown Service".to_string())
    });
    
    let proof_status = use_state(|| ProofStatus::Checking);
    let status_message = use_state(|| None::<String>);
    
    {
        let proof_status = proof_status.clone();
        let status_message = status_message.clone();
        let service_name = service_name.clone();
        
        use_effect_with((), move |_| {
            let proof_status = proof_status.clone();
            let status_message = status_message.clone();
            let service_name = service_name.clone();
            
            spawn_local(async move {

                gloo_timers::future::TimeoutFuture::new(1000).await;
                
                // For demo purposes, assume certain services have pre-computed proofs
                let service = (*service_name).clone();
                if service == "library" || service == "webmail" || service == "wifi" {
                    proof_status.set(ProofStatus::Ready);
                    status_message.set(Some("Pre-computed proof is ready to use.".to_string()));
                } else {
                    proof_status.set(ProofStatus::NotFound);
                    status_message.set(Some("No proof found. Please generate one.".to_string()));
                }
            });
            || ()
        });
    }

    let on_generate_proof = {
        let proof_status = proof_status.clone();
        let status_message = status_message.clone();
        
        Callback::from(move |_| {
            let proof_status = proof_status.clone();
            let status_message = status_message.clone();
            
            proof_status.set(ProofStatus::Generating);
            status_message.set(None);
            
            spawn_local(async move {
                // Simulate proof generation (this is where RISC0 integration would go)
                gloo_timers::future::TimeoutFuture::new(3000).await;
                
                // Simulate random success/failure for demo
                let success = js_sys::Math::random() > 0.3; // 70% success rate
                
                if success {
                    proof_status.set(ProofStatus::Ready);
                    status_message.set(Some("New proof generated successfully!".to_string()));
                    
                    // Store proof in local storage
                    let _ = LocalStorage::set("proof_generated", &true);
                } else {
                    proof_status.set(ProofStatus::Failed);
                    status_message.set(Some("Proof generation failed. Please try again.".to_string()));
                }
            });
        })
    };

    let on_connect = {
        let navigator = navigator.clone();
        let service_name = service_name.clone();
        
        Callback::from(move |_| {
            // Store service name for welcome page
            let _ = LocalStorage::set("connected_service", &(*service_name));
            navigator.push(&Route::Welcome);
        })
    };

    let theme_class = match settings.theme_mode {
        crate::models::ThemeMode::Dark => "dark-theme",
        crate::models::ThemeMode::Light => "light-theme",
        crate::models::ThemeMode::System => "system-theme",
    };

    let service_display_name = match service_name.as_str() {
        "library" => "Library",
        "webmail" => "Webmail",
        "wifi" => "WiFi Access",
        "gradescope" => "Gradescope",
        "badal" => "Badal VM",
        "moodle" => "Moodle",
        "admin" => "Admin Login",
        _ => "Unknown Service",
    };

    html! {
        <div class={classes!("authentication-page", theme_class)}>
            <header class="page-header">
                <button class="back-btn" onclick={
                    let navigator = navigator.clone();
                    Callback::from(move |_| {
                        navigator.push(&Route::Services);
                    })
                }>
                    {"← Back"}
                </button>
                <h1>{"Authentication"}</h1>
            </header>
            
            <div class="auth-container">
                <div class="service-header">
                    <h2>{service_display_name}</h2>
                </div>
                
                <div class="status-section">
                    {match (*proof_status).clone() {
                        ProofStatus::Checking => html! {
                            <div class="status-checking">
                                <div class="spinner"></div>
                                <p>{"Checking for existing proof..."}</p>
                            </div>
                        },
                        ProofStatus::Ready => html! {
                            <div class="status-ready">
                                <div class="status-icon success">{"✓"}</div>
                                <p>{status_message.as_ref().unwrap_or(&"Proof is ready!".to_string())}</p>
                            </div>
                        },
                        ProofStatus::Failed => html! {
                            <div class="status-failed">
                                <div class="status-icon error">{"✗"}</div>
                                <p>{status_message.as_ref().unwrap_or(&"Proof generation failed".to_string())}</p>
                            </div>
                        },
                        ProofStatus::NotFound => html! {
                            <div class="status-not-found">
                                <div class="status-icon warning">{"!"}</div>
                                <p>{"No proof found. Please generate one."}</p>
                            </div>
                        },
                        ProofStatus::Generating => html! {
                            <div class="status-generating">
                                <div class="spinner"></div>
                                <p>{"Generating zero-knowledge proof..."}</p>
                            </div>
                        },
                    }}
                </div>
                
                <div class="action-buttons">
                    <button 
                        class="generate-btn primary-btn"
                        onclick={on_generate_proof}
                        disabled={matches!(*proof_status, ProofStatus::Generating)}
                    >
                        <span class="icon">{"🔒"}</span>
                        {if matches!(*proof_status, ProofStatus::Generating) {
                            "Generating..."
                        } else {
                            "Generate New Proof"
                        }}
                    </button>
                    
                    <button 
                        class="connect-btn secondary-btn"
                        onclick={on_connect}
                        disabled={!matches!(*proof_status, ProofStatus::Ready)}
                    >
                        <span class="icon">{"🔗"}</span>
                        {"Connect"}
                    </button>
                </div>
            </div>
        </div>
    }
}