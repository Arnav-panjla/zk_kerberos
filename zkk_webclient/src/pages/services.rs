use yew::prelude::*;
use yew_router::prelude::*;
use web_sys::HtmlInputElement;

use crate::app::Route;
use crate::models::{Service, SettingsModel, UserCredentials};
use gloo_storage::{LocalStorage, Storage};

#[function_component(ServicesPage)]
pub fn services_page() -> Html {
    let navigator = use_navigator().unwrap();
    let settings = use_context::<UseStateHandle<SettingsModel>>().unwrap();
    
    let search_query = use_state(|| String::new());
    
    let filtered_services = {
        let query = (*search_query).to_lowercase();
        if query.is_empty() {
            Service::get_all_services()
        } else {
            Service::get_all_services()
                .into_iter()
                .filter(|service| service.name.to_lowercase().contains(&query))
                .collect()
        }
    };

    let on_search_change = {
        let search_query = search_query.clone();
        Callback::from(move |e: Event| {
            let input: HtmlInputElement = e.target_unchecked_into();
            search_query.set(input.value());
        })
    };

    let on_service_click = {
        let navigator = navigator.clone();
        Callback::from(move |service_id: String| {
            
            // For now store it in local storage
            
            let _ = LocalStorage::set("selected_service", &service_id);
            navigator.push(&Route::Authentication);
        })
    };

    let on_settings_click = {
        let navigator = navigator.clone();
        Callback::from(move |_| {
            navigator.push(&Route::Settings);
        })
    };

    let theme_class = match settings.theme_mode {
        crate::models::ThemeMode::Dark => "dark-theme",
        crate::models::ThemeMode::Light => "light-theme",
        crate::models::ThemeMode::System => "system-theme",
    };

    html! {
        <div class={classes!("services-page", theme_class)}>
            <header class="app-header">
                <h1>{"Available Services"}</h1>
                <button class="settings-btn" onclick={on_settings_click}>
                    <span class="icon">{"⚙️"}</span>
                    {"Settings"}
                </button>
            </header>
            
            <div class="services-container">
                <div class="search-section">
                    <div class="search-input-container">
                        <span class="search-icon">{"🔍"}</span>
                        <input
                            type="text"
                            placeholder="Search for a service..."
                            value={(*search_query).clone()}
                            onchange={on_search_change}
                            class="search-input"
                        />
                    </div>
                </div>
                
                <div class="services-grid">
                    {if filtered_services.is_empty() && !search_query.is_empty() {
                        html! {
                            <div class="no-results">
                                <p>{"No services found for your search."}</p>
                            </div>
                        }
                    } else {
                        filtered_services.iter().enumerate().map(|(index, service)| {
                            let service_clone = service.clone();
                            let on_click = {
                                let on_service_click = on_service_click.clone();
                                let service_id = service.id.clone();
                                Callback::from(move |_| {
                                    on_service_click.emit(service_id.clone());
                                })
                            };
                            
                            let avatar_text = if service.name.contains(' ') {
                                let parts: Vec<&str> = service.name.split(' ').collect();
                                format!("{}{}", 
                                    parts[0].chars().next().unwrap_or('?'),
                                    parts.get(1).and_then(|s| s.chars().next()).unwrap_or(' ')
                                )
                            } else {
                                service.name.chars().next().unwrap_or('?').to_string()
                            };

                            html! {
                                <div 
                                    key={service.id.clone()}
                                    class="service-card"
                                    onclick={on_click}
                                    style={format!("animation-delay: {}ms", index * 100)}
                                >
                                    <div class="service-avatar">
                                        {avatar_text}
                                    </div>
                                    <div class="service-info">
                                        <h3 class="service-name">{&service.name}</h3>
                                    </div>
                                    <div class="service-arrow">{"→"}</div>
                                </div>
                            }
                        }).collect::<Html>()
                    }}
                </div>
            </div>
        </div>
    }
}