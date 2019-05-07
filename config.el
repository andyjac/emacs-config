(setq user-full-name "Andrew Jacobson"
      user-mail-address "andrew.isaac.jacobson@gmail.com")

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)

(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

(blink-cursor-mode -1)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq-default indicate-empty-lines t)

(show-paren-mode 1)

(line-number-mode 1)
(column-number-mode 1)

(global-linum-mode)

(when window-system
  (add-hook 'prog-mode-hook 'hl-line-mode))

(when window-system
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (tooltip-mode -1))

(setq inhibit-startup-message t)

(defun aj/force-save ()
  (interactive)
  (not-modified 1)
  (save-buffer))

(bind-key "C-x C-s" 'aj/force-save)

(setq require-final-newline t)
(setq require-trailing-newline t)

(defalias 'yes-or-no-p 'y-or-n-p)

(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-save-list/" t)))

(delete-selection-mode 1)

(setq visible-bell nil)
(setq ring-bell-function 'ignore)

(add-hook 'before-save-hook 'delete-trailing-whitespace)

(defun aj/find-config ()
  "Edit `config.org' file"
  (interactive)
  (find-file
   (concat user-emacs-directory "config.org")))

(bind-key "C-c e" 'aj/find-config)

(let ((default-directory  "~/.emacs.d/lib/"))
  (normal-top-level-add-subdirs-to-load-path))

(global-visual-line-mode 1)

(bind-key [remap kill-line] 'kill-whole-line)

(use-package gruvbox-theme
  :ensure t)

(load-theme 'gruvbox-dark-hard)

(add-to-list 'default-frame-alist '(font . "Source Code Pro-14"))
;; (add-to-list 'default-frame-alist '(font . "Hack-14"))

(when (string-equal system-type 'darwin)
  (setq mac-option-modifier 'alt)
  (setq mac-command-modifier 'meta)
  (setq mac-pass-command-to-system nil)
  (setq dired-use-ls-dired nil)
  (setq ns-use-native-fullscreen nil))

(use-package exec-path-from-shell
  :ensure t
  :config
  (setq exec-path-from-shell-check-startup-files nil)
  (when (string-equal system-type 'darwin)
    (exec-path-from-shell-initialize)))

(use-package spaceline
  :ensure t
  :config
  (require 'spaceline-config)
  (setq spaceline-buffer-encoding-abbrev-p nil)
  (setq powerline-default-separator nil)
  (spaceline-emacs-theme))

(use-package fancy-battery
  :ensure t
  :config
  (setq fancy-battery-show-percentage t)
  (setq battery-update-interval 15)
  (if window-system
      (fancy-battery-mode 1)
    (display-battery-mode 1)))

(setq display-time-24hr-format 1)
(setq display-time-format "%H:%M - %d %B %Y")

(display-time-mode 1)

(bind-key "M-F" 'forward-to-word)
(bind-key "M-B" 'backward-to-word)

(defun kill-focused-buffer ()
    (interactive)
    (kill-buffer (current-buffer)))

(bind-key "C-x C-k" 'kill-focused-buffer)

(defun toggle-window-split ()
  (interactive)
  (if (= (count-windows) 2)
      (let* ((this-win-buffer (window-buffer))
             (next-win-buffer (window-buffer (next-window)))
             (this-win-edges (window-edges (selected-window)))
             (next-win-edges (window-edges (next-window)))
             (this-win-2nd (not (and (<= (car this-win-edges)
                                         (car next-win-edges))
                                     (<= (cadr this-win-edges)
                                         (cadr next-win-edges)))))
             (splitter
              (if (= (car this-win-edges)
                     (car (window-edges (next-window))))
                  'split-window-horizontally
                'split-window-vertically)))
        (delete-other-windows)
        (let ((first-win (selected-window)))
          (funcall splitter)
          (if this-win-2nd (other-window 1))
          (set-window-buffer (selected-window) this-win-buffer)
          (set-window-buffer (next-window) next-win-buffer)
          (select-window first-win)
          (if this-win-2nd (other-window 1))))))

(bind-key "C-M-]" 'toggle-window-split)

(defun rotate-windows-in-frame ()
    (interactive)
    (let ((map
           (mapcar
            (lambda (window)
              `(,window
                ,(window-buffer
                  (next-window window))))
            (window-list))))
      (mapcar
       (lambda (window-to-buffer)
         (let ((window (car window-to-buffer))
               (buffer (cadr window-to-buffer)))
           (select-window window)
           (switch-to-buffer buffer))) map)))

(bind-key "C-|" 'rotate-windows-in-frame)

(use-package ace-window
  :ensure t
  :config
  ;; (set-face-attribute
  ;;  'aw-background-face nil :foreground "gray40")
  ;; (set-face-attribute
  ;;  'aw-leading-char-face nil :height 200)
  ;; i prefer keys on the home row to the default 0-9
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  :bind ("M-o" . ace-window))

(use-package zoom
  :ensure t
  :config
  (setq zoom-size '(0.618 . 0.618))
  (setq temp-buffer-resize-mode t)
  (zoom-mode 1))

(use-package eyebrowse
  :ensure t
  :config
  (eyebrowse-mode 1))

(use-package dired
  :bind
  (("C-x C-d" . 'dired-jump)
   :map dired-mode-map
        ("<backspace>" . 'dired-up-directory)))

(use-package dired-efap
  :ensure t
  :config
  (setq dired-efap-initial-filename-selection nil)
  :bind (:map dired-mode-map ("e" . 'dired-efap)))

(use-package fasd
  :ensure
  :bind ("C-c f" . fasd-find-file))

(use-package which-key
  :ensure t
  :config (which-key-mode 1))

(use-package swiper
  :ensure t
  ;; :bind (("C-s" . swiper)
  ;;        ("C-r" . swiper)
  ;;        :map swiper-map
  ;;        ("C-*" . 'swiper-mc)
  ;;        ("C-r" . 'swiper-query-replace))
  :config (setq ivy-height 15))

(use-package hydra
  :ensure t)

(defhydra hydra-ag (:color blue :hint nil)
  "
  _a_: ag              _p_: ag-project-root
  _A_: do-ag           _P_: do-ag-project-root
  _f_: ag-this-file    _b_: ag-buffers
  _F_: do-ag-this-file _B_: do-ag-buffers
"
  ("a" helm-ag)
  ("A" helm-do-ag)
  ("f" helm-ag-this-file)
  ("F" helm-do-ag-this-file)
  ("p" helm-ag-project-root)
  ("P" helm-do-ag-project-root)
  ("b" helm-ag-buffers)
  ("B" helm-do-ag-buffers))

(bind-key "C-c a" 'hydra-ag/body)

(defhydra hydra-avy (:color blue :hint nil)
  "
  _C_: char
  _L_: line
  _S_: symbol
  _W_: word

  _q_: quit
"
  ("C" hydra-avy-char/body)
  ("L" hydra-avy-line/body)
  ("S" hydra-avy-symbol/body)
  ("W" hydra-avy-word/body)
  ("q" nil))

(defhydra hydra-avy-char (:color pink :hint nil)
  "
  _c_: goto-char         _l_: goto-char-in-line
  _2_: goto-char-2       _f_: goto-char-timer
  _p_: goto-char-2-above
  _n_: goto-char-2-below

  _q_: quit
"
  ("c" avy-goto-char)
  ("2" avy-goto-char-2)
  ("p" avy-goto-char-2-above)
  ("n" avy-goto-char-2-below)
  ("l" avy-goto-char-in-line)
  ("f" avy-goto-char-timer)
  ("q" nil))

(defhydra hydra-avy-line (:color pink :hint nil)
  "
  _w_: copy-line           _l_: goto-line
  _k_: kill-ring-save-line _p_: goto-line-above
  _K_: kill-line           _n_: goto-line-below
  _m_: move-line           _e_: goto-end-of-line

  _q_: quit
"
  ("w" avy-copy-line)
  ("k" avy-kill-whole-line)
  ("K" avy-kill-ring-save-whole-line)
  ("m" avy-move-line)
  ("l" avy-goto-line)
  ("p" avy-goto-line-above)
  ("n" avy-goto-line-below)
  ("e" avy-goto-end-of-line)
  ("q" nil))

(defhydra hydra-avy-symbol (:color pink :hint nil)
  "
  _1_: goto-symbol-1
  _p_: goto-symbol-1-above
  _n_: goto-symbol-1-below
"
  ("1" avy-goto-symbol-1)
  ("n" avy-goto-symbol-1-above)
  ("p" avy-goto-symbol-1-below)
  ("q" nil "quit"))

(defhydra hydra-avy-word (:color pink :hint nil)
  "
  _0_: goto-word-0       _P_: goto-word-1-above      _S_: goto-subword-1
  _p_: goto-word-0-above _N_: goto-word-1-below
  _n_: goto-word-0-below _f_: goto-word-or-subword-1
  _1_: goto-word-1       _s_: goto-subword-0

  _q_: quit
"
  ("0" avy-goto-word-0)
  ("p" avy-goto-word-0-above)
  ("n" avy-goto-word-0-below)
  ("1" avy-goto-word-1)
  ("P" avy-goto-word-1-above)
  ("N" avy-goto-word-1-below)
  ("f" avy-goto-word-or-subword-1)
  ("s" avy-goto-subword-0)
  ("S" avy-goto-subword-1)
  ("q" nil))

(bind-key "C-c v" 'hydra-avy/body)

(defhydra hydra-anzu (:color pink :hint nil)
  "
_m_ anzu-mode: %`anzu-mode

_f_: replace-at-cursor-thing _c_: query-replace-at-cursor
_i_: isearch-query-replace   _t_: query-replace-at-cursor-thing
_r_: query-replace
_R_: query-replace-regexp

_q_: quit
"
  ("m" anzu-mode)
  ("f" anzu-replace-at-cursor-thing)
  ("i" anzu-isearch-query-replace)
  ("r" anzu-query-replace)
  ("R" anzu-query-replace-regexp)
  ("c" anzu-query-replace-at-cursor)
  ("t" anzu-query-replace-at-cursor-thing)
  ("q" nil))

(defhydra hydra-help (:color blue :hint nil)
  "
_m_: man           _c_: command     _f_: function
_a_: apropos       _l_: library     _i_: info
_d_: documentation _u_: user-option
_v_: variable      _e_: value

_q_: quit
"
  ("m" man)
  ("a" apropos)
  ("d" apropos-documentation)
  ("v" apropos-variable)
  ("c" apropos-command)
  ("l" apropos-library)
  ("u" apropos-user-option)
  ("e" apropos-value)
  ("f" describe-function)
  ("i" helm-info)
  ("q" nil))

(bind-key "C-c h" 'hydra-help/body)

(defhydra hydra-git (:color blue :hint nil)
  "
_i_: init        _z_: stash
_s_: status      _b_: blame
_l_: log current _t_: git-timemachine
_L_: log other

_q_: quit
"
  ("i" magit-init)
  ("s" magit-status)
  ("l" magit-log-current)
  ("L" magit-log)
  ("z" magit-stash)
  ("b" magit-blame)
  ("t" git-timemachine)
  ("q" nil))

(bind-key "C-c g" 'hydra-git/body)

(defun smart-find-file (arg)
  (interactive "P")
  (if (equal (projectile-project-type) nil)
      (helm-find-files arg)
    (projectile-find-file)))

(defhydra hydra-window (:color red :hint nil)
  "
_o_: ace-window          _0_: delete-window        _h_: windmove-left  _t_: toggle-frame-fullscreen _F_: find-file
_d_: ace-delete-window   _1_: delete-other-windows _l_: windmove-right _b_: ido-switch-buffer
_i_: ace-maximize-window _2_: split-window-below   _j_: windmove-down  _p_: helm-projectile
_s_: ace-swap-window     _3_: split-window-right   _k_: windmove-up    _f_: smart-find-file

_q_: quit
"
  ("o" ace-window)
  ("d" ace-delete-window)
  ("s" ace-swap-window)
  ("i" ace-maximize-window :color blue)
  ("0" delete-window)
  ("1" delete-other-windows :color blue)
  ("2" (lambda ()
         (interactive)
         (split-window-below)
         (windmove-down)))
  ("3" (lambda ()
         (interactive)
         (split-window-right)
         (windmove-right)))
  ("h" windmove-left)
  ("l" windmove-right)
  ("j" windmove-down)
  ("k" windmove-up)
  ("t" toggle-frame-fullscreen)
  ("b" ido-switch-buffer)
  ("p" helm-projectile)
  ("f" smart-find-file)
  ("F" helm-find-files)
  ("q" nil))

(bind-key "C-c w" 'hydra-window/body)

(defhydra hydra-move-dup (:color pink)
  "Move/Dup"
  ("k" md/move-lines-up "move-up")
  ("j" md/move-lines-down "move-down")
  ("p" md/duplicate-up "dup-up")
  ("n" md/duplicate-down "dup-down")
  ("q" nil "quit"))

(bind-key "C-c l" 'hydra-move-dup/body)

(defun hydra-set-mark ()
  (interactive)
  (if (region-active-p)
      (progn
        (deactivate-mark)
        (hydra-keyboard-quit))
    (call-interactively 'set-mark-command)
    (hydra-region/body)))

(defun unset-mark ()
  (interactive)
  (if (region-active-p)
      (progn
        (deactivate-mark))))

(defhydra hydra-region (:color pink :hint nil)
  "
_f_: forward-word  _n_: next-line          _=_: expand-region     _<_: beginning-of-buffer _;_: comment-line
_b_: backward-word _p_: previous-line      _-_: contract-region   _>_: end-of-buffer
_F_: forward-sexp  _N_: forward-paragraph  _e_: end-of-line       _w_: copy
_B_: backward-sexp _P_: backward-paragraph _a_: beginning-of-line _k_: kill

_M_: multiple-cursors _L_: move-dup _S_: replace-string _R_: replace-regexp

_q_: quit
"
  ("f" forward-word)
  ("b" backward-word)
  ("F" forward-sexp)
  ("B" backward-sexp)
  ("n" next-line)
  ("p" previous-line)
  ("N" forward-paragraph)
  ("P" backward-paragraph)
  ("e" end-of-line)
  ("a" beginning-of-line)
  ("=" er/expand-region)
  ("-" er/contract-region)
  ("w" copy-region-as-kill :color blue)
  ("k" kill-region :color blue)
  ("<" beginning-of-buffer)
  (">" end-of-buffer)
  ("M" hydra-multiple-cursors/body :color blue)
  ("L" hydra-move-dup/body :color blue)
  ("S" replace-string :color blue)
  ("R" replace-regexp :color blue)
  (";" comment-line)
  ("q" nil))

(bind-key "C-SPC" 'hydra-set-mark)

(defhydra hydra-toggle (:color pink :hint nil)
  "
  _a_ abbrev-mode:       %`abbrev-mode
  _d_ debug-on-error:    %`debug-on-error
  _f_ auto-fill-mode:    %`auto-fill-function
  _h_ highlight          %`highlight-nonselected-windows
  _t_ truncate-lines:    %`truncate-lines
  _w_ whitespace-mode:   %`whitespace-mode
  _l_ org link display:  %`org-descriptive-links
  _r_ rainbow-mode:      %`rainbow-mode

  _q_: quit
  "
  ("a" abbrev-mode)
  ("d" toggle-debug-on-error)
  ("f" auto-fill-mode)
  ("h" (setq highlight-nonselected-windows (not highlight-nonselected-windows)))
  ("t" toggle-truncate-lines)
  ("w" whitespace-mode)
  ("l" org-toggle-link-display)
  ("r" rainbow-mode)
  ("q" nil))

;; toggle `whitespace-mode' to inhibit first run error
(whitespace-mode)
(whitespace-mode)
;; toggle `rainbow-mode' to inhibit first run error
;; (rainbow-mode)
;; (rainbow-mode)
(bind-key "C-c t" 'hydra-toggle/body)

(defhydra hydra-search-and-replace (:color blue :hint nil)
  "
  _a_: anzu           _r_: vr/replace
  _d_: deadgrep       _R_: vr/query-replace
  _i_: symbol-overlay
  _e_: iedit

  _s_: swoop-all
  _p_: swoop-projectile
  _m_: swoop-mode
  _b_: swoop-buffers

  _q_: quit
  "
  ("a" hydra-anzu/body)
  ("d" deadgrep)
  ("i" symbol-overlay-put)
  ("e" iedit-mode)
  ("r" vr/replace)
  ("R" vr/query-replace)
  ("s" helm-multi-swoop-all)
  ("p" helm-multi-swoop-projectile)
  ("m" helm-multi-swoop-current-mode)
  ("b" helm-multi-swoop)
  ("q" nil))

(bind-key "C-c s" 'hydra-search-and-replace/body)

(defhydra hydra-multiple-cursors (:color pink)
  "Multiple Cursors"
  ("a" mc/mark-all-like-this-dwim "mark-all")
  ("n" mc/mark-next-like-this "mark-next")
  ("p" mc/unmark-next-like-this "unmark-next")
  ("q" nil "quit"))

;; (bind-key "C-c m" 'hydra-multiple-cursors/body)

(defun previous-indent-and-open-newline ()
    "Call `indent-and-open-newline' with non-nil PREVIOUS value"
    (interactive)
    (indent-and-open-newline t))

(bind-key "C-o" 'previous-indent-and-open-newline)

(defun indent-buffer ()
  "Fix indentation on the entire buffer."
  (interactive)
  (save-excursion
    (indent-region (point-min) (point-max))))

(bind-key "C-c i" 'indent-buffer)

(defun indent-and-open-newline (&optional previous)
    "Add a newline after current line and tab to indentation.
    If PREVIOUS is non-nil, go up a line first."
    (interactive)
    (if previous
        (previous-line))
    (end-of-line)
    (newline)
    (indent-for-tab-command))

(bind-key "C-M-o" 'indent-and-open-newline)

(use-package anzu
  :ensure t
  :config
  (global-anzu-mode))

(use-package avy
  :ensure t
  :bind
  ("C-:" . 'avy-goto-char)
  ("C-'" . 'avy-goto-char-2)
  ("M-g f" . 'avy-goto-line)
  ("M-g w" . 'avy-goto-word-1)
  ("M-g e" . 'avy-goto-word-0))

(use-package expand-region
  :ensure
  :bind ("C-=" . 'er/expand-region))

(use-package multiple-cursors
  :ensure t
  :bind
  ("C-c C-m" . 'mc/mark-all-dwim)
  ("C-+" . 'mc/mark-next-like-this)
  ("C-_" . 'mc/unmark-next-like-this))

(use-package move-dup
  :ensure t
  :bind
  ("C-S-p" . 'md/move-lines-up)
  ("C-S-n" . 'md/move-lines-down)
  ("M-P" . 'md/duplicate-up)
  ("M-N" . 'md/duplicate-down))

(use-package wgrep
  :ensure t
  :config (setq wgrep-auto-save-buffer t))

(use-package symbol-overlay
  :ensure t)

(use-package visual-regexp
  :ensure t)

(use-package iedit
  :ensure t)

(use-package deadgrep
  :ensure t)

(use-package smartscan
  :ensure t
  :config (global-smartscan-mode t))

(use-package smart-indent-rigidly
  :ensure t
  :bind (("<C-tab>" . smart-rigid-indent)
         ("<backtab>" . smart-rigid-unindent)))

(use-package projectile
  :ensure t
  :init
  (projectile-global-mode 1)
  :bind (:map projectile-mode-map
              ("C-c p" . 'projectile-command-map)))

(use-package helm-projectile
  :after (projectile)
  :ensure t
  :config
  (setq projectile-completion-system 'helm)
  (helm-projectile-on))

(use-package magit
  :ensure t)

(use-package git-timemachine
  :ensure t)

(use-package helm
  :ensure t
  :bind
  ("C-x C-f" . helm-find-files)
  ("C-x C-b" . helm-buffers-list)
  ("M-x"     . helm-M-x)
  ("C-S-y"   . helm-show-kill-ring)
  :config
  (setq helm-split-window-in-side-p nil
        helm-autoresize-max-height 0
        helm-autoresize-min-height 40
        helm-M-x-fuzzy-match t
        helm-buffers-fuzzy-matching t
        helm-recentf-fuzzy-match t
        helm-semantic-fuzzy-match t
        helm-imenu-fuzzy-match t
        helm-echo-input-in-header-line t)
  :init
  (helm-mode 1)
  (helm-autoresize-mode 1)
  :bind (:map helm-map
              ("C-b" . helm-find-files-up-one-level)
              ("C-f" . helm-execute-persistent-action)))

(use-package helm-ag
  :ensure t
  :after (helm)
  :config
  (setq helm-ag-fuzzy-match t))

(use-package helm-swoop
  :bind
  ("C-s" . 'helm-swoop)
  ("C-r" . 'helm-swoop))

(use-package helm-tramp
  :ensure t
  :bind ("C-c c" . helm-tramp))

(use-package docker
  :ensure t
  :bind ("C-c d" . docker))

(use-package dockerfile-mode
  :ensure t
  :mode (("Dockerfile\\'" . dockerfile-mode)))

(use-package docker-tramp
  :ensure t)

(use-package lsp-mode
  :ensure t
  :commands lsp
  :config (setq lsp-prefer-flymake nil))

(use-package lsp-ui
  :ensure t
  :after (lsp)
  :commands lsp-ui-mode
  :hook (lsp-mode . lsp-ui-mode)
  :config
  (setq lsp-ui-doc-enable nil
        lsp-ui-peek-enable nil
        lsp-ui-sideline-enable nil
        lsp-ui-imenu-enable nil
        lsp-ui-flycheck-enable t))

(use-package company-lsp
  :ensure t)

(add-hook
 'lsp-mode-hook
 (lambda ()
   (add-to-list 'company-backends 'company-lsp)
   (company-mode 1)))

(use-package smartparens
  :ensure t
  :config
  (use-package smartparens-config)
  (smartparens-global-mode 1))

(use-package direnv
  :ensure t
  :config
  (setq direnv-show-paths-in-summary nil)
  (direnv-mode))

(use-package rainbow-mode
  :ensure t
  :hook
  ((org-mode lisp-interaction-mode typescript-mode) . rainbow-mode))

(use-package rainbow-delimiters
  :ensure t
  :hook
  ((lisp-mode emacs-lisp-mode lisp-interaction-mode org-mode) . rainbow-delimiters-mode))

(use-package shell-pop
  :ensure t
  :bind (("C-." . shell-pop))
  :config
  (setq shell-pop-shell-type
        (quote ("ansi-term" "*ansi-term*"
                (lambda nil (ansi-term shell-pop-term-shell)))))
  (setq shell-pop-term-shell "/bin/zsh")
  ;; need to do this manually or not picked up by `shell-pop'
  (shell-pop--set-shell-type 'shell-pop-shell-type shell-pop-shell-type))

(use-package restclient
  :ensure
  :mode (("\\.http\\'" . restclient-mode)))

(defvar http-buffer "*http*")
(defvar initial-http-message "# -*- restclient -*-\n#\n\n")

(defun aj/get-http-buffer-create ()
  (interactive)
  (let ((buf (get-buffer http-buffer)))
    (if (null buf)
        (progn
          (switch-to-buffer-other-window http-buffer)
          (restclient-mode)
          (insert initial-http-message))
      (switch-to-buffer-other-window http-buffer))))

(defun aj/zsh ()
  "Run a `zsh' instance."
  (interactive)
  (ansi-term "/bin/zsh"))

(bind-key "C-c ." 'aj/zsh)

(use-package company
  :ensure t
  :config
  ;; no delay before showing completion candidates
  (setq company-idle-delay 0)
  ;; show completion candidates after 3 chars are typed
  (setq company-minimum-prefix-length 3)
  :bind
  (("C-c <tab>" . 'company-complete)
   :map company-active-map
   ("M-n"     . nil)
   ("M-p"     . nil)
   ("C-n"     . 'company-select-next)
   ("C-j"     . 'company-select-next)
   ("C-p"     . 'company-select-previous)
   ("C-k"     . 'company-select-previous)
   ("C-f"     . 'company-filter-candidates)))

(use-package flycheck
  :ensure t)

(setq c-basic-offset 4)
(c-set-offset 'substatement-open 0)
(c-set-offset 'arglist-intro '+)
(c-set-offset 'arglist-close 0)

(use-package cquery
  :ensure t
  :config
  (setq cquery-executable "/usr/local/bin/cquery")
  (setq cquery-extra-init-params '(:index (:comments 2) :cacheFormat "msgpack")))

(add-hook 'c-mode-hook #'lsp)
(add-hook 'c++-mode-hook #'lsp)

(use-package helm-xref
  :ensure t
  :config
  (setq xref-show-xrefs-function 'helm-xref-show-xrefs))

;; (use-package helm-gtags
;;   :ensure t
;;   :config
;;   (setq helm-gtags-ignore-case t)
;;   (setq helm-gtags-auto-update t)
;;   (setq helm-gtags-use-input-at-cursor t)
;;   (setq helm-gtags-pulse-at-cursor t)
;;   (setq helm-gtags-prefix-key "\C-cj")
;;   (setq helm-gtags-suggested-key-mapping t)
;;   :hook
;;   (dired-mode . helm-gtags-mode)
;;   (eshell-mode . helm-gtags-mode)
;;   (c-mode . helm-gtags-mode)
;;   (c++-mode . helm-gtags-mode)
;;   (asm-mode . helm-gtags-mode)
;;   :bind (:map helm-gtags-mode-map
;;               ("C-c j a" . helm-gtags-tags-in-this-function)
;;               ("C-c j j" . helm-gtags-select)
;;               ("M-." . helm-gtags-dwim)
;;               ("M-," . helm-gtags-pop-stack)
;;               ("C-c <" . helm-gtags-previous-history)
;;               ("C-c >" . helm-gtags-next-history)))

(use-package alchemist
  :ensure t
  :init (setq alchemist-key-command-prefix (kbd "C-c ,")))

(add-hook
 'elixir-mode-hook
 (lambda ()
   (add-hook 'before-save-hook 'elixir-format nil t)))

(add-hook 'elixir-mode-hook 'company-mode)
(add-hook 'alchemist-iex-mode-hook 'company-mode)

(use-package lispy
  :ensure t
  :hook
  (lisp-mode . lispy-mode)
  (emacs-lisp-mode . lispy-mode)
  :bind
  (:map lispy-mode-map
        ("`" . 'self-insert-command)
        ("M-o" . 'ace-window)
        ("M-n" . nil)))

(use-package slime
  :ensure t
  :config
  (setq inferior-lisp-program "/usr/local/bin/sbcl")
  (setq slime-contribs '(slime-fancy)))

(add-hook 'emacs-lisp-mode-hook 'company-mode)

(add-hook 'lisp-mode-hook 'company-mode)

(use-package typescript-mode
  :config
  (setq typescript-indent-level 2)
  :ensure t
  :mode (("\\.ts\\'" . typescript-mode)))

(use-package tide
  :ensure t
  :after (typescript-mode)
  :hook
  (typescript-mode .
   (lambda ()
     (setq flycheck-check-syntax-automatically '(save mode-enabled))
     (tide-setup)
     (tide-hl-identifier-mode 1)
     (eldoc-mode 1))))

(add-hook 'typescript-mode-hook 'flycheck-mode)

(add-hook 'typescript-mode-hook 'company-mode)

(use-package elpy
  :ensure t
  :config (elpy-enable))

(use-package js2-mode
  :ensure t
  :config
  (setq js-indent-level 2)
  :mode (("\\.js\\'" . js2-mode)))

(use-package js2-refactor
  :ensure t
  :hook (js2-mode . js2-refactor-mode)
  :config (js2r-add-keybindings-with-prefix "C-c C-r")
  :bind (:map js2-mode-map
              ("C-k" . 'js2r-kill)))

(use-package xref-js2
  :ensure t
  :bind (:map js2-mode-map
              ("M-." . nil))
  :hook (js2-mode
         . (lambda ()
             (add-hook 'xref-backend-functions #'xref-js2-xref-backend nil t))))

(use-package rjsx-mode
  :ensure t
  :after (js2-mode)
  :mode
  (("\\.js\\'" . rjsx-mode)
   ("\\.jsx\\'" . rjsx-mode)))

(use-package company-tern
  :ensure t
  :hook (js2-mode .
                  (lambda ()
                    (add-to-list 'company-backends 'company-tern)
                    (company-mode)
                    (tern-mode))))

(use-package yaml-mode
  :ensure t)

(use-package go-mode
  :ensure t
  :hook
  (go-mode
   . (lambda ()
       (add-hook 'before-save-hook 'gofmt-before-save)
       (setq gofmt-command "goimports")
       (if (not (string-match "go" compile-command))
           (set (make-local-variable 'compile-command)
                "go build -v && go test -v && go vet"))))
  :bind (:map go-mode-map
              ("C-c C-c" . compile)
              ("C-c C-p" . recompile)
              ("M-]" . next-error)
              ("M-[" . previous-error)))

(use-package go-eldoc
  :ensure t
  :after (go-mode)
  :hook (go-mode . go-eldoc-setup))

(use-package company-go
  :ensure t
  :after (go-mode)
  :hook
  (go-mode
   . (lambda ()
       (add-to-list 'company-backends 'company-go)
       (company-mode 1))))

(use-package go-guru
  :ensure t
  :bind (:map go-mode-map
              ("M-." . go-guru-definition)
              ("M-," . pop-tag-mark))
  :hook (go-mode
         . (lambda ()
             (require 'go-guru)
             (go-guru-hl-identifier-mode 1))))

(use-package css-mode
  :config
  (setq css-indent-offset 2)
  (company-mode 1))

(use-package web-mode
  :ensure t
  :config
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-markup-indent-offset 2)
  :init
  (setq-default
   web-mode-comment-formats
   '(("java"       . "/*")
     ("javascript" . "//")
     ("jsx"        . "//")
     ("php"        . "/*")))
  :mode (("\\.tsx\\'" . web-mode))
  :hook
  (web-mode
   . (lambda ()
       (when (string-equal "tsx" (file-name-extension buffer-file-name))
         (if (equal web-mode-content-type "javascript")
             (web-mode-set-content-type "jsx"))
         (tide-setup)
         (flycheck-mode 1)
         (setq flycheck-check-syntax-automatically '(save mode-enabled))
         (tide-hl-identifier-mode 1)
         (eldoc-mode 1)
         (company-mode 1)
         (flycheck-add-mode 'typescript-tslint 'web-mode))
       (setq web-mode-markup-indent-offset 2))))

(use-package sh-mode
  :hook
  (sh-mode
   . (lambda ()
     (company-mode 1)))
  :mode (("\\zshrc\\'" . sh-mode)))

(setq sh-basic-offset 2)

(defun aj/irc (&optional server port nick)
  "Log into irc server.
  Uses default values for SERVER, PORT and NICK if they are not supplied"
  (interactive)
  (erc
   :server (or server "irc.freenode.net")
   :port   (or port   "6667")
   :nick   (or nick   "andyjac")))

;; enable company-mode for erc
(add-hook 'erc-mode-hook 'company-mode)
