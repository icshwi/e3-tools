;;
;; This is the unofficial configuration file for iocuser of ICS at ESS
;;
;;  Author  : Jeong Han Lee
;;  email   : han.lee@esss.se
;;  Date    : 2016-10-25
;;  version : 0.0.1

(setq column-number-mode t)
(setq auto-compression-mode t)
(setq vc-follow-symlinks t)

(if (featurep 'paren)
    ( (require 'paren)
      (show-paren-mode 1)))

;; default to better frame titles
(setq frame-title-format (concat invocation-name "@" system-name ": %b %+%+ %f"))

(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(add-hook 'org-mode-hook 'turn-on-font-lock)
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)

(transient-mark-mode 1)

(setq org-log-done 'note)
(setq org-todo-keywords
      '((sequence "TODO" "PROGRESSING" "|" "DONE" "DELEGATED")))

;; see how to format
;; http://www.delorie.com/gnu/docs/elisp-manual-21/elisp_689.html
;; %A : This stands for the full name of the day of week. 
;; %B : This stands for the full name of the month. 
;; %e : This stands for the day of month, blank-padded. 
;; %H : his stands for the hour (00-23). 
;; %M : This stands for the minute (00-59). 
;; %S : This stands for the seconds (00-59). 
;; %Z : This stands for the time zone abbreviation. 
;; %Y : This stands for the year with century. 

(defvar insert-date-format "%A, %B %e %H:%M:%S %Z %Y")

(defun insert-date ()
  "Insert the current date"
  (interactive "*")
  (insert (format-time-string insert-date-format (current-time) )))


 
(global-set-key [?\S- ] 'toggle-input-method)
(global-set-key [f5] 'insert-date)

;; not necessary for 23-2 emacs
;;(global-set-key (kbd "C-x <left>") 'previous-buffer)
;;(global-set-key (kbd "C-x <right>") 'next-buffer)

;; handle color codes properly in shell enviroment into emacs shell

(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;; for emacs 23 or later

(setq tex-view "xdvi -watchfile 1 *")

(load-file "$HOME/.emacs.d/epics-mode.el")
(require 'epics-mode)

(if (featurep 'ecb)
    (require 'ecb))


(setq auto-mode-alist (cons '("\\.json\\'" . js-mode) auto-mode-alist))


(autoload 'markdown-mode "markdown-mode"
   "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.text\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))


(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(doc-view-continuous t)
 '(ecb-auto-activate nil)
 '(ecb-compile-window-height nil)
 '(ecb-layout-window-sizes nil)
 '(ecb-new-ecb-frame nil)
 '(ecb-options-version "2.40")
 '(ecb-tree-buffer-style (quote image))
 '(ecb-tree-expand-symbol-before t)
 '(font-use-system-font t)
 '(inhibit-startup-screen t)
 '(ispell-personal-dictionary "~/.aspell.LANG.pws")
 '(ispell-skip-html t)
 '(safe-local-variable-values (quote ((TeX-master . t))))
 '(show-paren-mode t)
 '(text-mode-hook (quote (text-mode-hook-identify))))

(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "white" :foreground "black" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 99 :width normal :foundry "unknown" :family "DejaVu Sans Mono")))))
