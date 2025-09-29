use yew::prelude::*;
use yew_router::prelude::*;
use web_sys::HtmlInputElement;
use gloo_storage::{LocalStorage, Storage};

use crate::app::Route;
use crate::models::{UserCredentials, SettingsModel};

#[function_component(LoginPage)]
pub fn login_page() -> Html {
    let navigator = use_navigator().unwrap();
    let settings = use_context::<UseStateHandle<SettingsModel>>().unwrap();
    
    let user_id = use_state(|| String::new());
    let password = use_state(|| String::new());
    let is_loading = use_state(|| false);

    let on_user_id_change = {
        let user_id = user_id.clone();
        Callback::from(move |e: Event| {
            let input: HtmlInputElement = e.target_unchecked_into();
            user_id.set(input.value());
        })
    };

    let on_password_change = {
        let password = password.clone();
        Callback::from(move |e: Event| {
            let input: HtmlInputElement = e.target_unchecked_into();
            password.set(input.value());
        })
    };

    let on_login = {
        let navigator = navigator.clone();
        let user_id = user_id.clone();
        let password = password.clone();
        let is_loading = is_loading.clone();
        
        Callback::from(move |e: SubmitEvent| {
            e.prevent_default();
            
            if user_id.is_empty() || password.is_empty() {
                return;
            }

            is_loading.set(true);
            
            let credentials = UserCredentials {
                user_id: (*user_id).clone(),
                password: (*password).clone(),
            };
            
            // Save credentials to local storage
            let _ = LocalStorage::set("user_credentials", &credentials);
            
            // Navigate to services page
            navigator.push(&Route::Services);
        })
    };

    let on_biometric_login = {
        let navigator = navigator.clone();
        Callback::from(move |_| {
            // Try to load saved credentials
            if let Ok(credentials) = LocalStorage::get::<UserCredentials>("user_credentials") {
                navigator.push(&Route::Services);
            }
        })
    };

    let theme_class = match settings.theme_mode {
        crate::models::ThemeMode::Dark => "dark-theme",
        crate::models::ThemeMode::Light => "light-theme",
        crate::models::ThemeMode::System => "system-theme",
    };

    html! {
        <div class={classes!("login-page", theme_class)}>
            <div class="login-container">
                <div class="login-header">
                    <h1 class="title">{"Welcome Back"}</h1>
                    <p class="subtitle">{"Login to access services"}</p>
                </div>
                
                <form class="login-form" onsubmit={on_login}>
                    <div class="input-group">
                        <label for="user-id">{"User ID"}</label>
                        <input
                            type="text"
                            id="user-id"
                            value={(*user_id).clone()}
                            onchange={on_user_id_change}
                            placeholder="Enter your user ID"
                            required=true
                        />
                    </div>
                    
                    <div class="input-group">
                        <label for="password">{"Password"}</label>
                        <input
                            type="password"
                            id="password"
                            value={(*password).clone()}
                            onchange={on_password_change}
                            placeholder="Enter your password"
                            required=true
                        />
                    </div>
                    
                    <button 
                        type="submit" 
                        class="login-btn primary-btn"
                        disabled={*is_loading}
                    >
                        {if *is_loading { "Logging in..." } else { "Login" }}
                    </button>
                    
                    {if settings.biometric_enabled {
                        html! {
                            <button 
                                type="button" 
                                class="biometric-btn secondary-btn"
                                onclick={on_biometric_login}
                            >
                                <span class="icon">{"🔒"}</span>
                                {"Biometric Login"}
                            </button>
                        }
                    } else {
                        html! {}
                    }}
                </form>
            </div>
        </div>
    }
}