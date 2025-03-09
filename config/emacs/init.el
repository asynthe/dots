;; Set the user configuration directory
(setq user-emacs-directory (expand-file-name "~/.config/emacs/"))

;; Load the main configuration
(load (expand-file-name "config.el" user-emacs-directory))
