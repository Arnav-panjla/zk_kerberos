use yew::prelude::*;
use yew_router::prelude::*;

use crate::pages::{LoginPage, ServicesPage, AuthenticationPage, SettingsPage, WelcomePage};
use crate::models::SettingsModel;

#[derive(Clone, Routable, PartialEq)]
pub enum Route {
    #[at("/")]
    Login,
    #[at("/services")]
    Services,
    #[at("/authentication")]
    Authentication,
    #[at("/settings")]
    Settings,
    #[at("/welcome")]
    Welcome,
}

fn switch(route: Route) -> Html {
    match route {
        Route::Login => html! { <LoginPage /> },
        Route::Services => html! { <ServicesPage /> },
        Route::Authentication => html! { <AuthenticationPage /> },
        Route::Settings => html! { <SettingsPage /> },
        Route::Welcome => html! { <WelcomePage /> },
    }
}

#[function_component(App)]
pub fn app() -> Html {
    let settings = use_state(SettingsModel::new);

    html! {
        <div class="app">
            <BrowserRouter>
                <ContextProvider<UseStateHandle<SettingsModel>> context={settings}>
                    <Switch<Route> render={switch} />
                </ContextProvider<UseStateHandle<SettingsModel>>>
            </BrowserRouter>
        </div>
    }
}