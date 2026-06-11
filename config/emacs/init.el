(cond
 ((or (eq system-type 'gnu/linux) (eq system-type 'darwin)) 
  (progn

    ;; Linux and macOS configuration
    (setq user-emacs-directory (expand-file-name "~/.config/emacs/"))               ; Set the user configuration directory
    (load (expand-file-name "config.el" user-emacs-directory))))                    ; Load the main configuration
 ((eq system-type 'windows-nt)
  (progn

    ;; Windows configuration
    (load (expand-file-name "config.el" user-emacs-directory))))
)
