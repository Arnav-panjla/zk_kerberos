use yew::prelude::*;
use yew_router::prelude::*;
use gloo_storage::{LocalStorage, Storage};

use crate::app::Route;
use crate::models::{SettingsModel, ThemeMode, UserCredentials};

#[function_component(SettingsPage)]
pub fn settings_page() -> Html {
    let navigator = use_navigator().unwrap();
    let settings = use_context::<UseStateHandle<SettingsModel>>().unwrap();
    
    let on_theme_change = {
        let settings = settings.clone();
        Callback::from(move |new_theme: ThemeMode| {
            let mut new_settings = (*settings).clone();
            new_settings.set_theme_mode(new_theme);
            settings.set(new_settings);
        })
    };

    let on_biometric_toggle = {
        let settings = settings.clone();
        Callback::from(move |_| {
            let mut new_settings = (*settings).clone();
            new_settings.set_biometric_enabled(!new_settings.biometric_enabled);
            settings.set(new_settings);
        })
    };

    let on_logout = {
        let navigator = navigator.clone();
        let settings = settings.clone();
        
        Callback::from(move |_| {

            let _ = LocalStorage::delete("user_credentials");
            let _ = LocalStorage::delete("selected_service");
            let _ = LocalStorage::delete("connected_service");
            let _ = LocalStorage::delete("proof_generated");
            
            let mut new_settings = (*settings).clone();
            new_settings.set_biometric_enabled(false);
            settings.set(new_settings);
            
            navigator.push(&Route::Login);
        })
    };

    let on_back = {
        let navigator = navigator.clone();
        Callback::from(move |_| {
            navigator.back();
        })
    };

    let theme_class = match settings.theme_mode {
        ThemeMode::Dark => "dark-theme",
        ThemeMode::Light => "light-theme",
        ThemeMode::System => "system-theme",
    };

    let value = on_theme_change.clone();
    let value1 = value.clone();
    let value2 = value1.clone();

    html! {
        <div class={classes!("settings-page", theme_class)}>
            <header class="page-header">
                <button class="back-btn" onclick={on_back}>
                    {"← Back"}
                </button>
                <h1>{"Settings"}</h1>
            </header>
            
            <div class="settings-container">
                <section class="settings-section">
                    <h2 class="section-title">{"Theme"}</h2>
                    <div class="setting-card">
                        <div class="theme-options">
                            <label class="radio-option">
                                <input 
                                    type="radio" 
                                    name="theme" 
                                    checked={settings.theme_mode == ThemeMode::Light}
                                    onchange={Callback::from(move |_| value.emit(ThemeMode::Light))}
                                />
                                <span class="radio-label">{"Light"}</span>
                            </label>
                            
                            <label class="radio-option">
                                <input 
                                    type="radio" 
                                    name="theme" 
                                    checked={settings.theme_mode == ThemeMode::Dark}
                                    onchange={Callback::from(move |_| value1.emit(ThemeMode::Dark))}
                                />
                                <span class="radio-label">{"Dark"}</span>
                            </label>
                            
                            <label class="radio-option">
                                <input 
                                    type="radio" 
                                    name="theme" 
                                    checked={settings.theme_mode == ThemeMode::System}
                                    onchange={Callback::from(move |_| value2.emit(ThemeMode::System))}
                                />
                                <span class="radio-label">{"System Default"}</span>
                            </label>
                        </div>
                    </div>
                </section>

                <section class="settings-section">
                    <h2 class="section-title">{"Security"}</h2>
                    <div class="setting-card">
                        <div class="toggle-setting">
                            <div class="setting-info">
                                <h3>{"Enable Biometric Login"}</h3>
                                <p class="setting-description">{"Use fingerprint or Face ID for faster logins"}</p>
                            </div>
                            <label class="toggle-switch">
                                <input 
                                    type="checkbox" 
                                    checked={settings.biometric_enabled}
                                    onchange={on_biometric_toggle}
                                />
                                <span class="slider"></span>
                            </label>
                        </div>
                    </div>
                </section>

                <section class="settings-section">
                    <h2 class="section-title">{"General"}</h2>
                    <div class="setting-card">
                        <div class="toggle-setting">
                            <div class="setting-info">
                                <h3>{"Push Notifications"}</h3>
                                <p class="setting-description">{"Receive notifications for important updates"}</p>
                            </div>
                            <label class="toggle-switch">
                                <input 
                                    type="checkbox" 
                                    checked={true}
                                    disabled={true}
                                />
                                <span class="slider"></span>
                            </label>
                        </div>
                        
                        <div class="link-setting">
                            <button class="link-btn">
                                <span>{"Privacy Policy"}</span>
                                <span class="arrow">{"→"}</span>
                            </button>
                        </div>
                    </div>
                </section>

                <section class="settings-section danger-section">
                    <div class="setting-card danger-card">
                        <button class="logout-btn danger-btn" onclick={on_logout}>
                            <span class="icon">{"🚪"}</span>
                            {"Log Out & Clear User ID"}
                        </button>
                    </div>
                </section>
            </div>
        </div>
    }
}