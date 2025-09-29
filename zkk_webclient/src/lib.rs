use wasm_bindgen::prelude::*;
use yew::prelude::*;
use yew::Renderer;

mod app;
mod components;
mod pages;
mod models;
mod utils;

use app::App;

#[wasm_bindgen(start)]
pub fn run_app() {
    Renderer::<App>::new().render();
}