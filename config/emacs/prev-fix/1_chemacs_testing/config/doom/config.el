;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;;;;;;;;;;;;;;;;;;;; CONFIG ;;;;;;;;;;;;;;;;;;;;

;; USER
(setq user-full-name "Benjamin Dunstan"
      user-mail-address "benjadunstan@gmail.com")

;;;;;;;;;; SYSTEM ;;;;;;;;;;
(display-battery-mode 1)
(setq doom-theme 'doom-meltbus)
(setq confirm-kill-emacs nil)

;; DOOM DASHBOARD MENU SECTIONS
(setq +doom-dashboard-menu-sections (cl-subseq +doom-dashboard-menu-sections 0 0))
;; LINE STYLE AND NUMBERING
;; line numbers on the left can be set to t, nil or relative
(setq display-line-numbers-type nil)
;; LINE VISUAL STYLE
(setq global-hl-line-mode nil)
(setq hl-line-mode nil)
;;(setq global-hl-line-modes '(prog-modes markdown-mode))

;; FRINGE
;; (color line on the left or right border)
(setq fringe-mode nil)

;; BACKGROUND COLOR FOR CODE BLOCKS

;; CUSTOM ORG HEADINGS

(after! org
  (setq org-fontify-whole-heading-line t
        org-fontify-done-headline t
        org-fontify-quote-and-verse-blocks t)
  (defun my/org-mode-hook ()
    (set-face-attribute 'org-level-1 nil :height 1.0 :background nil))
  (add-hook 'org-load-hook #'my/org-mode-hook))

;; CUSTOM ORG CODE BLOCKS
;;(after! org
  ;;(require 'color)
  ;;(set-face-attribute 'org-block nil :background
                    ;;(color-darken-name
                     ;;(face-attribute 'default :background) 3)))

;; ORG APPEAR
(add-hook! org-mode :append #'org-appear-mode)

;; TAB BAR
;; there are two tab modes, one which is tab-bar-mode
;; and the other one is tab-line-mode
(setq global-tab-line-mode nil)
(setq tab-line-mode nil)

;; MARGINS/PADDING
(setq-default left-margin-width 5 right-margin-width 5)
(set-window-buffer nil (current-buffer))

;;(set-window-margins (selected-window) 2 2)
;; add it to popup buffers
;;(add-hook! '+popup-buffer-mode-hook
;;  (set-window-margins (selected-window) 1 1))

;; SAVING FILES

;; this creates copies of files in ~/emacs.d/.local/cache/{autosave,backup}
;; then deletes it when you save the buffer.
;;(setq auto-save-default t
;;      make-backup-files t)

;; auto save automatically when changing buffers and when idle
(super-save-mode +1)
(setq super-save-auto-save-when-idle t)

;; save whenever you unfocus Emacs.
;;(add-hook! 'focus-out-hook (save-some-buffers t))
;; save after 3s of idle time.
;;(run-with-idle-timer 3 t #'save-some-buffers t)

;; FONT
(setq doom-font (font-spec :family "Iosevka" :size 28)
      doom-unicode-font (font-spec :family "A-OTF Shin Go Pro" :weight 'bold :size 32)
      doom-variable-pitch-font (font-spec :family "JetBrainsMono NF" :size 24)
      doom-big-font (font-spec :family "Iosevka" :size 30))
;;      dart-format-on-save t)
(after! doom-themes
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t))
(custom-set-faces!
  '(font-lock-comment-face :slant italic)
  '(font-lock-keyword-face :slant italic))

;; APPS
;;(after! projectile
;;  (setq projectile-project-search-path '("~/main/sync/code")))

;; KEYBINDINGS TEST
;;(map! :leader
;;      (:prefix ("e" . "applications")
;;      :desc "org-roam completion at point"
;;      "r" #'completion-at-point))

(map! :leader
      (:prefix ("z" . "shortcuts")
      :desc "timestamp"
      "z" #'org-time-stamp))

;; MAP TEST!
;;(map! :leader
;;      (:prefix ("e" . "applications")
;;      :desc "Export Org to HTML"
;;      "e" #'org-html-export-to-html))

;;(after! org
;;        (require 'org-bullets)
;;        (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

;; ORG-JOURNAL
(setq org-journal-dir "~/sync/notes/org/irl/journal"
      org-journal-date-prefix "#+TITLE: "
      org-journal-time-prefix "* "
      org-journal-date-format "%a, %d-%m-%Y"
      org-journal-file-format "%Y-%m-%d.org")

;; ORG
(setq org-directory "~/sync/notes/org")
(after! org
  (setq org-hide-emphasis-markers t
        org-superstar-headline-bullets-list '("⁖" "◉" "○" "✸" "✿")
        org-todo-keywords '((sequence "TODO(t)" "WAIT(w)" "|" "DONE(d)" "CANCELLED(c)" ))
        org-log-done 'time
        ;;org-log-done 'note
        org-fancy-priorities-list '("！" "" "[B]" "[C]")
        org-priority-faces
        '((?A :foreground "#ff6c6b" :weight bold)
          (?B :foreground "#98be65" :weight bold)
          (?C :foreground "#c678dd" :weight bold))
        org-enable-priority-commands t
        org-highest-priority ?A
        org-default-priority ?B
        org-lowest-priority ?D))

;;(after! org
;;  (setq org-superstar-headline-bullets-list '("#"))

;; ORG-AGENDA
(after! org
  (setq org-agenda-files '("~/sync/notes/org/irl/daily")
        ;;org-agenda-include-diary t
        org-agenda-block-separator 8411
        org-agenda-start-on-weekday nil
        org-agenda-start-day "-3d"
        org-agenda-span 15))

(setq org-agenda-custom-commands
      '(("v" "A better agenda view"
         ((tags "PRIORITY=\"A\""
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "High-priority unfinished tasks:")))
          (tags "PRIORITY=\"C\""
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "Medium-priority unfinished tasks:")))
          (tags "PRIORITY=\"D\""
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "Low-priority unfinished tasks:")))
          (agenda "")
          (alltodo "")))))


;; ORG-ROAM
(setq org-roam-directory "~/sync/notes/org")

;; HELPFUL ORG-ROAM KEYBINDINGS
(map! :leader
       :desc "Main file"
       "n r m" #'(lambda () (interactive) (find-file "~/sync/notes/org/main.org"))
       ;;:desc "Completion at point"
       ;;"n r c" #'completion-at-point
       :desc "Dailies today"
       "n r ." #'org-roam-dailies-goto-today
       :desc "Dailies find date"
       "n r ," #'org-roam-dailies-goto-date
       :desc "Journal new entry"
       "n r j" #'org-journal-new-entry
       :desc "Agenda"
       "n r z" #'org-agenda
       :desc "Tasks file"
       "n r c" #'(lambda () (interactive) (find-file "~/sync/notes/org/irl/daily/tasks.org"))
       :desc "Events file"
       "n r x" #'(lambda () (interactive) (find-file "~/sync/notes/org/irl/daily/events.org")))


;; ORG-AGENDA from ORG-ROAM NOTES
(after! org-roam
  (defun my/org-roam-filter-by-tag (tag-name)
    (lambda (node)
      (member tag-name (org-roam-node-tags node)))))

(after! org-roam
  (defun my/org-roam-list-notes-by-tag (tag-name)
    (mapcar #'org-roam-node-file
            (seq-filter
             (lambda (node)
               (member tag-name (org-roam-node-tages node)
        (my/org-roam-filter-by-tag tag-name)))))))

;; DAILIES
(after! org-roam
  (setq org-roam-db-autosync-mode t
        org-roam-dailies-directory "daily/"
        org-roam-dailies-capture-templates
        '(("d" "default" entry
           (file "~/sync/notes/org/other/templates/daily.org")
           ;;"* TODO %? (org-time-stamp)"
        ;;'(("d" "default" entry "* %<%I:%M %p>: %?"
           :if-new (file+head "irl/daily/%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n")))))


;; CAPTURE TEMPLATES
(after! org-roam
    (setq org-roam-capture-templates
          '(("d" "default note" plain
             "%?"
             :if-new
             (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+date: %U\n")
             :unnarrowed t)


            ("a" "app" plain
             (file "~/sync/notes/org/other/templates/app.org")
             :if-new
             (file+head "app/%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
             :unnarrowed t)


            ("e" "blog entry" plain
             (file "~/sync/notes/org/other/templates/blog.org")
             :if-new
             (file+head "irl/blog/%<%Y%m%>-${slug}.org" "#+title: ${title}\n")
             :unnarrowed t)


            ("b" "book" plain
             (file "~/sync/notes/org/other/templates/booknote.org")
             :if-new
             (file+head "media/book/%<%Y%m%>-${slug}.org" "#+title: ${title}\n")
             :unnarrowed t)


            ("g" "guide" plain
             (file "~/sync/notes/org/other/templates/guide.org")
             :if-new
             (file+head "tguide/%<%Y>-${slug}.org" "#+title: ${title}\n")
             :unnarrowed t)


;;            ("l" "programming language" plain
;;             (file "~/main/sync/docs/org/templates/main.org")
;;             "* Characteristics\n\n- Family: %?\n- Inspired by: \n\n* Reference:\n\n"
;;             :if-new
;;             (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
;;             :unnarrowed t)


            ("m" "main" plain
             (file "~/sync/notes/org/other/templates/main.org")
            :if-new
            (file+head "other/main/${slug}.org" "#+title: ${title}\n")
            :unnarrowed t)


            ("n" "notes" plain
             "%?"
             :if-new
             (file+head "other/random/%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+date: %U\n")
             :unnarrowed t)


            ("s" "study" plain
             (file "~/sync/notes/org/other/templates/study.org")
             :if-new
             (file+head "study/%<%Y%m%d>-${slug}.org" "#+title: ${title}\n")
             :unnarrowed t)



            ("p" "project" plain "* Goals\n\n%?\n\n* Tasks\n\n** TODO Add initial tasks\n\n* Dates\n\n"
             :if-new
             (file+head "irl/project/%<%Y%m%d>-${slug}.org" "#+title: ${title}\n#+filetags: Project")
             :unnarrowed t)



            ("v" "media" plain
             (file "~/sync/notes/org/other/templates/media.org")
            :if-new
            (file+head "media/${slug}.org" "#+title: ${title}\n")
            :unnarrowed t)


            ("w" "work" plain "* Goals\n\n%?\n\n* Tasks\n\n** TODO Add initial tasks\n\n* Dates\n\n"
             :if-new
             (file+head "irl/work/%<%Y%m%d>-${slug}.org" "#+title: ${title}\n#+filetags: Project")
             :unnarrowed t))))
