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

;; ------------------------- Settings -------------------------
;;(setq inhibit-startup-message t)

;; Main
(global-display-line-numbers-mode t) ;; Line numbers
(setq-default indent-tabs-mode nil) ;; Use spaces instead of tabs
(setq-default tab-width 4) ;; 4 spaces
(show-paren-mode 1) ;; Enable parentheses matching

;; Basic UI settings
(menu-bar-mode -1)  ;; Disable menu bar
(scroll-bar-mode -1) ;; Disable scroll bar
(setq inhibit-startup-message t) ;; No startup message
(tool-bar-mode -1)  ;; Disable tool bar

;; Margins / Padding
;; (setq-default left-margin width 5 right-margin-width 5)
;; (set-window-buffer nil (current-buffer)) ;; ?

;; Transparency
(set-frame-parameter nil 'alpha-background 80) ; For current frame
(add-to-list 'default-frame-alist '(alpha-background .80)) ; For new frames

;; Auto-save
(setq auto-save-default t)
(setq auto-save-timeout 20)
(setq auto-save-interval 200)

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
;; ------------------------- Font -------------------------
;; Font -> JetBrainsMono
;;(set-face-attribute 'default nil
;;		    :font "JetBrainsMono Nerd Font 12"
;;		    :weight 'regular)
;;
;;(set-face-attribute 'variable-pitch nil
;;		    :font "JetBrainsMono Nerd Font 12"
;;		    :weight 'regular)
;;
;; Inherited face by org-table and org-block
;;(set-face-attribute 'fixed-pitch nil
;;		    :font "JetBrainsMono Nerd Font 12"
;;		    :weight 'regular)

;; Required by emacsclient, if not used fonts will appear smaller
;;(add-to-list 'default-frame-alist '(font . "JetBrainsMono Nerd Font 12"))

;; Size
;; ...

;; Ligatures
;; ...

;; ------------------------- Keybinds -------------------------
(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)

;; ------------------------- Packages -------------------------
;; ------------------------- Extra -------------------------

;; EOF
(provide 'config)
