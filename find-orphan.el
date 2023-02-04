;;; find-orphan.el --- Find orphan function

;; Filename: find-orphan.el
;; Description: Find orphan function
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2021, Andy Stewart, all rights reserved.
;; Created: 2021-11-27 10:50:57
;; Version: 0.1
;; Last-Updated: 2021-11-27 10:50:57
;;           By: Andy Stewart
;; URL: https://www.github.org/manateelazycat/find-orphan
;; Keywords:
;; Compatibility: GNU Emacs 29.0.50
;;
;; Features that might be required by this library:
;;
;;

;;; This file is NOT part of GNU Emacs

;;; License
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; Find orphan function
;;

;;; Installation:
;;
;; Put find-orphan.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'find-orphan)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET find-orphan RET
;;

;;; Change log:
;;
;; 2021/11/27
;;      * First released.
;;

;;; Acknowledgements:
;;
;;
;;

;;; TODO
;;
;;
;;

;;; Require
(require 'cl-lib)
(require 'treesit)

;;; Code:

(defvar find-orphan-search-dir nil)

(defun find-orphan-get-match-nodes (query)
  (ignore-errors
    (mapcar #'(lambda (range)
                (treesit-node-at (car range)))
            (treesit-query-range
             (treesit-node-language (treesit-buffer-root-node))
             query))))

(defun find-orphan-match-times-in-buffer (search-string)
  (let ((match-count 0))
    (save-excursion
      (goto-char (point-min))
      (while (search-forward search-string nil t)
        (setq match-count (1+ match-count))))
    match-count))

(defun find-orphan-match-times-in-directory (search-string)
  (let ((search-command (format "rg --no-ignore -g '!node_modules' -g '!dist' -e %s %s --stats -q" search-string find-orphan-search-dir)))
    (string-to-number (nth 0 (split-string (nth 1 (split-string (shell-command-to-string search-command) "\n")))))))

(defun find-orphan-function (match-times-func location)
  (interactive)
  (let* ((function-nodes (append (find-orphan-get-match-nodes '((function_definition name: (symbol) @name)))
                                 (find-orphan-get-match-nodes '((function_definition name: (identifier) @x)))
                                 (find-orphan-get-match-nodes '((method_declaration name: (identifier) @x)))
                                 (find-orphan-get-match-nodes '((function_declaration name: (identifier) @x)))
                                 ))
         (function-names (mapcar #'treesit-node-text function-nodes))
         (noreference-functions (cl-remove-if-not #'(lambda (f) (<= (funcall match-times-func f) 1)) function-names)))

    (if (> (length noreference-functions) 0)
        (progn
          (message "Found below orphan functions in current %s." location)
          (message "--------")
          (mapcar #'(lambda (f) (message "%s" f)) noreference-functions)
          (message "--------")
          (message "Found %s orphan functions, switch to buffer `*Messages*' to review." (length noreference-functions)))
      (message "Yay, no orphan function found in current %s." location))))

(defun find-orphan-function-in-buffer ()
  (interactive)
  (find-orphan-function 'find-orphan-match-times-in-buffer "buffer"))

(defun find-orphan-function-in-directory ()
  (interactive)
  (setq find-orphan-search-dir (expand-file-name (read-directory-name "Find orphan function at directory: ")))
  (find-orphan-function 'find-orphan-match-times-in-directory "directory"))

(provide 'find-orphan)

;;; find-orphan.el ends here
