(if (boundp 'comp-deferred-compilation)
    (setq comp-deferred-compilation nil)
    (setq native-comp-deferred-compilation nil))

(setq load-prefer-newer noninteractive)

;; Using garbage magic hack.
;;(use-package gcmh
  ;;:config
  ;;(gcmh-mode 1))
;; Setting garbage collection threshold
;;(setq gc-cons-threshold 402653184
      ;;gc-cons-percentage 0.6)

;; Profile emacs startup
;;(add-hook 'emacs-startup-hook
          ;;(lambda ()
            ;;(message "*** Emacs loaded in %s with %d garbage collections."
                     ;(format "%.2f seconds"
                             ;;(float-time
                             ;;(time-subtract after-init-time before-init-time)))
                     ;;gcs-done)))

;;(setq comp-async-report-warnings-errors nil)

;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 2 1000 1000))

(global-auto-revert-mode t)

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
   (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;;(server-start)

(use-package general
  :config
  (general-evil-setup t))

(use-package evil
  :init
  (setq evil-want-integration t) ;; This is optional, set on by default
  (setq evil-want-keybinding nil)
  (setq evil-want-fine-undo t)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(evil-define-key 'normal org-mode-map (kbd "<tab>") #'org-cycle)

;; Override pdf-tools mode
;;(evil-make-overriding-map pdf-view-mode-map 'normal)

(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

(use-package haskell-mode)
(use-package json-mode)
(use-package lua-mode)
(use-package markdown-mode)
(use-package nix-mode
  :mode "\\.nix\\'")

(setq focus-follows-mouse t)
(setq mouse-autoselect-window t)

(setq inhibit-startup-message t)

(scroll-bar-mode -1)     ; Disable visible scrollbar
(tool-bar-mode -1)       ; Disable the toolbar
(tooltip-mode -1)        ; Disable tooltips
(menu-bar-mode -1)       ; Disable the menu bar

;;(set-fringe-mode 10)   ; Give some breathing room
(set-fringe-mode 0)      ; No fringes, please

;; Set Margins / Padding
(setq-default left-margin-width 5 right-margin-width 5)
(set-window-buffer nil (current-buffer))

;; Set up the visible bell
(setq visible-bell t)
(setq ring-bell-function 'ignore)

;; Copy from X11 apps (something temporary)
(setq x-select-enable-clipboard t)

;; Delete selected text
(delete-selection-mode t)

;; Don't do file backups (file.org~)
(setq make-backup-files nil)
;; (setq backup-directory-alist '((".*" . "~/.config/emacs/backup"))) ; Backups on a specific folder

(global-tab-line-mode -1)
;;(setq tab-line-new-button-show nil) ;; do not show add-new button
;;(setq tab-line-close-button-show nil) ;; do not show close button
;;(setq tab-line-separator "/")
;;(setq tab-line-separator "") ;; set to empty

;; tab color settings

;;(set-face-attribute 'tab-line nil ;; background behind tabs
      ;;:background "gray40"
      ;;:foreground "gray60" :distant-foreground "gray50"
      ;;:height 1.0 :box nil)
;;(set-face-attribute 'tab-line-tab nil ;; active tab in another window
      ;;:inherit 'tab-line
      ;;:foreground "gray70" :background "gray90" :box nil)

;;(set-face-attribute 'tab-line-tab-current nil ;; active tab in current window
      ;;:background "#b34cb3" :foreground "white" :box nil)
;;(set-face-attribute 'tab-line-tab-inactive nil ;; inactive tab
      ;;:background "gray60" :foreground "black" :box nil)
;;(set-face-attribute 'tab-line-highlight nil ;; mouseover
      ;;:background "white" :foreground 'unspecified)

(set-face-attribute 'mode-line-inactive nil
		          :underline t
			  :background (face-background 'default))

;; Line numbers and truncated lines

;;(global-display-line-numbers-mode t)
;; (global-display-line-numbers-mode -1)
(global-visual-line-mode t)

;; See column line in little mode
(column-number-mode)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
		term-mode-hook
		shell-mode-hook
		eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(set-frame-parameter nil 'alpha-background 80) ; For current frame
(add-to-list 'default-frame-alist '(alpha-background .80)) ; For all new frames henceforth

;;(set-frame-parameter nil 'alpha-background 0.7) ; For current frame
;;(add-to-list 'default-frame-alist '(alpha-background .70)) ; For all new frames henceforth

;;(defun toggle-window-transparency ()
  ;;"Toggle transparency."
  ;;(interactive)
  ;;(let ((alpha-transparency 55))
    ;;(pcase (frame-parameter nil 'alpha-background)
      ;;(alpha-transparency (set-frame-parameter nil 'alpha-background 100))
      ;;(t (set-frame-parameter nil 'alpha-background alpha-transparency)))))

(setq scroll-conservatively 101) ;; Value greater than 100 gets rid of half page jumping
(setq scroll-step 1) ;; Keyboard scroll one line at a time

;; Mouse
(setq mouse-wheel-scroll-amount '(3 ((shift) . 3))) ;; How many lines at a time
(setq mouse-wheel-progressive-speed t) ;; Accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; Scroll window under mouse

;; Precision pixel scroll
 
(pixel-scroll-precision-mode 1)
(setq pixel-scroll-precision-use-momentum t) ;; Keep the momentum (notice on touchpad)
(setq pixel-scroll-precision-large-scroll-height 40.0) ;; Scroll with mouse as smooth as touchpad
;; If it doesn't work, decrease by 5 until it works.

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
;;(global-set-key (kbd "C-0") '(lambda () (interactive) (text-scale-adjust 0))) ;; return to default
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

(use-package doom-themes)
(load-theme 'doom-meltbus t)
(setq doom-themes-enable-bold t)        ; if nil, bold is disabled
(setq doom-themes-enable-italic t)      ; if nil, italics is disabled

(set-face-attribute 'default nil
	  :font "JetBrainsMono Nerd Font 12"
	  :weight 'regular)
(set-face-attribute 'variable-pitch nil
	  :font "JetBrainsMono Nerd Font 12"
	  :weight 'regular)

;; org-table and org-block are inherited from this face
(set-face-attribute 'fixed-pitch nil
	  :font "JetBrainsMono Nerd Font 12"
	  :weight 'regular)

;; Org Faces
(defun my-org-faces ()
  (set-face-attribute 'org-todo nil :height 0.8)
  (set-face-attribute 'org-level-1 nil :height 1.0)
  (set-face-attribute 'org-level-2 nil :height 1.0)
  (set-face-attribute 'org-level-3 nil :height 1.0))

(add-hook 'org-mode-hook #'my-org-faces)

;; Needed if using emacs client. Otherwise, your fonts will be smaller than expected.
(add-to-list 'default-frame-alist '(font . "JetBrainsMono Nerd Font 12"))

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

(use-package auctex
  :hook
  (LaTeX-mode . turn-on-prettify-symbols-mode)
  (LaTeX-mode . turn-on-flyspell))

(require 'latex)

(setq TeX-engine-alist '((default
                          "Tectonic"
                          "tectonic -X compile -f plain %T"
                          "tectonic -X watch"
                          nil)))

;; Changing a file name from the buffer
(defun rename-current-buffer-file ()
  "Renames current buffer and the file it is visiting."
  (interactive)
  (let* ((name (buffer-name))
	    (filename (buffer-file-name))
	    (basename (file-name-nondirectory filename)))
    (if (not (and filename (file-exists-p filename)))
	    (error "Buffer '%s' is not visiting a file!" name)
      (let ((new-name (read-file-name "New name: " (file-name-directory filename) basename nil basename)))
	   (if (get-buffer new-name)
	       (error "A buffer name '%s' already exists!" new-name)
	     (rename-file filename new-name 1)
	     (rename-buffer new-name)
	     (set-visited-file-name new-name)
	     (set-buffer-modified-p nil)
	     (message "File '%s' successfully renamed to '%s'"
		      name (file-name-nondirectory new-name)))))))

(defun kill-other-buffers ()
  "Kill all other buffers."
  (interactive)
  (mapc 'kill-buffer
	(delq (current-buffer)
	      (remove-if-not 'buffer-file-name (buffer-list)))))

(defun toggle-maximize-buffer ()
  "Toggle maximize buffer"
  (interactive)
  (if (= 1 (length (window-list)))
      (progn
        (set-window-configuration my-saved-window-configuration)
        (goto-char my-saved-point))
    (setq my-saved-window-configuration (current-window-configuration)
          my-saved-point (point))
    (delete-other-windows)))

(setq erc-prompt (lambda () (concat "[" (buffer-name) "]"))
      erc-server "irc.libera.chat"
      erc-nick "meowtoo"
      erc-user-full-name "Benjamin"
      erc-track-shorten-start 24
      erc-autojoin-channels-alist '(("irc.libera.chat" "#gentoo-chat"))
      erc-kill-buffer-on-part t
      erc-fill-column 100
      erc-fill-function 'erc-fill-static
      erc-fill-static-center 20
      ;; erc-auto-query 'bury
      )

;; Directory and others
(setq org-directory "~/sync/notes"
      org-id-track-globally t
      org-log-done 'time
      org-startup-folded t
      ;;org-startup-latex-with-latex-preview t ;; Org-fragtog enables it.
      org-hide-emphasis-markers t ;; Org styling, hide markup, etc.
      org-hide-leading-stars t ;; Hide org header leading stars.
      org-pretty-entities t
      org-ellipsis " … ")

;; Enable the mouse
(require 'org-mouse)

;; * following links with the left mouse button
;; * subtree expansion/collapse (org-cycle) with the left mouse button
;; * several context menus on the right mouse button:
;;    + general text
;;    + headlines
;;    + timestamps
;;    + priorities
;;    + links
;;    + tags
;; * promoting/demoting/moving subtrees with mouse-3
;;    + if the drag starts and ends in the same line then promote/demote
;;    + otherwise move the subtree

;; To do keywords
(setq org-todo-keywords '((sequence "TODO(t)" "WAIT(w)" "|" "DONE(d)" "CANCELLED(c)" ))
      org-log-done 'time
      ;;org-log-done 'note
      org-fancy-priorities-list '("[A]" "[B]" "[C]")
      org-priority-faces
      '((?A :foreground "#ff6c6b" :weight bold)
        (?B :foreground "#98be65" :weight bold)
        (?C :foreground "#c678dd" :weight bold)))
      ;; just-saving this stuff
      ;;org-enable-priority-commands t
      ;;org-highest-priority ?A
      ;;org-default-priority ?B
      ;;org-lowest-priority ?D)

;; Start in ...
(add-hook 'org-mode-hook 'org-indent-mode)
;; If using Org-capture, start with Insert mode
(add-hook 'org-capture-mode-hook 'evil-insert-state)

;; from DT
(setq org-src-preserve-indentation nil)
;;    org-src-tab-acts-natively t
;;	  org-edit-src-content-indentation 0)

;; Return follows Org links (Special for Org roam)
(setq org-return-follows-link t)

;; RETURN thing 
;;(setq org-M-RET-may-split-line '((item . nil)))
;; Make M-RET not add blank lines when doing a new org heading
(setq org-blank-before-new-entry (quote ((heading . nil)
					     (plain-list-item . nil))))

;; Start with display images
(setq org-startup-with-inline-images t)
(setq org-image-actual-width nil) ;; Set width as nil, enable attrs to edit width

;; Headings Size
;(custom-set-faces
; '(org-level-1 ((t (:inherit outline-1 :height 1.0))))
; '(org-level-2 ((t (:inherit outline-2 :height 0.9))))
; '(org-level-3 ((t (:inherit outline-3 :height 0.8))))
; '(org-level-4 ((t (:inherit outline-4 :height 0.8))))
; '(org-level-5 ((t (:inherit outline-5 :height 0.8))))
; '(org-document-title ((t (:inherit outline-3 :height 0.8)))))

(custom-set-faces
 '(org-level-1 ((t (:inherit outline-1 :height 1.0))))
 '(org-level-2 ((t (:inherit outline-2 :height 1.0))))
 '(org-level-3 ((t (:inherit outline-3 :height 1.0))))
 '(org-level-4 ((t (:inherit outline-4 :height 1.0))))
 '(org-level-5 ((t (:inherit outline-5 :height 1.0))))
 '(org-document-title ((t (:inherit outline-3 :height 0.8)))))

;; Font size
(set-face-attribute 'default nil :height 160)

;; Set all to text size
;;(require 'org-faces
;;  (dolist (face '(org-document-title
;;                 org-level-1
;;                 org-level-2
;;                 org-level-3))
;;(set-face-attribute face nil :height 1.0)))

(setq org-adapt-identation nil)

;;(require 'color)
;;(set-face-attribute 'org-block nil :background
;;                    (color-darken-name
;;                     (face-attribute 'default :background) 3))

;; Language specific
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

             ;;(custom-set-faces
             ;; '(org-block-begin-line
             ;;   ((t (:underline "#A7A6AA" :foreground "#008ED1" :background "#EAEAFF" :extend t))))
             ;; '(org-block
             ;;   ((t (:background "EFF0F1" :extend t))))
             ;; '(org-block-end-line
             ;;   ((t (:overline "#A7A6AA" :foreground "#008ED1" :background"EAEAFF" :extend t))))
             ;; )

(setq org-hide-block-startup nil)

(use-package org-tempo
  :ensure nil) ;; tell use-package not to try to install org-tempo since it's already there.

(setq org-src-fontify-natively t
      org-src-tab-acts-natively t
      org-confirm-babel-evaluate nil
      org-edit-src-content-indentation 0)

(use-package org-roam
  :init
  (setq org-roam-v2-ack t)

  ;;:config
  (org-roam-db-autosync-mode)
  (require 'org-roam-protocol) ;; If using org-roam-protocol

  :custom
  (org-roam-directory "~/sync/notes")
  ;;(org-roam-dailies-directory  "personal/daily") ;; From org-roam-directory
  (org-roam-completion-everywhere t)
  (org-roam-capture-templates
             '(("d" "default" plain
		    "%?"
		    :if-new (file+head "%<%Y%m%d>-${slug}.org" "#+title: ${title}\n")
		    :unnarrowed t)
	       
             ("a" "app" plain
             (file "~/sync/notes/.org/templates/app.org")
             :if-new
             (file+head "not_ready/app/%<%Y%m%d>-${slug}.org" "#+title: ${title}\n")
             :unnarrowed t)

            ("b" "book" plain
             (file "~/sync/notes/.org/templates/booknote.org")
             :if-new
             (file+head "personal/book/%<%Y>-${slug}.org" "#+title: ${title}\n")
             :unnarrowed t)
   
            ("n" "note" plain
             (file "~/sync/notes/.org/templates/note.org")
             :if-new
             (file+head "personal/notes/%<%Y%m%d>-${slug}.org" "#+title: ${title}\n")
             :unnarrowed t))))

;;("p" "project" plain "* Goals\n\n%?\n\n* ;;Tasks\n\n** TODO Add initial tasks\n\n* Dates\n\n"
             ;;:if-new
             ;;(file+head "irl/project/%<%Y%m%d>-${slug}.org" "#+title: ${title}\n#+filetags: Project")
             ;;:unnarrowed t)

            ;;("w" "work" plain "* Goals\n\n%?\n\n* Tasks\n\n** TODO Add initial tasks\n\n* Dates\n\n"
             ;;:if-new
             ;;(file+head "irl/work/%<%Y%m%d>-${slug}.org" "#+title: ;;${title}\n#+filetags: Project")
             ;;:unnarrowed t))))

;; :config
;;(setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
;; If you're using a vertical completion framework, you might want a more informative completion interface 

;; Configuration of the roam buffer as a side-window
(add-to-list 'display-buffer-alist
	           '("\\*org-roam\\*"
		      (display-buffer-in-direction)
		      (direction . right)
		      (window-width . 0.33)
		      (window-height . fit-window-to-buffer)))

;; Navigation in roam buffer
;;(define-key org-roam-mode-map [mouse-1] #'org-roam-visit-thing)
(define-key org-roam-mode-map [mouse-1] #'org-roam-preview-visit)

(use-package org-roam-ui
  :config
  (setq org-roam-ui-sync-theme t
	      org-roam-ui-follow t
	      org-roam-ui-update-on-save t
	      org-roam-ui-open-on-start t))

;;(setq org-roam-graph-viewer nil) ;; use view-file by default
;;(setq org-roam-graph-viewer #'eww-open-file) ;; open the graph in eww.

(use-package org-journal
         :config
        (setq org-journal-dir "~/sync/notes/personal/journal"
              org-journal-file-format "%Y-%m-%d.org"
              org-journal-date-prefix "#+title: "
              org-journal-date-format "%a, %d-%m-%Y"
              org-journal-time-prefix "* "))

(use-package org-pomodoro)

(setq org-format-latex-options (plist-put org-format-latex-options :scale 1.5))

(use-package org-fragtog)
(add-hook 'org-mode-hook 'org-fragtog-mode)

(use-package org-auto-tangle
  :defer t
  :hook (org-mode . org-auto-tangle-mode))

(use-package toc-org
  :commands toc-org-enable
  :init (add-hook 'org-mode-hook 'toc-org-enable))

(use-package org-superstar)
(add-hook 'org-mode-hook (lambda () (org-superstar-mode 1)))

(use-package ox-reveal)

(use-package ox-man
  :ensure nil)

(add-hook 'org-mode-hook 'turn-on-flyspell)

(nvmap :states '(normal) :keymaps 'override :prefix "SPC"

       ;; Perspective Binds (Find-file / Switch-buffer)
       "."   '(counsel-find-file :which-key "Find file")
       ;","   '(persp-counsel-switch-buffer :which-key "Switch buffer")
       ;"/"   '(persp-switch :which-key "Change workspace")

       ;; Exit emacs
       "q q" '(kill-emacs :which-key "Exit emacs without saving")
       "q s" '(save-buffers-kill-emacs :which-key "Exit emacs saving all the buffers")
      
       ;; Helpful
       "h v" '(counsel-describe-variable :which-key "Describe variable")
       "d f" '(describe-font :which-key "Describe font"))

(with-eval-after-load 'evil-maps
  (define-key evil-motion-state-map (kbd "SPC") nil)
  (define-key evil-motion-state-map (kbd "RET") nil))
  ;;(define-key evil-motion-state-map (kbd "TAB") nil))

;; Keybinding for Evil Mode
(evil-define-key 'normal org-mode-map (kbd "<tab>") #'zin/org-cycle-current-headline)

;; Here's the function.
;;(defun zin/org-cycle-current-headline ()
  ;;(interactive)
  ;;(outline-previous-heading)
  ;;(org-cycle))

(defun zin/org-cycle-current-headline ()
  (interactive)
  (org-cycle-internal-local))

;; easy window swap
(global-set-key (kbd "s-n") 'window-swap-states)

;; window switch - vi keys
(global-set-key (kbd "s-h") 'windmove-left)
(global-set-key (kbd "s-j") 'windmove-down)
(global-set-key (kbd "s-k") 'windmove-up)
(global-set-key (kbd "s-l") 'windmove-right)

;; window switch - arrow keys
;; very easy
(windmove-default-keybindings 'super)

;; window resize - vi keys
(global-set-key (kbd "s-C-h") 'shrink-window-horizontally)
(global-set-key (kbd "s-C-j") 'enlarge-window)
(global-set-key (kbd "s-C-k") 'shrink-window)
(global-set-key (kbd "s-C-l") 'enlarge-window-horizontally)

;; window resize - arrow keys
(global-set-key (kbd "s-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "s-<down>") 'enlarge-window)
(global-set-key (kbd "s-<up>") 'shrink-window)
(global-set-key (kbd "s-<right>") 'enlarge-window-horizontally)

;; other
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(global-set-key (kbd "M-[") 'previous-buffer)
(global-set-key (kbd "M-]") 'next-buffer)

(nvmap :prefix "SPC"
      "b b" '(ibuffer :which-key "Ibuffer")
      "b l" '(ibuffer-list-buffers :which-key "Ibuffer list buffers")
      "b n" '(next-buffer :which-key "Next buffer")
      "b p" '(previous-buffer :which-key "Previous buffer")
      "b c" '(clone-indirect-buffer-other-window :which-key "Clone indirect buffer other window")
      "b k" '(kill-current-buffer :which-key "Kill current buffer")
      "b K" '(kill-buffer-and-window :which-key "Kill current buffer and window")
      ;;"b K" '(kill-buffer :which-key "Kill buffer")
      "b m" '(toggle-maximize-buffer :which-key "Maximize buffer") ;; From the Extra function

      ;; With n / p
      "b n" '(next-buffer :which-key "Next buffer")
      "b p" '(previous-buffer :which-key "Previous buffer"))

(nvmap :states '(normal visual) :keymaps 'override :prefix "SPC"
       "f f" '(find-file :which-key "Find file")
       "f r" '(rename-current-buffer-file :which-key "Rename current buffer filename")
       ;;"f r"   '(counsel-recentf :which-key "Recent files")
       ;; put recent files in SPC + /
       "f s" '(save-buffer :which-key "Save file")
       "f u" '(sudo-edit-find-file :which-key "Sudo find file")
       "f y" '(dt/show-and-copy-buffer-path :which-key "Yank file path")
       "f C" '(copy-file :which-key "Copy file")
       "f D" '(delete-file :which-key "Delete file")
       "f R" '(rename-file :which-key "Rename file")
       "f S" '(write-file :which-key "Save file as...")
       "f U" '(sudo-edit :which-key "Sudo edit file"))

(nvmap :states '(normal) :keymaps 'override :prefix "SPC"

  ;;"c c" '(compile :which-key "Compile")
  ;;"c C" '(recompile :which-key "Recompile")
  ;;"c p" '(check-parens :which-key "Check parenthesis")   
  ;;"c b" '(beacon-blink :which-key "Blink cursor"))
  
  ;; Config files
  "l" '((lambda () (interactive (find-file "~/sync/notes/.writing/log.org"))) :which-key "Open log file")
  "c e" '((lambda () (interactive (find-file "~/sync/flake/dots/emacs/config.org"))) :which-key "Emacs configuration")
  "h r r" '((lambda () (interactive) (load-file "~/.config/emacs/init.el")) :which-key "Reload emacs config")

  ;; Configuration files 
  "c f" '((lambda () (interactive (find-file "~/flake/flake.org"))) :which-key "Nix flake configuration")
  "c t" '((lambda () (interactive (find-file "~/.config/tmux/README.org"))) :which-key "tmux configuration")
  "c l" '((lambda () (interactive (find-file "~/.config/lf/README.org"))) :which-key "lf configuration")
  "c v" '((lambda () (interactive (find-file "~/.config/nvim/README.org"))) :which-key "Neovim configuration")

  "c h" '((lambda () (interactive (find-file "~/.config/hypr/README.org"))) :which-key "Hyprland configuration")
  "c x" '((lambda () (interactive (find-file "~/.config/xmonad/README.org"))) :which-key "Xmonad configuration")

  "c b" '((lambda () (interactive (find-file "~/.config/bash/README.org"))) :which-key "Bash configuration")
  "c z" '((lambda () (interactive (find-file "~/.config/zsh/README.org"))) :which-key "Zsh configuration"))

(winner-mode 1)
(nvmap :prefix "SPC"
       ;; Window splits
       "w c" '(evil-window-delete :which-key "Close window")
       "w n" '(evil-window-new :which-key "New window")
       "w s" '(evil-window-split :which-key "Horizontal split window")
       "w v" '(evil-window-vsplit :which-key "Vertical split window")
       ;; Window motions
       "w h" '(evil-window-left :which-key "Window left")
       "w j" '(evil-window-down :which-key "Window down")
       "w k" '(evil-window-up :which-key "Window up")
       "w l" '(evil-window-right :which-key "Window right")
       "w w" '(evil-window-next :which-key "Goto next window")
       ;; winner mode
       "w <left>"  '(winner-undo :which-key "Winner undo")
       "w <right>" '(winner-redo :which-key "Winner redo"))

;(global-set-key (kbd "s-{") 'persp-prev)
;(global-set-key (kbd "s-}") 'persp-next)

;(nvmap :states '(normal) :keymaps 'override :prefix "SPC"
       ;"p k" '(persp-kill :which-key "Kill workspace")
       ;"p r" '(persp-rename :which-key "Rename workspace")
       ;"p a" '(persp-add-buffer :which-key "Move a buffer to current workspace, no switching")
       ;"p m" '(persp-set-buffer :which-key "Move buffer to workspace and remove from all others"))

(nvmap :states '(normal) :keymaps 'override :prefix "SPC"

    ;; Open - Apps
    "o t" '(term :which-key "Open terminal")
    "e h" '(counsel-esh-history :which-key "Eshell history")
    "e s" '(eshell :which-key "Eshell")
    "m w" '(writeroom-mode :which-key "Writeroom mode"))
    "a c" '(org-mouse-insert-checkbox :which-key "Insert checkbox")

    ;; Log Buffer
    "l o" '((lambda () (interactive) (clm/toggle-command-log-buffer) (global-command-log-mode)) :which-key "Start command log mode")
    ;; Start log buffer
    "l s" '(global-command-log-mode :which-key "Turn on command log mode")
    "l b" '(clm/toggle-command-log-buffer :which-key "Open the command log buffer")

(nvmap :states '(normal) :keymaps 'override :prefix "SPC"

       ;; Org agenda
       "o a" '(org-agenda :which-key "Open agenda")
       "o s" '(org-time-stamp :which-key "Insert a time stamp")
       "RET" '(org-toggle-checkbox :which-key "Tick checkbox")
       
       ;; Org dailies
       ;;"n d d" '(org-roam-dailies-goto-date :which-key "Dailies calendar")
       ;;"n d d" '(org-roam-dailies-capture-today :which-key "Capture today") ;; I prefer using the calendar.
       ;;"n d n" '(org-roam-dailies-goto-tomorrow :which-key "Next day")
       ;;"n d p" '(org-roam-dailies-goto-yesterday :which-key "Previous day")

       ;; Org journal
       "n j" '(org-journal-new-entry :which-key "New entry")

       "j n" '(org-journal-next-entry :which-key "Next entry")
       "j p" '(org-journal-previous-entry :which-key "Previous entry")

       ;; S - start
       "s p" '(org-pomodoro :which-key "Start/end pomodoro timer")

       ;; I - Insert
       "i l" '(org-insert-link :which-key "Insert link")
       "i s" '(org-schedule :which-key "Insert SCHEDULE:")
       "i p" '(org-set-property :which-key "Insert PROPERTY:")

       ;; R - Roam
       "r a" '(org-roam-alias-add :which-key "Add alias to node")
       "r b" '(org-roam-buffer-toggle :which-key "Open roam buffer")
       "r i" '(org-id-get-create :which-key "Create org id")
       "r t" '(org-roam-tag-add :which-key "Add a tag to node")
       ;; R g - Roam Graph
       "r g" '(org-roam-ui-open :which-key "Open org-roam graph")
       ;;"r g" '(org-roam-graph :which-key "Open org-roam graph") [NOT WORKING]

       ;; D - Display
       "d L" '(org-toggle-link-display :which-key "Display links as plain text")
       "d i" '(org-toggle-inline-images :which-key "Org toggle inline imager")
       "d m" '(hide-mode-line-mode :which-key "Display/Hide modeline")
       "d a" '(global-hide-mode-line-mode :which-key "Display/Hide all modelines")
       ;;"d a" '(global-org-modern-mode :which-key "Activate org modern")

       ;; Notes - Org capture
       "n n" '(org-roam-capture :which-key "New note")
       "n f" '(org-roam-node-find :which-key "Find note")
       "n d s" '(org-roam-db-sync :which-key "Database sync")
       "n i" '(org-roam-node-insert :which-key "Insert org-roam node link")

       ;; Toggle - Narrow
       "t e" '(widen :which-key "Widen / Escape narrowed area.")
       "t t" '(org-narrow-to-subtree :which-key "Narrow to subtree.")
       "t b" '(org-narrow-to-block :which-key "Narrow to source block / block of text.")
       "t l" '(org-narrow-to-element :which-key "Narrow to line."))

(nvmap :states '(normal) :keymaps 'override :prefix "SPC"
       "p i" '(pdf-view-midnight-minor-mode :which-key "Invert PDF colors"))

;;(nvmap :states '(normal) :keymaps 'override :prefix "SPC"
       ;; T - toggle
       ;;"t c" '(centered-cursor-mode :which-key "Toggle centered cursor mode")
       ;;"t C" '(global-centered-cursor-mode :which-key "Toggle centered cursor mode on all buffers"))
       ;;"t s" '(scroll-lock-mode :which-key "Scroll lock mode") ;; Disabled for centered-cursor-mode
       ;;"t t" '(toggle-window-transparency :which-key "Toggle transparency")

;(use-package perspective
;  :bind
;  ("C-x C-b" . persp-list-buffers)
;  :custom
;  (persp-mode-prefix-key (kbd "C-c M-p"))
;  (persp-state-default-file "~/.config/emacs/persp-save")
;  :init
;  (persp-mode))

;(add-hook 'kill-emacs-hook #'persp-state-save)

(use-package counsel
      :bind (( "M-x" . counsel-M-x)
	( "C-x b" . counsel-ibuffer)
	( "C-x C-f" . counsel-find-file)
      :map minibuffer-local-map
	( "C-r" . 'counsel-minibuffer-history)))
  ;;    :config
(setq ivy-initial-inputs-alist nil) ;; Don't start searches with ^

(ivy-mode)
(setq ivy-use-virtual-buffers t)
(setq enable-recursive-minibuffers t)

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
       :map ivy-minibuffer-map
       ("TAB" . ivy-alt-done)	
       ("C-l" . ivy-alt-done)
       ("C-j" . ivy-next-line)
       ("C-k" . ivy-previous-line)
       :map ivy-switch-buffer-map
       ("C-k" . ivy-previous-line)
       ("C-l" . ivy-done)
       ("C-d" . ivy-switch-buffer-kill) 
       :map ivy-reverse-i-search-map
       ("C-k" . ivy-previous-line)
       ("C-d" . ivy-reverse-i-search-kill)))
;;TEST (NOT WORKIGN YET)
;;(global-set-key (kbd "SPC .") 'counsel-find-file)
;;(global-set-key (kbd "SPC ,") 'counsel-switch-buffer)

;; enable this if you want `swiper' to use it
;; (setq search-default-mode #'char-fold-to-regexp)
;;(global-set-key "\C-s" 'swiper)
;;(global-set-key (kbd "C-c C-r") 'ivy-resume)
;;(global-set-key (kbd "<f6>") 'ivy-resume)
;;(global-set-key (kbd "M-x") 'counsel-M-x)
;;(global-set-key (kbd "C-x C-f") 'counsel-find-file)
;;(global-set-key (kbd "<f1> f") 'counsel-describe-function)
;;(global-set-key (kbd "<f1> v") 'counsel-describe-variable)
;;(global-set-key (kbd "<f1> o") 'counsel-describe-symbol)
;;(global-set-key (kbd "<f1> l") 'counsel-find-library)
;;(global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
;;(global-set-key (kbd "<f2> u") 'counsel-unicode-char)
;;(global-set-key (kbd "C-c g") 'counsel-git)
;;(global-set-key (kbd "C-c j") 'counsel-git-grep)
;;(global-set-key (kbd "C-c k") 'counsel-ag)
;;(global-set-key (kbd "C-x l") 'counsel-locate)
;;(global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
;;(define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history)

(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

(use-package all-the-icons-dired)
(use-package dired-open)
(use-package peep-dired)

(nvmap :states '(normal visual) :keymaps 'override :prefix "SPC"
               "d d" '(dired :which-key "Open dired")
               "d j" '(dired-jump :which-key "Dired jump to current")
               "d p" '(peep-dired :which-key "Peep-dired"))

(with-eval-after-load 'dired
  ;;(define-key dired-mde-map (kbd "M-p") 'peep-dired)
  (evil-define-key 'normal dired-mode-map (kbd "h") 'dired-up-directory)
  (evil-define-key 'normal dired-mode-map (kbd "l") 'dired-open-file) ; use dired-find-file instead if not using dired-open package
  (evil-define-key 'normal peep-dired-mode-map (kbd "j") 'peep-dired-next-file)
  (evil-define-key 'normal peep-dired-mode-map (kbd "k") 'peep-dired-prev-file))

(add-hook 'peep-dired-hook 'evil-normalize-keymaps)
;; Get file icons in dired
(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)
;; Auto-refresh dired on file change
(add-hook 'dired-mode-hook 'auto-revert-mode)
;; With dired-open plugin, you can launch external programs for certain extensions
;; For example, I set all .png files to open in 'sxiv' and all .mp4 files to open in 'mpv'
(setq dired-open-extensions '(("gif" . "nsxiv")
                               ("jpg" . "nsxiv")
                              ("png" . "nsxiv")
                              ("mkv" . "mpv")
                              ("mp4" . "mpv")))

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
        which-key-separator " → " ))

(use-package valign)
;;(add-hook 'org-mode-hook #'valign-mode)

(use-package projectile
  :config
  (projectile-global-mode 1))

(unless (package-installed-p 'super-save)
  (package-refresh-contents)
  (package-install 'super-save))

(super-save-mode +1)
(setq super-save-auto-save-when-idle t)
(setq auto-save-default nil)

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package command-log-mode)

(use-package all-the-icons)

(use-package beacon
  :config
  (beacon-mode 1))

(use-package doom-modeline)
(doom-modeline-mode 1)
;; + BATTERY
(display-battery-mode 1)

;; hide the modeline with hide-mode-line-mode
(use-package hide-mode-line)
(global-hide-mode-line-mode 1)
;; some hooks for stuff in which we don't want use modeline in
;;(add-hook 'completion-list-mode-hook #'hide-mode-line-mode)
(add-hook 'neotree-mode-hook #'hide-mode-line-mode)

(use-package emojify
:hook (after-init . global-emojify-mode))

(use-package centered-cursor-mode)
(rassq-delete-all 'centered-cursor-mode auto-mode-alist) ;; Disables mode on all buffers unless started manually.

;; Keep the cursor centered to avoid sudden scroll jumps
;;(require 'centered-cursor-mode)

(use-package neotree)
(global-set-key [f8] 'neotree-toggle)

(setq neo-theme (if (display-graphic-p) 'icons 'arrow)) ;; Display all-the-icons icons and fonts
(setq neo-smart-open t) ;; Find current file and jump to node
;; TEST
;; (setq projectile-switch-project-action 'neotree-projectile-action)

;;(use-package calfw-cal)
;;(use-package calfw-org)

;;(defun my-open-calendar ()
  ;;(interactive)
  ;;(cfw:open-calendar-buffer
   ;;:contents-sources
   ;;(list
    ;;(cfw:org-create-file-source "Org" "~/sync/notes/org/irl/events.org" "Orange") ; org mode
    ;;(cfw:org-create-file-source "Agenda" "~/sync/notes/org"
    ;;(cfw:org-create-file-source "Events" "~/sync/notes/org"
    ;;)))

(use-package writeroom-mode)

(use-package pass)

(use-package simple-httpd)

(setq browse-url-browser-function 'browse-url-generic
          browse-url-generic-program "librewolf")

(find-file "~/sync/notes/main.org")

(set-face-attribute 'mode-line-inactive nil
		        ;;:underline t
			;;:background (face-background 'default)
		        :background "black"
			:foreground "black")

;;hide-mode-line-mode -1

(defun my/return-t (orig-fun &rest args)
    t)
(defun my/disable-yornp (orig-fun &rest args)
  (advice-add 'yes-or-no-p :around #'my/return-t)
  (advice-add 'y-or-n-p :around #'my/return-t)
  (let ((res (apply orig-fun args)))
    (advice-remove 'yes-or-no-p #'my/return-t)
    (advice-remove 'y-or-n-p #'my/return-t)
    res))
(advice-add 'org-roam-capture--finalize :around #'my/disable-yornp)

(setq find-file-visit-truename t)
;(setq vc-follow-symlinks t) ; What does this do?

;; Make all backups be in the same directory.
;;(setq backup-directory-alist '(("." . "~/.saves")))

;; Specify a backup by copying (safest but slowest.)
;;(setq backup-by-copying t)
;;(setq backup-by-copying-when-linked t)

;; More backups of versions
;;(setq delete-old-versions t
      ;;kept-new-versions 6
      ;;kept-old-versions 2
      ;;version-control t)

;; Enable this if you don't want backup files
;;(setq make-backup-files nil)

;;(use-package eaf
  ;;:load-path ;;"~/.emacs.d/site-lisp/emacs-application-framework"
  ;;:custom
  ;; See https://github.com/emacs-eaf/emacs-application-framework/wiki/Customization
  ;;(eaf-browser-continue-where-left-off t)
  ;;(eaf-browser-enable-adblocker t)
  ;;(browse-url-browser-function 'eaf-open-browser)
  ;;:config
  ;;(defalias 'browse-web #'eaf-open-browser))
  ;;(eaf-bind-key scroll_up "C-n" eaf-pdf-viewer-keybinding)
  ;;(eaf-bind-key scroll_down "C-p" eaf-pdf-viewer-keybinding)
  ;;(eaf-bind-key take_photo "p" eaf-camera-keybinding)
;;(eaf-bind-key nil "M-q" eaf-browser-keybinding)) ;; unbind, see more in the Wiki

;;(require 'eaf-browser)
;;(require 'eaf-pdf-viewer)

;;(good-scroll-mode 1)
;;(global-set-key [next] #'good-scroll-up)
;;(global-set-key [prior] #'good-scroll-down)

(use-package org-gtd
  :after org
  :init
  (setq org-gtd-update-ack "3.0.0"))

(setq org-edna-use-inheritance t)
(org-edna-mode t)

(setq org-gtd-organize-hooks nil) ;; Decorate each item, i put it to skip adding tags to tasks.

(setq org-agenda-files '("~/sync/notes/1_personal/gtd/next.org"
                             "~/sync/notes/1_personal/gtd/projects.org"))

;(use-package ellama)
  ;:init
  ;(setopt ellama-language "German")
  ;(require 'llm-ollama)
  ;(setopt ellama-provider
		  ;(make-llm-ollama
		   ;:chat-model "zephyr:7b-beta-q6_K" :embedding-model "zephyr:7b-beta-q6_K"))
  ;; Predefined llm providers for interactive switching.
  ;; You shouldn't add ollama providers here - it can be selected interactively
  ;; without it. It is just example.
  ;(setopt ellama-providers
		  ;'(("zephyr" . (make-llm-ollama
						 ;:chat-model "zephyr:7b-beta-q6_K"
						 ;:embedding-model "zephyr:7b-beta-q6_K"))
			;("mistral" . (make-llm-ollama
						  ;:chat-model "mistral:7b-instruct-v0.2-q6_K"
						  ;:embedding-model "mistral:7b-instruct-v0.2-q6_K"))
			;("mixtral" . (make-llm-ollama
						  ;:chat-model "mixtral:8x7b-instruct-v0.1-q3_K_M-4k"
						  ;:embedding-model "mixtral:8x7b-instruct-v0.1-q3_K_M-4k")))))

(use-package websocket)
