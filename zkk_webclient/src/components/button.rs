use yew::prelude::*;

#[derive(Properties, PartialEq)]
pub struct ButtonProps {
    pub onclick: Callback<MouseEvent>,
    pub children: Children,
    #[prop_or_default]
    pub class: String,
    #[prop_or_default]
    pub disabled: bool,
    #[prop_or_default]
    pub button_type: String,
}

#[function_component(Button)]
pub fn button(props: &ButtonProps) -> Html {
    html! {
        <button
            type={props.button_type.clone()}
            class={props.class.clone()}
            onclick={props.onclick.clone()}
            disabled={props.disabled}
        >
            {props.children.clone()}
        </button>
    }
}