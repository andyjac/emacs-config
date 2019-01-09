;; make emacs start faster
(setq gc-cons-threshold 402653184
      gc-cons-percentage 0.6)

(defvar startup/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(defun startup/revert-file-name-handler-alist ()
  (setq file-name-handler-alist startup/file-name-handler-alist))

(defun startup/reset-gc ()
  (setq gc-cons-threshold 16777216
	gc-cons-percentage 0.1))

(add-hook 'emacs-startup-hook 'startup/revert-file-name-handler-alist)
(add-hook 'emacs-startup-hook 'startup/reset-gc)

;; set up 'package'
(require 'package)
(setq package-enable-at-starup nil)

;; add package repos
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("ELPA"  . "http://tromey.com/elpa/")
			  ("gnu"   . "http://elpa.gnu.org/packages/")
			  ("org"   . "https://orgmode.org/elpa/")))

(unless package--initialized (package-initialize))

;; install 'use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; this is what actually loads the config
(when (file-readable-p "~/.emacs.d/config.org")
  (org-babel-load-file (expand-file-name "~/.emacs.d/config.org")))
