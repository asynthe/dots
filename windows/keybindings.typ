// Windows 11 default keybindings cheat sheet: laptop keys, plus HHKB Type-S chords.
//   typst compile windows/keybindings.typ    -> windows/keybindings.pdf

#set document(title: "Windows 11 Keybindings")
#set page(paper: "us-letter", flipped: true, margin: (x: 0.35in, y: 0.3in), columns: 4)
#set columns(gutter: 6mm)
#set text(size: 7.3pt, font: ("Segoe UI", "Yu Gothic", "Microsoft YaHei", "Malgun Gothic"))
#set par(leading: 0.4em)

#let accent = rgb("#2b5797")
#show heading.where(level: 2): it => block(above: 0.85em, below: 0.35em,
  text(size: 8.8pt, weight: "bold", fill: accent, it.body))
#show heading.where(level: 3): it => block(above: 0.6em, below: 0.3em,
  text(size: 7.6pt, weight: "bold", it.body))

#let k(s) = box(inset: (x: 2pt, y: 0.5pt), outset: (y: 1pt), radius: 1.5pt,
  stroke: 0.4pt + luma(150), fill: luma(245), text(font: ("Consolas", "Yu Gothic"), size: 6.8pt, s))
// "Win + Shift + ←/→" -> one keycap per " + " part
#let keys(s) = s.split(" + ").map(k).join("+")
#let tbl(..rows) = table(
  columns: (auto, 1fr), stroke: none, inset: (x: 1.5pt, y: 1.7pt),
  fill: (_, y) => if calc.odd(y) { luma(246) },
  ..rows.pos().map(((a, b)) => (keys(a), b)).flatten(),
)
#let note(body) = block(above: 0.3em, text(size: 6.6pt, fill: luma(80), body))

#place(top, scope: "parent", float: true, clearance: 3mm,
  grid(columns: (1fr, auto), align: (left + bottom, right + bottom),
    text(size: 14pt, weight: "bold")[Windows 11 Keybindings],
    text(size: 7pt, fill: luma(100))[Laptop keys in every section · HHKB Hybrid Type-S chords at the end]))

== Learn these first
#tbl(
  ("Win", [Start; just type to search]),
  ("Alt + Tab", [Cycle windows (Shift: back)]),
  ("Win + 1…9", [Open / focus taskbar app N]),
  ("Win + ←/→", [Snap left / right]),
  ("Win + ↑/↓", [Maximize / restore, minimize]),
  ("Win + Ctrl + ←/→", [Previous / next desktop]),
  ("Alt + F4", [Close window]),
  ("Win + E", [File Explorer]),
  ("Win + V", [Clipboard history]),
  ("Win + Shift + S", [Screenshot a region]),
  ("Win + L", [Lock]),
)

=== Open a terminal
#tbl(
  ("Win + 1", [Terminal pinned in taskbar slot 1]),
  ("Win + Shift + 1", [New terminal window]),
  ("Win + X", [then I: Terminal · A: admin]),
  ("Win + R", [type `wezterm` or `wt`]),
  ("Win + `", [Windows Terminal quake drop-down]),
  ("Ctrl + Shift + Enter", [In Start: run as admin]),
)
#note[Pin terminal 1st, browser 2nd. A Start-menu shortcut can carry its own Ctrl+Alt+letter hotkey (Properties → Shortcut key).]

== Windows & snapping
#tbl(
  ("Win + Shift + ←/→", [Window to other monitor]),
  ("Win + Shift + ↑", [Stretch to full height]),
  ("Win + Z", [Snap layouts; number picks zone]),
  ("Win + D", [Show desktop]),
  ("Win + M", [Minimize all (Shift: restore)]),
  ("Win + Home", [Minimize all but active]),
  ("Win + Tab", [Task view]),
  ("Alt + Space", [Window menu: M move, S size]),
  ("Win + Ctrl + 1…9", [Last window of app N]),
  ("Win + Alt + 1…9", [Jump list of app N]),
  ("Win + T", [Walk the taskbar]),
  ("Win + B", [Walk the tray icons]),
)

== Virtual desktops
#tbl(
  ("Win + Ctrl + D", [New desktop]),
  ("Win + Ctrl + ←/→", [Switch desktop]),
  ("Win + Ctrl + F4", [Close desktop (windows move left)]),
  ("Win + Tab", [Overview; Shift+F10 on a window → Move to]),
  ("Win + Tab + Tab", [Desktop row: F2 rename, Delete close]),
)
#note[No default key jumps to desktop N or sends a window there.]

== Without the mouse
#tbl(
  ("Tab", [Next control (Shift: previous)]),
  ("←↑↓→", [Move in lists, menus, groups]),
  ("Space", [Toggle checkbox, press button]),
  ("Enter", [Default button / open]),
  ("Esc", [Cancel, close menu or dialog]),
  ("Alt", [Tap: show access-key letters]),
  ("Alt + letter", [Underlined button or field]),
  ("F10", [Focus the menu bar]),
  ("Shift + F10", [Right-click menu]),
  ("F6", [Cycle panes (Explorer, browser)]),
  ("Ctrl + Tab", [Next tab in apps and dialogs]),
  ("Win + I", [Settings, then type to search]),
)

=== Browser
#tbl(
  ("Ctrl + L", [Address bar]),
  ("Ctrl + T/W", [New / close tab]),
  ("Ctrl + Shift + T", [Reopen closed tab]),
  ("Ctrl + 1…8/9", [Tab N / last tab]),
  ("Alt + ←/→", [Back / forward]),
  ("Ctrl + F", [Find on page]),
  ("'", [Firefox: quick find in links]),
)
#note[Tridactyl or Vimium: f puts a letter hint on every link.]

== System
#tbl(
  ("Win + R", [Run: cmd, pwsh, regedit]),
  ("Win + X", [Power-user menu]),
  ("Win + I", [Settings]),
  ("Win + A", [Quick settings: wifi, sound, bt]),
  ("Win + N", [Notifications, calendar]),
  ("Ctrl + Shift + Esc", [Task Manager]),
  ("Win + P", [Display mode]),
  ("Win + K", [Cast]),
  ("Win + .", [Emoji, symbols, kaomoji]),
  ("Win + H", [Dictation]),
  ("Win + PrtSc", [Full screenshot to Pictures]),
  ("Win + Alt + R", [Record screen (Game Bar)]),
  ("Win + G", [Game Bar]),
  ("Win + Ctrl + Shift + B", [Restart graphics driver]),
  ("Win + +", [Magnifier (Win+Esc: off)]),
)

== File Explorer
#tbl(
  ("Alt + ↑", [Parent folder]),
  ("Alt + ←/→", [Back / forward]),
  ("Ctrl + L", [Address bar (type `pwsh` for a shell)]),
  ("Ctrl + T/W", [New / close tab]),
  ("Ctrl + Shift + N", [New folder]),
  ("F2", [Rename]),
  ("Ctrl + Shift + C", [Copy path]),
  ("Alt + Enter", [Properties]),
  ("Shift + Del", [Delete, skip Recycle Bin]),
)

== Text editing
#tbl(
  ("Ctrl + ←/→", [Jump by word]),
  ("Ctrl + Backspace", [Delete word back]),
  ("Ctrl + Del", [Delete word forward]),
  ("Shift + Home/End", [Select to line start / end]),
  ("Ctrl + Home/End", [Top / bottom]),
  ("Ctrl + Shift + V", [Paste plain text (many apps)]),
  ("Ctrl + Z/Y", [Undo / redo]),
)

== IME & input languages
#tbl(
  ("Win + Space", [Next input language / IME]),
  ("Win + Shift + Space", [Previous]),
  ("Alt + Shift", [Switch language (if enabled)]),
  ("Ctrl + Shift", [Switch layout (if enabled)]),
)

=== Japanese (Microsoft IME)
#tbl(
  ("Alt + `", [IME on / off (あ ↔ A)]),
  ("Ctrl + Caps", [Hiragana]),
  ("Alt + Caps", [Katakana]),
  ("Space", [Convert / candidate list]),
  ("Enter/Esc", [Confirm / cancel]),
  ("Tab", [Predictions]),
  ("Shift + ←/→", [Resize segment]),
  ("F6/F7/F8", [ひらがな / カタカナ / ｶﾀｶﾅ]),
  ("F9/F10", [Full / half-width romaji]),
)
#note[Caps is Fn+Tab on the HHKB. IME settings → Key and touch customization can put IME on/off on Ctrl+Space.]

=== Chinese (Pinyin)
#tbl(
  ("Shift", [中 / 英 mode]),
  ("Ctrl + Space", [IME on / off]),
  ("Shift + Space", [Full / half width]),
  ("Ctrl + .", [Chinese / English punctuation]),
)

=== Korean
#tbl(
  ("Right Alt", [한 / 영]),
  ("Right Ctrl", [Hanja]),
)

== Drill: two windows → desktop 3, 50/50
#let step(n) = text(weight: "bold", fill: accent, str(n))
#table(
  columns: (auto, auto, 1fr), stroke: none, inset: (x: 1.5pt, y: 1.7pt),
  fill: (_, y) => if calc.odd(y) { luma(246) },
  step(1), keys("Win + Ctrl + D"), [Repeat until desktop 3 exists],
  step(2), keys("Win + Ctrl + ←"), [Back to where the windows are],
  step(3), keys("Win + Tab"), [Task View],
  step(4), keys("←/→"), [Highlight the window],
  step(5), keys("Shift + F10"), [Its menu (HHKB: Shift+Fn+0)],
  step(6), keys("↓ … →"), [*Move to*, open the list],
  step(7), keys("↓ … Enter"), [*Desktop 3*],
  step(8), [4–7], [Same for the other window, then Esc],
  step(9), keys("Win + Ctrl + →"), [Go to desktop 3],
  step(10), keys("Alt + Tab"), [Focus the first window],
  step(11), keys("Win + ←"), [Snap it to the left half],
  step(12), keys("→ … Enter"), [Snap Assist fills the right half],
)
#note[Instead of 11–12: Win+Z, 1, then 1 or 2. Resize the split: Alt+Space, S, arrows, Enter.]

#colbreak()
== HHKB Hybrid Type-S
#note[HHK mode: ◇ is Win. No arrows or F-keys, they live on the Fn layer.]
#tbl(
  ("◇", [Win]),
  ("Fn + [ ; ' /", [↑ ← → ↓]),
  ("Fn + K/,", [Home / End]),
  ("Fn + L/.", [PgUp / PgDn]),
  ("Fn + 1…=", [F1–F12]),
  ("Fn + I", [PrtSc]),
  ("Fn + Tab", [Caps Lock]),
)

=== Laptop shortcut → HHKB chord
#tbl(
  ("◇ + Fn + ;/'", [Win+←/→ snap]),
  ("◇ + Fn + [//", [Win+↑/↓ maximize, minimize]),
  ("◇ + Ctrl + Fn + ;/'", [Win+Ctrl+←/→ switch desktop]),
  ("◇ + Ctrl + Fn + 4", [Win+Ctrl+F4 close desktop]),
  ("◇ + Shift + Fn + ;/'", [Win+Shift+←/→ other monitor]),
  ("◇ + Fn + K", [Win+Home minimize others]),
  ("◇ + Fn + I", [Win+PrtSc full screenshot]),
  ("Alt + Fn + 4", [Alt+F4 close window]),
  ("Shift + Fn + 0", [Shift+F10 right-click menu]),
  ("Fn + 2", [F2 rename]),
  ("Fn + 6", [F6 cycle panes]),
  ("Alt + Fn + [", [Alt+↑ parent folder]),
  ("Alt + Fn + ;/'", [Alt+←/→ back / forward]),
  ("Ctrl + Fn + ;/'", [Ctrl+←/→ jump by word]),
  ("Shift + Fn + K/,", [Shift+Home/End select line]),
  ("Ctrl + Fn + Tab", [Ctrl+Caps hiragana]),
  ("Fn + 6…0", [F6–F10 IME conversion]),
)
#note[Tip: PowerToys Keyboard Manager can map Right ◇ to the Menu key, a one-key Shift+F10.]
