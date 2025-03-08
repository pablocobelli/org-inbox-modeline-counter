;;; org-inbox-modeline-counter.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2025 Pablo Cobelli
;;
;; Author: Pablo Cobelli <pablo.cobelli@gmail.com>
;; Maintainer: Pablo Cobelli <pablo.cobelli@gmail.com>
;; Created: March 08, 2025
;; Modified: March 08, 2025
;; Version: 0.0.1
;; Keywords: org-gtd modeline counter
;; Homepage: https://github.com/pablocobelli/org-inbox-modeline-counter
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:

(require 'filenotify)

(defgroup org-inbox-modeline-counter nil
  "Display first-level-heading item count in the modeline for file org-inbox-modeline-counter-watch-file."
  :group 'org)

(defcustom org-inbox-modeline-counter-watch-file nil
  "Path to the file that will be watched for first-level-heading items."
  :type 'string)

(defcustom org-inbox-modeline-counter-help-echo-text "items in GTD inbox."
  "Text that will accompany the item count in the help-echo line. Defaults to 'items in the GTD inbox.'"
  :type 'string
  :group 'org-inbox-modeline-counter)

(defvar org-inbox-modeline-counter-watch-descriptor nil
  "File notification descriptor for watching org-inbox-modeline-counter-watch-file file.")

(defun org-inbox-modeline-counter-item-count ()
  "Count first-level headings in org-inbox-modeline-counter-watch-file file."
  (when (and org-inbox-modeline-counter-watch-file (file-exists-p org-inbox-modeline-counter-watch-file))
    (with-temp-buffer
      (insert-file-contents org-inbox-modeline-counter-watch-file)
      (format "%d" (count-matches "^* ")))))

(defun org-inbox-modeline-counter-update-modeline ()
  "Update the modeline with the current count of first-level headings."
  (let ((count (org-inbox-modeline-counter-item-count)))
    (setq-default mode-line-misc-info
                  (list (propertize count
                                    'face 'font-lock-keyword-face
                                    'help-echo (format "%s %s" count org-inbox-modeline-counter-help-echo-text)
                                    'mouse-face 'highlight
                                    'local-map (let ((map (make-sparse-keymap)))
                                                 (define-key map [mode-line down-mouse-1] 'org-inbox-modeline-counter-open-inbox)
                                                 map))))))

(defun org-inbox-modeline-counter-on-inbox-change (_event)
  "Handler for changes to org-inbox-modeline-counter-watch-file file."
  (org-inbox-modeline-counter-update-modeline))

(defun org-inbox-modeline-counter-start-watching ()
  "Start watching org-inbox-modeline-counter-watch-file file."
  (org-inbox-modeline-counter-stop-watching)
  (when org-inbox-modeline-counter-watch-file
    (setq org-inbox-modeline-counter-watch-descriptor
          (file-notify-add-watch org-inbox-modeline-counter-watch-file '(change) #'org-inbox-modeline-counter-on-inbox-change))
    (org-inbox-modeline-counter-update-modeline)))

(defun org-inbox-modeline-counter-stop-watching ()
  "Stop watching the org-inbox-modeline-counter-watch-file file."
  (when org-inbox-modeline-counter-watch-descriptor
    (file-notify-rm-watch org-inbox-modeline-counter-watch-descriptor)
    (setq org-inbox-modeline-counter-watch-descriptor nil)))

(defun org-inbox-modeline-open-inbox ()
  "Open the org-inbox-modeline-counter-watch-file file."
  (interactive)
  (when org-inbox-modeline-counter-watch-file
    (find-file org-inbox-modeline-counter-watch-file)))

(define-minor-mode org-inbox-modeline-counter-mode
  "Toggle item count for org-inbox-modeline-counter-watch-file file in the modeline."
  :global t
  :lighter nil
  (if org-inbox-modeline-counter-mode
      (org-inbox-modeline-counter-start-watching)
    (org-inbox-modeline-counter-stop-watching)))

(provide 'org-inbox-modeline-counter)
;;; org-inbox-modeline-counter.el ends here
