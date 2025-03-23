;; TODO
;; ASCII ART HERE PLZ

;; 1. Package Manager (straight.el)
;; 2. Settings
;; 3. Theme
;; 4. Font
;; 5. Keybinds
;; 6. Packages
;; 7. Org mode
;; 7. Extra

;; ------------------------- Package Manager (straight.el) -------------------------
;; https://github.com/radian-software/straight.el

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(setq straight-use-package-by-default t) ;; Use as default
(setq package-enable-at-startup nil) ;; Improves startup speed if not using package.el
(straight-use-package 'use-package) ;; Integrate with use-package

;; ------------------------- Packages (1) -------------------------
;; Evil Mode
(use-package evil
	     :init
	     (setq evil-want-integration t)     ; Enable integration with other modes
	     (setq evil-want-keybinding nil)    ; Avoid default keybindings (use evil-collection)
	     (setq evil-want-C-u-scroll t)      ; Enable scrolling with Ctrl+U
	     (setq evil-want-C-i-jump nil)      ; Prevent conflict with TAB
	     :config
	     (evil-mode 1))

(setq evil-undo-system 'undo-redo)          ; Undo like vim

;; Evil Collection (for Evil Mode)
(use-package evil-collection
	     :after evil
         :ensure t
	     :config
	     (evil-collection-init))

;; Unmap keys so that `setq org-return-follows-link` works.
(with-eval-after-load 'evil-maps
                      (define-key evil-motion-state-map (kbd "SPC") nil)
                      (define-key evil-motion-state-map (kbd "RET") nil)
                      (define-key evil-motion-state-map (kbd "TAB") nil))

;; Dired (directory editor)
;(use-package all-the-icons-dired)
;(use-package dired-open)
;(use-package peep-dired)

;; Vertico
(use-package vertico
             :init
             (vertico-mode))
(vertico-mode 1)

;; Savehist
(use-package savehist ; Save minibuffer history
             :init
             (savehist-mode))

;; Orderless
(use-package orderless
             :custom
             (completion-styles '(orderless basic)))

(use-package consult) ; Consult
(setq consult-buffer-filter '("\\`\\*"))     ; Hide buffers starting with "*"
(use-package embark) ; Embark
(use-package embark-consult)

;; Marginalia
(use-package marginalia 
             :init
             (marginalia-mode))

;; Which-key
(use-package which-key
             :init (which-key-mode)
             :diminish which-key-mode
             :config
             (setq which-key-idle-delay 1
                   which-key-side-window-location 'bottom
                   which-key-sort-order #'which-key-key-order-alpha
                   which-key-sort-uppercase-first nil
                   which-key-add-column-padding 1
                   which-key-max-display-columns nil
                   which-key-min-display-lines 6
                   which-key-side-window-slot -10
                   which-key-side-window-max-height 0.25
                   which-key-max-description-length 25
                   which-key-allow-imprecise-window-fit t
                   which-key-separator " → "))

;; ------------------------- Packages (2) -------------------------

;; All the Icons
(use-package all-the-icons
             :ensure t
             :if (display-graphic-p))
(use-package all-the-icons-dired
             :hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

;; Beacon (cursor blink)
;; https://github.com/Malabarba/beacon
;(use-package beacon
	     ;:config
	     ;(beacon-mode 1))

(use-package doom-themes)     ; Doom Themes
(use-package doom-modeline)   ; Doom Modeline
(doom-modeline-mode 1)
(display-battery-mode 1)      ; Display battery on modeline
(use-package emojify
             :hook (after-init . global-emojify-mode))

(use-package hide-mode-line)  ; Hide the modeline
;(global-hide-mode-line mode 1)
;(add-hook 'neotree-mode-hook #'hide-mode-line-mode) ; FIX

(use-package valign)          ; Vertical align
;(add-hook 'org-mode-hook #'valign-mode)

;; ------------------------- Packages - Org -------------------------


(use-package org-tidy           ; Hides :PROPERTY:
             :ensure t
             :hook
             (org-mode . org-tidy-mode))

;; ------------------------- Settings -------------------------

;; Open a file instead of Scratch buffer
;; https://superuser.com/questions/400457/how-to-automatically-open-a-file-when-emacs-start
(find-file "~/notes/main.org")

;; Main
;(global-display-line-numbers-mode t)        ; Line numbers
(setq-default indent-tabs-mode nil)         ; Use spaces instead of tabs
(setq-default tab-width 4)                  ; 4 spaces
(show-paren-mode 1)                         ; Enable parentheses matching

;; Fcitx5 - Japanese Input
;(use-package mozc)
;(require 'mozc)
;(setq default-input-method "japanese-mozc")
(setenv "GTK_IM_MODULE" "fcitx")
(setenv "QT_IM_MODULE" "fcitx")
(setenv "XMODIFIERS" "@im=fcitx")

;; Basic UI settings
(setq inhibit-startup-message t)          ; No startup message
(menu-bar-mode -1)                        ; Disable menu bar
(scroll-bar-mode -1)                      ; Disable scroll bar
(tool-bar-mode -1)                        ; Disable tool bar
(tooltip-mode -1)                         ; Disable tooltips
(setq-default line-spacing 1)
(setq truncate-lines nil)                 ; Enable word wrap

;; Disabling line numbering for certain modes
(dolist (mode '(org-mode-hook
                shell-mode-hook
                term-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode -1))))

;; Fringes
;(set-fringe-mode 7)
(set-fringe-mode 0)                       ; No fringes

;; Margins / Padding
(setq-default left-margin-width 3)
(setq-default right-margin-width 3)
(set-window-buffer nil (current-buffer))

;; Transparency
(set-frame-parameter nil 'alpha-background 80) ; For current frame
(add-to-list 'default-frame-alist '(alpha-background .80)) ; For new frames

;; Auto-save
;(setq auto-save-default t)
;(setq auto-save-timeout 20)
;(setq auto-save-interval 200)

;; Enable recent files mode
(recentf-mode 1)
(setq recentf-max-saved-items 50)

;; Scrolling
(setq mouse-wheel-follow-mouse 't) ;; Scroll window under mouse
(setq scroll-conservatively 101) ;; Value greater than 100 gets rid of half page jumping
(setq mouse-wheel-progressive-speed t) ;; Accelerate scrolling

;; Precision pixel scroll
(pixel-scroll-precision-mode 1)
(setq pixel-scroll-use-momentum t) ;; Keep the momentum when scrolling
(setq pixel-scroll-precision-large-scroll-height 40.0) ;; Scroll with mouse as smooth as touchpad

;; ------------------------- Theme -------------------------
;;
(load-theme 'doom-meltbus t) ; THEME
(setq doom-themes-enable-bold t)        ; If nil, bol is disabled
(setq doom-themes-enable-italics t)     ; If nil, italics is disabled
;;
;; ------------------------- Font -------------------------
;; Font -> JetBrainsMono
(set-face-attribute 'default nil
		    :font "JetBrainsMono Nerd Font 14"
		    :weight 'regular)

(set-face-attribute 'variable-pitch nil
		    :font "JetBrainsMono Nerd Font 14"
		    :weight 'regular)

;; Inherited face by org-table and org-block
(set-face-attribute 'fixed-pitch nil
		    :font "JetBrainsMono Nerd Font 14"
		    :weight 'regular)

;; Makes commented text and keywords italics.
;; Works in emacsclient
(set-face-attribute 'font-lock-comment-face nil
                    :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
                    :slant 'italic)

;; Required by emacsclient, if not used fonts will appear smaller
(add-to-list 'default-frame-alist '(font . "JetBrainsMono Nerd Font 14"))

;; Font size
(set-face-attribute 'default nil :height 120)

;; Ligatures
(use-package ligature
	     :config
	     (ligature-set-ligatures 'prog-mode '("<---" "<--"  "<<-" "<-" "->" "-->" "--->" "<->" "<-->" "<--->" "<---->" "<!--"
                                       "<==" "<===" "<=" "=>" "=>>" "==>" "===>" ">=" "<=>" "<==>" "<===>" "<====>" "<!---"
                                       "<~~" "<~" "~>" "~~>" "::" ":::" "==" "!=" "===" "!=="
                                       ":=" ":-" ":+" "<*" "<*>" "*>" "<|" "<|>" "|>" "+:" "-:" "=:" "<******>" "++" "+++"))
	     (ligature-set-ligatures 'org-mode '("<---" "<--"  "<<-" "<-" "->" "-->" "--->" "<->" "<-->" "<--->" "<---->" "<!--"
                                       "<==" "<===" "<=" "=>" "=>>" "==>" "===>" ">=" "<=>" "<==>" "<===>" "<====>" "<!---"
                                       "<~~" "<~" "~>" "~~>" "::" ":::" "==" "!=" "===" "!=="
                                       ":=" ":-" ":+" "<*" "<*>" "*>" "<|" "<|>" "|>" "+:" "-:" "=:" "<******>" "++" "+++"))
	     (global-ligature-mode t))
	
;; ------------------------- Org Mode -------------------------
(add-hook 'org-mode-hook 'turn-on-flyspell) ; Flyspell (Spell Checking)
(setq org-startup-with-inline-images t)

;; Settings
(setq org-directory "~/notes"
      org-id-track-globally t
      org-return-follows-link t
      org-hide-block-startup nil      ; Don't fold code blocks
      org-hide-emphasis-markers t     ; Hide bold and italics symbols
      org-hide-leading-stars t        ; Hide org header leading stars
      org-startup-folded 'overview    ; Show only top-level headings
      org-startup-indented t          ; Indent the text below headers
      org-startup-folded t            ; Open with headers folded
      org-log-done 'time
      org-pretty-entities t
      org-ellipsis " … "
      org-adapt-identation nil

      ;; Syntax Highlighting
      org-src-fontify-natively t
      org-src-tab-acts-natively t
      org-config-babel-evaluate nil
      org-edit-src-content-identation 0)
(require 'org-mouse)                  ; Enable the mouse

;; Headings size
(custom-set-faces
 '(org-level-1 ((t (:inherit outline-1 :height 1.0))))
 '(org-level-2 ((t (:inherit outline-2 :height 1.0))))
 '(org-level-3 ((t (:inherit outline-3 :height 1.0))))
 '(org-level-4 ((t (:inherit outline-4 :height 1.0))))
 '(org-level-5 ((t (:inherit outline-5 :height 1.0))))
 '(org-document-title ((t (:inherit outline-3 :height 0.8)))))

;; Font size for org faces
(defun my-org-faces ()
  (set-face-attribute 'org-todo nil :height 0.8)
  (set-face-attribute 'org-level-1 nil :height 1.0)
  (set-face-attribute 'org-level-2 nil :height 1.0)
  (set-face-attribute 'org-level-3 nil :height 1.0))

;; Language-specific colors for code blocks
(setq org-src-block-faces '(("bash" (:background "#121212" :extend t))
                            ("c" (:background "#121212" :extend t))
                            ("cpp" (:background "#121212" :extend t))
                            ("dockerfile" (:background "#121212" :extend t))
                            ("haskell" (:background "#121212" :extend t))
                            ("emacs-lisp" (:background "#121212" :extend t))
                            ("json" (:background "#121212" :extend t))
                            ("latex" (:background "#121212" :extend t))
                            ("lua" (:background "#121212" :extend t))
                            ("nix" (:background "#121212" :extend t))
                            ("org" (:background "#121212" :extend t))
                            ("python" (:background "#121212" :extend t))
                            ("pwsh" (:background "#012456" :extend t))
                            ("text" (:background "#121212" :extend t))
                            ("shell" (:background "#121212" :extend t))
                            ("yaml" (:background "#121212" :extend t))
                            ("xml" (:background "#6D86FF" :extend t))))

;; Org Roam
;; ...

;; ------------------------- Keybinds -------------------------
(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)

;; Buffers and Files
(global-set-key (kbd "M-[") 'previous-buffer)
(global-set-key (kbd "M-]") 'next-buffer)

(evil-define-key '(normal visual) global-map
                 (kbd "SPC .") #'find-file
                 (kbd "SPC ,") #'consult-buffer)

;; ------------------------- Extra -------------------------

;; EOF
(provide 'config)
