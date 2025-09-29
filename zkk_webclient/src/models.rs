use serde::{Deserialize, Serialize};
use gloo_storage::{LocalStorage, Storage};

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum ThemeMode {
    Light,
    Dark,
    System,
}

impl Default for ThemeMode {
    fn default() -> Self {
        ThemeMode::System
    }
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct SettingsModel {
    pub theme_mode: ThemeMode,
    pub biometric_enabled: bool,
}

impl SettingsModel {
    pub fn new() -> Self {
        // Try to load from local storage, otherwise use defaults
        LocalStorage::get("settings").unwrap_or_else(|_| Self::default())
    }

    pub fn set_theme_mode(&mut self, mode: ThemeMode) {
        self.theme_mode = mode;
        self.save();
    }

    pub fn set_biometric_enabled(&mut self, enabled: bool) {
        self.biometric_enabled = enabled;
        self.save();
    }

    fn save(&self) {
        let _ = LocalStorage::set("settings", self);
    }
}

impl Default for SettingsModel {
    fn default() -> Self {
        Self {
            theme_mode: ThemeMode::System,
            biometric_enabled: false,
        }
    }
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct UserCredentials {
    pub user_id: String,
    pub password: String,
}

#[derive(Debug, Clone, PartialEq)]
pub struct Service {
    pub name: String,
    pub id: String,
}

impl Service {
    pub fn get_all_services() -> Vec<Service> {
        vec![
            Service { name: "Webmail".to_string(), id: "webmail".to_string() },
            Service { name: "Gradescope".to_string(), id: "gradescope".to_string() },
            Service { name: "Library".to_string(), id: "library".to_string() },
            Service { name: "WiFi Access".to_string(), id: "wifi".to_string() },
            Service { name: "Badal VM".to_string(), id: "badal".to_string() },
            Service { name: "Moodle".to_string(), id: "moodle".to_string() },
            Service { name: "Admin Login".to_string(), id: "admin".to_string() },
        ]
    }
}