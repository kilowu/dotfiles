;;; init.el -- my .emacs file

;; Wu Wei <weiwu@cacheme.net>
;; Copyright (c) 2018

;;; Commentary:

;; The init.el/Commentary/Code lines only exist for making flycheck happy
;; TODO: find a way to prevent flycheck from checking these crazily

;;; Code:

(eval-when-compile
  ;; MELPA setup
  (require 'package)
  (let* ((no-ssl (or (memq system-type '(windows-nt ms-dos))
                     (not (gnutls-available-p))))
         (proto (if no-ssl "http" "https")))
    (add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
    (when (< emacs-major-version 24)
      ;; For important compatibility libraries like cl-lib
      (add-to-list 'package-archives (cons "gnu" (concat proto "://elpa.gnu.org/packages/")))))
  (package-initialize)
  (unless (package-installed-p 'use-package)
  (package-install 'use-package))
  (require 'use-package))


(set-language-environment 'UTF-8)
(global-font-lock-mode 1)
; remove startup message
(setq inhibit-startup-message t)
(show-paren-mode t)
(setq show-paren-style 'parentheses)
;; use 4 spaces to as tab
(setq-default indent-tabs-mode nil)
;; scroll down with the cursor, move down the buffer one line at a time
(setq scroll-step 1)
;; represent the buffer name as title
(setq frame-title-format "%f")
(setq column-number-mode t)
(setq line-number-mode t)

;; set cursor to a vertical bar
(setq-default cursor-type 'bar)
;; disable blinking
(blink-cursor-mode 0)


;; GUI mode settings
(when window-system
  ;; remove toolbar
  (tool-bar-mode -1)
  ;; set default frame size
  (set-frame-size (selected-frame) 130 50)
  ;; set a dark color theme
  (load-theme 'tsdh-dark)

  ;; macOS things
  (if (eq system-type 'darwin)
      ;; Set font (especially for size), because the default font size is too
      ;; small on macOS.
      (set-face-attribute 'default nil :font
                          "-outline-Monaco-normal-normal-normal-mono-14-*-*-*-c-*-iso8859-1" ))
  ) ;; End of GUI settings



;; Backup files can be really anoying, so redirect them to /tmp
(setq backup-directory-alist
       `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))


;; coding standard of the Apsara project
(defconst apsara-c-style
  '((c-basic-offset . 4)
    (c-comment-only-line-offset . 0)
    (c-hanging-braces-alist     . ((substatement-open before after)
                                   (brace-list-open)))
    (c-offsets-alist (statement-block-intro . +)
                     (substatement-open . 0)
                     (inline-open . 0)
                     (substatement-label . 0)
                     (statement-cont . +)
                     (namespace-open . [0]) ;absolute offset 0
                     (namespace-close . [0]) ;absolute offset 0
                     (innamespace . [0])
                     )
    )
  "Apsara C/C++ Programming Style\nThis style is a modification of stroustrup style.")
(c-add-style "apsara" apsara-c-style)
(setq c-default-style '((c++-mode . "apsara") (c-mode . "apsara") (awk-mode . "awk") (other . "gnu")))

;; load .h in c++-mode
(setq auto-mode-alist
      (append '(("\\.h$" . c++-mode)) auto-mode-alist))


;; Helm/Projectile
(use-package helm
  :ensure t
  :init (helm-mode 1))


(use-package projectile
  :ensure t
  :after (helm)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  ("s-p" . projectile-command-map)
  :config
  (projectile-mode)
  (setq projectile-completion-system 'helm)
  (setq projectile-enable-caching t)) ; indexing big projects at every time is just slow


;; Flycheck
(use-package flycheck
  :ensure t
  :hook (after-init . global-flycheck-mode))


;; Magit
(use-package magit
  :ensure t)
