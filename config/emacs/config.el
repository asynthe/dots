;; ███████╗███╗   ███╗ █████╗  ██████╗███████╗
;; ██╔════╝████╗ ████║██╔══██╗██╔════╝██╔════╝
;; █████╗  ██╔████╔██║███████║██║     ███████╗
;; ██╔══╝  ██║╚██╔╝██║██╔══██║██║     ╚════██║
;; ███████╗██║ ╚═╝ ██║██║  ██║╚██████╗███████║
;; ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝╚══════╝

;; TODO If i scroll down can i keep cursor where it is, so if i move the arrows then it goes back to that line.


; Package Manager
; Packages (1)
; Packages (2)
; Packages (Org Mode)
; Settings
; Keybinds
; Settings - Theme
; Settings - Font
; Settings - Org Mode
; Settings - Org Roam

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

;; Configuration
(straight-use-package 'use-package)
(use-package el-patch
  :straight t)
(setq straight-use-pakage-by-default t)

;; ------------------------- Packages (1) -------------------------

;; Vertico
;; Marginalia
;; Orderless
;; Consult
;; Embark
;; embark-consult
;; wgrep

;; Vertico
(use-package vertico
  :straight t
  :config
  (setq vertico-cycle t)
  (setq vertico-resize nil)
  (vertico-mode 1))

;; Marginalia
(use-package marginalia
  :straight t
  :config
  (marginalia-mode 1))

;; Orderless
(use-package orderless
  :straight t
  :config
  (setq completion-styles '(orderless basic)))

;; Consult
(use-package consult
  :straight t
  :config
  (setq consult-buffer-filter '("\\`\\*"))      ; Hide buffers starting with "*"
  :bind (
         ("M-s M-g" . consult-grep)             ; A recursive grep
         ("M-s M-f" . consult-find)             ; Search for files names recursively
         ("M-s M-o" . consult-outline)          ; Search through the outline (headings) of the file
         ("M-s M-l" . consult-line)             ; Search the current buffer
         ("M-s M-b" . consult-buffer)))         ; Switch to another buffer, or bookmarked file, or recently opened file.

;; Embark
(use-package embark
  :straight t
  :bind (("C-." . embark-act)
         :map minibuffer-local-map
         ("C-c C-c" . embark-collect)
         ("C-c C-e" . embark-export)))

;; embark-consult
(use-package embark-consult
  :straight t)

;; wgrep
(use-package wgrep
  :straight t
  :bind ( :map grep-mode-map
          ("e" . wgrep-change-to-wgrep-mode)
          ("C-x C-q" . wgrep-change-to-wgrep-mode)
          ("C-c C-c" . wgrep-finish-edit)))

;; (built-in)
(savehist-mode 1)

;; ------------------------- Packages (2) -------------------------
;; Evil Mode
(use-package evil
      :straight t
	     :init
	     (setq evil-want-integration t)      ; Enable integration with other modes
	     (setq evil-want-keybinding nil)     ; Avoid default keybindings (use evil-collection)
	     (setq evil-want-C-u-scroll t)       ; Enable scrolling with Ctrl+U
	     (setq evil-want-C-i-jump nil)       ; Prevent conflict with TAB
       (setq evil-undo-system 'undo-redo)    ; Undo like vim
	     :config
	     (evil-mode 1))

;; Evil Collection (for Evil Mode)
(use-package evil-collection
	     :after evil
         :straight t
	     :config
	     (evil-collection-init))

;; Unmap keys so that `setq org-return-follows-link` works.
(with-eval-after-load 'evil-maps
                      (define-key evil-motion-state-map (kbd "SPC") nil)
                      (define-key evil-motion-state-map (kbd "RET") nil)
                      (define-key evil-motion-state-map (kbd "TAB") nil))

;; ------------------------- Packages - Org Mode -------------------------

(use-package valign                         ; Vertical align
  :straight t)
(add-hook 'org-mode-hook #'valign-mode)

;; ------------------------- Settings -------------------------
(global-display-line-numbers-mode t)        ; Line numbers
(setq-default indent-tabs-mode nil)         ; Use spaces instead of tabs
(setq-default tab-width 4)                  ; 4 spaces
(show-paren-mode 1)                         ; Enable parentheses matching

;; Basic UI settings
(setq inhibit-startup-message t)            ; No startup message
(menu-bar-mode -1)                          ; Disable menu bar
(scroll-bar-mode -1)                        ; Disable scroll bar
(tool-bar-mode -1)                          ; Disable tool bar
(tooltip-mode -1)                           ; Disable tooltips
(setq-default line-spacing 1)

;; Disabling line numbering for certain modes
(dolist (mode '(org-mode-hook
                shell-mode-hook
                term-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode -1))))

;; Mouse Scrolling
(setq mouse-wheel-follow-mouse 't)          ; Scroll window under mouse
;(setq mouse-wheel-progressive-speed t)     ; Accelerate scrolling
(setq scroll-conservatively 101)            ; Value greater than 100 gets rid of half page jumping

;; Mouse - Precision pixel scroll
;(pixel-scroll-precision-mode 1)
;(setq pixel-scroll-precision-large-scroll-height 40.0) ; Scroll with mouse as smooth as touchpad
;(setq pixel-scroll-use-momentum t)         ; Keep the momentum when scrolling

; TODO
(setq mac-mouse-whell-mode t)

;; Transparency
(cond
 ;; Linux
 ((and (eq system-type 'gnu/linux)

  ;; This are the two lines that set up transparency, you can use them outside the cond if you want.
  (set-frame-parameter nil 'alpha-background 80)                    ; For current frame
  (add-to-list 'default-frame-alist '(alpha-background . 80))))     ; For new frames

 ;; macOS
 ((eq system-type 'darwin)
  (set-frame-parameter nil 'alpha '(70 . 80))
  (add-to-list 'default-frame-alist '(alpha . (80 . 80))))

 ;; Windows
 ((eq system-type 'windows-nt)
  (set-frame-parameter nil 'alpha '(80 . 80))
  (add-to-list 'default-frame-alist '(alpha . (80 . 80)))))

;; ------------------------- Keybinds -------------------------
;; Setting up Evil-style keybindings
(use-package general
  :straight t
  :config
  (general-create-definer my/keybinds
    :keymaps '(normal visual)
    :prefix "SPC"
    :global-prefix "C-SPC") ; Optional: allows SPC outside evil too
)

;; Description on the minibuffer
;(use-package which-key
;             :straight t
;             :init (which-key-mode)
;             :diminish which-key-mode
;             :config
;             (setq which-key-idle-delay 1
;                   which-key-side-window-location 'bottom
;                   which-key-sort-order #'which-key-key-order-alpha
;                   which-key-sort-uppercase-first nil
;                   which-key-add-column-padding 1
;                   which-key-max-display-columns nil
;                   which-key-min-display-lines 6
;                   which-key-side-window-slot -10
;                   which-key-side-window-max-height 0.25
;                   which-key-max-description-length 25
;                   which-key-allow-imprecise-window-fit t
;                   which-key-separator " → "))

(use-package which-key
  :straight t
  :init
  (setq which-key-idle-delay 0.3) ; Faster pop-up
  :config
  (which-key-mode)
  (which-key-enable-god-mode-support)) ; optional

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)

;; Buffers and Files
(global-set-key (kbd "M-[") 'previous-buffer)
(global-set-key (kbd "M-]") 'next-buffer)

;(evil-define-key '(normal visual) global-map
;                 (kbd "SPC .") #'find-file
;                 (kbd "SPC ,") #'consult-buffer)

;; Keybinds
(my/keybinds

  ;; Files
  "."   '(find-file :which-key "Find file")
  ","   '(consult-buffer :which-key "Switch buffer")
  "fs"  '(save-buffer :which-key "Save file")

  ;; Configuration
  "uc"  '(load-file "~/.config/emacs/config.el" :which-key "Reload configuration")

  ;; Buffers
  "b"   '(:ignore t :which-key "Buffers commands")
  "bk"  '(kill-this-buffer :which-key "Kill buffer")

  ;; Org Roam
  "n"  '(:ignore t :which-key "Org roam commands")
  "nf" '(org-roam-node-find :which-key "Find and open note")
  "nu" '(org-roam-db-sync :which-key "Notes database update")
  "ri" '(org-id-get-create :which-key "Insert org-id")
)

;; ------------------------- Settings - Theme -------------------------
(use-package doom-themes
  :straight t)
(load-theme 'doom-meltbus t)                ; Load a theme
(setq doom-themes-enable-bold t)            ; If nil, bol is disabled
(setq doom-themes-enable-italics t)         ; If nil, italics is disabled

;; ------------------------- Settings - Font (JetBrainsMono) -------------------------

;; General Font Settings
(set-face-attribute 'default nil :height 120)                                       ; Font size
(set-face-attribute 'font-lock-comment-face nil :slant 'italic)                     ; Makes commented text and keywords italics, works in emacsclient
(set-face-attribute 'font-lock-keyword-face nil :slant 'italic)                     ; Makes commented text and keywords italics, works in emacsclient

;; System-os specific
(cond
 ((or (eq system-type 'gnu/linux) (eq system-type 'darwin)) 
  (progn

    ; Linux and macOS configuration
    (add-to-list 'default-frame-alist '(font . "JetBrainsMono Nerd Font 12"))       ; Required by emacsclient, if not used fonts will appear smaller
    (set-face-attribute 'default nil
                        :font "JetBrainsMono Nerd Font 12"
                        :weight 'regular)
    (set-face-attribute 'variable-pitch nil
                        :font "JetBrainsMono Nerd Font 12"
                        :weight 'regular)
    (set-face-attribute 'fixed-pitch nil
                        :font "JetBrainsMono Nerd Font 12"
                        :weight 'regular)

  ))
 ((eq system-type 'windows-nt) 
  (progn
  
    ; Windows configuration
    (add-to-list 'default-frame-alist '(font . "JetBrainsMono NF 12"))              ; Required by emacsclient, if not used fonts will appear smaller
    (set-face-attribute 'default nil
                        :font "JetBrainsMono NF 12"
                        :weight 'regular)
    (set-face-attribute 'variable-pitch nil
                        :font "JetBrainsMono NF 12"
                        :weight 'regular)
    (set-face-attribute 'fixed-pitch nil
                        :font "JetBrainsMono NF 12"
                        :weight 'regular)
    )))

;; Ligatures
(use-package ligature
  :straight t
	     :config

         ;; Prog-mode
	     (ligature-set-ligatures 'prog-mode '("<---" "<--"  "<<-" "<-" "->" "-->" "--->" "<->" "<-->" "<--->" "<---->" "<!--"
                                       "<==" "<===" "<=" "=>" "=>>" "==>" "===>" ">=" "<=>" "<==>" "<===>" "<====>" "<!---"
                                       "<~~" "<~" "~>" "~~>" "::" ":::" "==" "!=" "===" "!=="
                                       ":=" ":-" ":+" "<*" "<*>" "*>" "<|" "<|>" "|>" "+:" "-:" "=:" "<******>" "++" "+++"))

         ;; Org-mode
	     (ligature-set-ligatures 'org-mode '("<---" "<--"  "<<-" "<-" "->" "-->" "--->" "<->" "<-->" "<--->" "<---->" "<!--"
                                       "<==" "<===" "<=" "=>" "=>>" "==>" "===>" ">=" "<=>" "<==>" "<===>" "<====>" "<!---"
                                       "<~~" "<~" "~>" "~~>" "::" ":::" "==" "!=" "===" "!=="
                                       ":=" ":-" ":+" "<*" "<*>" "*>" "<|" "<|>" "|>" "+:" "-:" "=:" "<******>" "++" "+++"))
	     (global-ligature-mode t))

;; ------------------------- Settings - Org Mode -------------------------
(straight-use-package 'org)
(require 'org-mouse)                  ; Enable the mouse
;; Open file links in the same window
(setq org-link-frame-setup '((file . find-file)))  

(setq 

        ; TODO Set condition for Linux, macOS, and Windows
      org-directory "~/notes"
      org-id-track-globally t
      org-return-follows-link t
      org-hide-block-startup nil      ; Don't fold code blocks
      org-hide-emphasis-markers t     ; Hide bold and italics symbols
      org-hide-leading-stars t        ; Hide org header leading stars
      org-startup-with-inline-images t; Open files with inline images opened
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

;; ------------------------- Settings - Org Roam -------------------------
(use-package org-roam
  :straight t
  :custom
  (org-roam-directory (cond
                       ((eq system-type 'gnu/linux) "~/notes")
                       ((eq system-type 'darwin) "~/ben/notes")
                       ((eq system-type 'windows-nt) "C:/Users/Ben/Desktop/ben/notes")
                       (t "~/notes")))
  :config
  (condition-case err
      (progn
        (make-directory org-roam-directory t)
        (org-roam-db-autosync-mode))
    (error (message "Error initializing org-roam: %s" err))))
