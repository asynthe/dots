// user-overrides.js
// General
user_pref("general.autoScroll", true);

// DRM
user_pref("media.eme.enabled", true);
user_pref("media.gmp-widevinecdm.enabled", true);
user_pref("browser.startup.page", 3); // restore previous session
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("full-screen-api.warning.timeout", 0);

// skip the download confirmation
user_pref("browser.download.always_ask_before_handling_new_types", false);
user_pref("browser.download.useDownloadDir", true);

// don't delete cookies and site data
user_pref("privacy.clearOnShutdown.cookies", false);
user_pref("privacy.sanitize.sanitizeOnShutdown", false);
user_pref("network.cookie.lifetimePolicy", 0);

// Fonts
// Firefox takes its *chrome* font (tabs, menus, dialogs) from GTK, so that half
// lives in config/gtk-3.0/settings.ini. Everything below is page content only.
//
// Body text stays proportional on purpose -- the rest of the system is mono,
// but long-form reading in a mono face is measurably worse. Code on a page
// still lands on JetBrainsMono NF, matching the terminal-adjacent surfaces.
user_pref("font.default.x-western", "sans-serif");
user_pref("font.name.sans-serif.x-western", "Noto Sans");
user_pref("font.name.serif.x-western", "Noto Serif");
user_pref("font.name.monospace.x-western", "JetBrainsMono Nerd Font");
user_pref("font.size.variable.x-western", 15);
user_pref("font.size.monospace.x-western", 15);

// Japanese, to match the fontconfig CJK fallbacks in nix/nixos/desktop/look.nix
user_pref("font.name.sans-serif.ja", "Noto Sans CJK JP");
user_pref("font.name.serif.ja", "Noto Serif CJK JP");
user_pref("font.name.monospace.ja", "Noto Sans Mono CJK JP");

// Forces the above onto every site, ignoring their @font-face. Off by design:
// it also kills icon fonts, so navs and buttons across the web turn into
// stray letters. Flip it only if you want the uniformity that badly.
// user_pref("browser.display.use_document_fonts", 0);
