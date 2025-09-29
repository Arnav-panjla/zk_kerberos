use wasm_bindgen::prelude::*;
use yew::prelude::*;

mod app;
mod components;
mod pages;
mod models;
mod utils;

use app::App;

#[wasm_bindgen(start)]
pub fn run_app() {
    yew::Renderer::<App>::new().render();
}