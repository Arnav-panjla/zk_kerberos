use yew::prelude::*;

#[function_component(Spinner)]
pub fn spinner() -> Html {
    html! {
        <div class="spinner">
            <div class="spinner-ring"></div>
        </div>
    }
}