;; default
(("emacs" . ((user-emacs-directory . "~/.emacs.default")
               (server-name . "emacs")
               ))

;; doom emacs
  ("doom" . ((user-emacs-directory . "~/.doom-emacs")
             (server-name . "doom")
           (env . (("DOOMDIR" . "~/sync/system/config/emacs/doom-config"))))))
