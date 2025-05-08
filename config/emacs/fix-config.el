;; Which-key
(use-package which-key
             :straight t
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
             :straight t
             :if (display-graphic-p))
(use-package all-the-icons-dired
             :hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

;; Beacon (cursor blink)
;; https://github.com/Malabarba/beacon
;(use-package beacon
	     ;:config
	     ;(beacon-mode 1))

(use-package doom-modeline)   ; Doom Modeline
(doom-modeline-mode 1)
(display-battery-mode 1)      ; Display battery on modeline
(use-package emojify
             :hook (after-init . global-emojify-mode))

(use-package hide-mode-line)  ; Hide the modeline
(global-hide-mode-line-mode 1)
(add-hook 'neotree-mode-hook #'hide-mode-line-mode)

;; ------------------------- Packages - Org -------------------------
(use-package org-tidy         ; Hides :PROPERTY:
             :straight t
             :hook
             (org-mode . org-tidy-mode))

;; ------------------------- Settings -------------------------
;; Truncate or word wrapping
(add-hook 'org-mode-hook (lambda ()
                           (setq truncate-lines nil)  ; Disable truncation
                           (visual-line-mode 1)))     ; Enable word wrapping

(setq-default fringe-indicator-alist
              '((truncation . right-arrow)    ; Change to right-arrow (default)
                (continuation . right-arrow))) ; Change wrapped lines to left-arrow

;; Word wrapping doesn't work with Vertico
(advice-add #'vertico--resize-window :after #'set-truncate)
(defun set-truncate (&rest _)
  (setq-local truncate-lines nil))

;; Fringes
;(set-fringe-mode 7)
;(set-fringe-mode 0)                       ; No fringes

;; Margins / Padding
(setq-default left-margin-width 3)
(setq-default right-margin-width 3)
(set-window-buffer nil (current-buffer))

;; ------------------------- Org Mode -------------------------
(add-hook 'org-mode-hook 'turn-on-flyspell) ; Flyspell (Spell Checking)

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

;; Apply the org faces
(add-hook 'org-mode-hook 'my-org-faces)

;; Add TODO keywords
(setq org-todo-keywords '((sequence "TODO(t)" "WAIT(w)" "|" "DONE(d)" "CANCELLED(c)")))

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

;; ------------------------- Extra -------------------------

