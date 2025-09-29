use yew::prelude::*;
use yew_router::prelude::*;
use gloo_storage::{LocalStorage, Storage};

use crate::app::Route;
use crate::models::SettingsModel;

#[function_component(WelcomePage)]
pub fn welcome_page() -> Html {
    let navigator = use_navigator().unwrap();
    let settings = use_context::<UseStateHandle<SettingsModel>>().unwrap();
    
    let service_name = use_state(|| {
        LocalStorage::get::<String>("connected_service").unwrap_or_else(|_| "Unknown Service".to_string())
    });

    let on_done = {
        let navigator = navigator.clone();
        Callback::from(move |_| {
            navigator.push(&Route::Services);
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
        <div class={classes!("welcome-page", theme_class)}>
            <div class="welcome-container">
                <div class="success-animation">
                    <div class="success-icon">
                        {"✓"}
                    </div>
                </div>
                
                <div class="welcome-content">
                    <h1 class="welcome-title">{"Welcome to"}</h1>
                    <h2 class="service-name">{service_display_name}</h2>
                    
                    <div class="success-message">
                        <p>{"You have successfully authenticated and connected to the service."}</p>
                        <p class="note">{"Your zero-knowledge proof has been verified."}</p>
                    </div>
                </div>
                
                <div class="welcome-actions">
                    <button class="done-btn primary-btn" onclick={on_done}>
                        {"Done"}
                    </button>
                </div>
            </div>
        </div>
    }
}