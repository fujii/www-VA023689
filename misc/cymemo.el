;;; cymemo.el --- Simple memo tool

;; Copyright (C) 2002-2012 Fujii Hironori

;; Author: Fujii Hironori
;; Created: 21 Apr 2002
;; Keywords: tools
;; Package-Version: 1.1
;; Package-Requires: 

;; Cymomo mode

(defvar cymemo-filename "~/doc/cymemo/cymemo.txt")

(defvar cymemo-mode-font-lock-keywords
  '(("^$" . font-lock-variable-name-face)))

(defconst cymemo-mode-font-lock-defaults
  '(cymemo-mode-font-lock-keywords t nil nil beginning-of-line))

(defvar cymemo-mode-syntax-table nil
  "Syntax table used while in cymemo mode.")
     
(if cymemo-mode-syntax-table
    ()              ; Do not change the table if it is already set up.
  (setq cymemo-mode-syntax-table (make-syntax-table)))
     
(defvar cymemo-mode-abbrev-table nil
  "Abbrev table used while in cymemo mode.")
(define-abbrev-table 'cymemo-mode-abbrev-table ())
     
(defvar cymemo-mode-map nil	      ; Create a mode-specific keymap.
  "Keymap for Cymemo mode.
     Many other modes, such as Mail mode, Outline mode and Indented Cymemo mode,
     inherit all the commands defined in this map.")
     
(if cymemo-mode-map
    ()		   ; Do not change the keymap if it is already set up.
  (setq cymemo-mode-map (make-sparse-keymap))
  (define-key cymemo-mode-map "\C-c\C-a" 'cymemo-new-entry))

(defun cymemo-mode ()
  "Major mode for editing cymemo intended
  Special commands: \\{cymemo-mode-map}
  Turning on cymemo-mode runs the hook `cymemo-mode-hook'."
  (interactive)
  (kill-all-local-variables)
  (use-local-map cymemo-mode-map)
  (setq local-abbrev-table cymemo-mode-abbrev-table)
  (set-syntax-table cymemo-mode-syntax-table)
  (setq major-mode 'cymemo-mode)
  (set (make-local-variable 'font-lock-defaults) cymemo-mode-font-lock-defaults)
  (run-hooks 'cymemo-mode-hook))

;;;###autoload
(defun cymemo ()
  (interactive)
  (find-file cymemo-filename)
  (cymemo-mode))

(defun cymemo-new-entry ()
  (interactive)
  (goto-char (point-min))
  (insert (format-time-string "Date: %Y-%m-%d (%a)\n"))
  (insert "Subject: \n")
  (insert "\n")
  (insert "\n")
  (end-of-line -2))

;;; cymemo.el ends here
