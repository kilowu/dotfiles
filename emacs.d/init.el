;;; init.el -- my .emacs file

;; Wu Wei <weiwu@cacheme.net>
;; Copyright (c) 2018

;;; Commentary:

;; The init.el/Commentary/Code lines only exist for making flycheck happy
;; TODO: find a way to prevent flycheck from checking these crazily

;;; Code:

;; use-package settings
(eval-when-compile
  ;; MELPA setup
  (require 'package)
  (let* ((no-ssl (or (memq system-type '(windows-nt ms-dos))
                     (not (gnutls-available-p))))
         (proto (if no-ssl "http" "https")))
    (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
    (add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
    (when (< emacs-major-version 24)
      ;; For important compatibility libraries like cl-lib
      (add-to-list 'package-archives (cons "gnu" (concat proto "://elpa.gnu.org/packages/")))))
  (package-initialize)
  (unless (package-installed-p 'use-package)
    (package-install 'use-package))
  (require 'use-package))

;; Use use-package to automate package downloading.
(setq use-package-always-ensure t)
;; Prefer stable version by default. You can always specifically pin another repo
;; in indivisual use-package statement.
(setq use-package-always-pin "melpa-stable")


;;; Basic settings

(set-language-environment 'UTF-8)
(global-font-lock-mode 1)
; remove startup message
(setq inhibit-startup-message t)
(show-paren-mode t)
;; use 4 spaces to as tab
(setq-default indent-tabs-mode nil)
;; scroll down with the cursor, move down the buffer one line at a time
(setq scroll-step 1)
(setq column-number-mode t)
(setq line-number-mode t)
(blink-cursor-mode 1)

;; Backup files can be really anoying, so redirect them to /tmp
(setq backup-directory-alist
       `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))


(if window-system
     ;;; GUI settings. Window components are kept to be minimal.
    (progn
      ;; Remove toolbar. Frankly speaking, it's ugly and of little usage.
      (tool-bar-mode -1)
      ;; Remove scroll bar. Seriously, who uses it to scroll around? Since the whole point
      ;; of emacs is to keep your hands on keyboard.
      (scroll-bar-mode 0)
      ;; A slim vertical bar looks clean and swift. Cursor type can be only changed under GUI.
      (setq-default cursor-type 'bar)


      ;; macOS things
      (if (eq system-type 'darwin)
          ;; Set font (especially for size), because the default font size is too
          ;; small on macOS.
          (set-face-attribute 'default nil :font
                              "-outline-Monaco-normal-normal-normal-mono-14-*-*-*-c-*-iso8859-1" )
        ;; Turn off menu bar if the system is not macOS. Menu bar only looks good at
        ;; GUI mode of macOS, which resides at the top of desktop.
        (menu-bar-mode 0))
      ) ;; End of GUI settings
  ;; We turn off menu bar in terminal mode regardless of the system type.
  (menu-bar-mode 0))

;; theme
(use-package color-theme-solarized
  :init
  ;; load-theme will trigger a prompt from emacs saying the theme runs elisp
  ;; code. Then it is your responsibility to ensure it's safe to do so. After
  ;; that, the approved (by you) theme will be registered in custom-set-variables
  ;; generated by emacs custom. So next time it can load the same theme without
  ;; asking your permission. However, this mechanism is broken here. Because
  ;; this init.el is supposed to run before custom scripts.
  ;; Hence load-theme is placed in the hook "after-init-hook".
  (add-hook 'after-init-hook (lambda ()
                               (load-theme 'solarized t))))


(use-package smart-mode-line
  ;; Prevent theme from being loaded before custom generated code. Also see above code of load-theme.
  :hook (after-init . (lambda () (sml/setup))))


;; A mode to hide minor mode name from status bar.
;; We will use it in use-packge. So we must ensure this package is installed
;; prior to the declarations for other packages.
(use-package diminish)


;; Helm
;;  see http://tuhdo.github.io/helm-intro.html
(use-package helm
  :diminish helm-mode
  :bind (("M-x" . 'helm-M-x) ; A great M-x replacement, which can fully leverage the helm discovery engine.
         ("C-x b" . 'helm-mini) ; besides buffers, this mode also offers recentf
         ("C-x C-f" . 'helm-find-files)
         ("M-y". 'helm-show-kill-ring))
  :init (helm-mode 1)
  :config
  (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to do persistent action
  ;; (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB works in terminal
  (define-key helm-map (kbd "C-z")  'helm-select-action)) ; list actions using C-z


;; Projectile
(use-package projectile
  :after (helm)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  ("s-p" . projectile-command-map)
  :config
  (projectile-mode)
  (setq projectile-completion-system 'helm)
  (setq projectile-enable-caching t)) ; indexing big projects at every time is just slow


;; company: a completion (complete anything) front-end
(use-package company
  :diminish company-mode
  :hook (after-init . global-company-mode))


;; Flycheck
(use-package flycheck
  :diminish flycheck-mode
  :hook (after-init . global-flycheck-mode))


;; Magit
(use-package magit
  ;; Magit enables auto-revert-mode for git tracked files
  :diminish auto-revert-mode
  :bind ("C-x g" . magit-status)
  :init
  ;; "C-c M-g" to magit-file-popup when in normal file buffer
  (global-magit-file-mode))


;; Irony
(use-package irony
  :hook
  (c++-mode . irony-mode)
  (c-mode . irony-mode)
  (irony-mode . irony-cdb-autosetup-compile-options))

;; company-irony: the irony back-end of company
(use-package company-irony
  :after (irony company)
  :config (add-to-list 'company-backends 'company-irony))


;; Brute-forced jump-to-definition tool. Just ag/git-grep/grep the code by pattern.
(use-package dumb-jump
  :bind (("M-g o" . dumb-jump-go-other-window)
         ("M-g j" . dumb-jump-go)
         ("M-g i" . dumb-jump-go-prompt)
         ("M-g x" . dumb-jump-go-prefer-external)
         ("M-g z" . dumb-jump-go-prefer-external-other-window))
  :config
  (setq dumb-jump-selector 'helm))


;;; Other customization stuff not managed by use-package

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


;; To make flycheck happy
(provide 'init)
;;; init.el ends here
