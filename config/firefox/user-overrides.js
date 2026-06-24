// user-overrides.js
// DRM
user_pref("media.eme.enabled", true);
user_pref("media.gmp-widevinecdm.enabled", true);
user_pref("browser.startup.page", 3); // restore previous session
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("full-screen-api.warning.timeout", 0);

// don't delete cookies and site data
user_pref("privacy.clearOnShutdown.cookies", false);
user_pref("privacy.sanitize.sanitizeOnShutdown", false);
user_pref("network.cookie.lifetimePolicy", 0);
