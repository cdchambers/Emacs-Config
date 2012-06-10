;; Do this early on in the load so it doesn't stay visible while loading
(setq inhibit-splash-screen t)  ; no splash screen
(line-number-mode 1)            ; have line numbers
(column-number-mode 1)          ; and column numbers

(tool-bar-mode -1)  ;; no tool bar
(scroll-bar-mode -1)
(unless (string-match "apple-darwin" system-configuration)
  ;; on mac, theres always a menu drawn, so don't let it empty
  (menu-bar-mode -1))

;; Setup some nice fonts
(if (string-match "apple-darwin" system-configuration)
    (set-face-font 'default "Monaco-13")
  (set-face-font 'default "Monospace-10"))

(global-hl-line-mode) ; highlight current line
(global-linum-mode 1) ; add line numbers on the left

;; avoid compiz manager rendering bugs
(add-to-list 'default-frame-alist '(alpha . 100))

(cua-mode)

;; under mac, have Command as Meta and keep Option for localized input
(when (string-match "apple-darwin" system-configuration)
  (setq mac-allow-anti-aliasing t)
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier 'none))

;; use the clipboard, pretty please, so that copy/paste "works"
(setq x-select-enable-clipboard t)

;; Navigate windows with M-<arrows>
(windmove-default-keybindings 'meta)
(setq windmove-wrap-around t)

;; whenever an external process changes a file underneath emacs, and there
;; was no unsaved changes in the corresponding buffer, just revert its content
;; to reflect what's on -disk
(global-auto-revert-mode 1)

;; M-x shell is a nice shell interface to use, let's make it colorful.
;; If you need a terminal emulater rather than just a shell, consider M-x term
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;; use ido for minibuffer completion
(require 'ido)
(ido-mode t)
(setq ido-save-directory-list-file "~/.emacs.d/.ido.last")
(setq ido-enable-flex-matching t)
(setq ido-use-filename-at-point 'guess)
(setq ido-show-dot-for-dired t)

;; default key to switch buffer is C-x b, but that's not easy enough
;;
;; When you do this, to kill emacs either close its frame from the window
;; manager, or do M-x kill-emacs.  Don't need a nice shortcut for an irregular
;; action
(global-set-key (kbd "C-x C-b") 'ido-switch-buffer)
(global-set-key (kbd "C-x C-c") 'ido-switch-buffer)
(global-set-key (kbd "C-x B") 'ibuffer)

;; C-x C-j opens dired with the cursor right on the file you're editing
(require 'dired-x)

;; Full screen
(defun fullscreen ()
  (interactive)
  (set-frame-parameter nil 'fullscreen
    (if (frame-parameter nil 'fullscreen) nil 'fullboth)))
(global-set-key [f11] 'fullscreen)

(require 'cl)

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

(defvar my-packages 
 '(magit color-theme-solarized)
 "Libraries that should be installed by default")

(defun install-my-packages ()
  "Install all packages listed in my-packages that aren't installed."
  (interactive)
  (dolist (package my-packages)
    (unless (or (member package package-activated-list)
                (functionp package))
      (message "Installing %s" (symbol-name package))
      (package-install package))))

(defun is-online? ()
  "See if we're online.  

On Windows, which doesn't have network-interface-list, assume we're online."
  (if (and (functionp 'network-interface-list)
           (network-interface-list))
      (some (lambda (iface) (unless (equal "lo" (car iface))
                              (member 'up (first (last (network-interface-info
                                                        (car iface)))))))
            (network-interface-list))
      t))

(when (is-online?)
  (unless package-archive-contents (package-refresh-contents))
  (install-my-packages))

;; Setup some nicer fonts/themes
(load-theme 'solarized-dark t)

;; Setup magit now that its loaded
(global-set-key (kbd "C-x C-z") 'magit-status)