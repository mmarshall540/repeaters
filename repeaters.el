;;; repeaters.el --- Repeater maps for common Emacs commands  -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Martin Marshall

;; Author: Martin Marshall <law@martinmarshall.com>
;; Keywords: convenience

;; This file is NOT part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package is a proof-of-concept.  It provides a function for
;; easily defining multiple repeat-maps and associating them with
;; commands.  It also provides a default set of repeat maps to reduce
;; the need for modifier keys when entering commands.
;;
;; Repeat maps are a feature of Emacs 28, which this package requires.
;;
;; To use, you can place this file within your load-path, and add
;; something like the following to your configuration:
;;
;; (require 'repeaters)
;; (repeaters-define-repmaps repeaters-repmaps)
;; (setq repeat-exit-key "g"
;;       repeat-exit-timeout 30)
;; (repeat-mode)

;;; Code:

(defun repeaters-define-repmaps (rlist)
  "Define an arbitrary number of repeater maps.

Maps are defined based on the lists passed through RLIST, a
quoted list containing ‘repeat-map’ definitions.  Each definition
is itself a list containing the following items:

NAME is a string designating the unique portion of the
repeat-map’s name (to be constructed into the form
‘repeaters-NAME-rep-map’ as the name of the symbol for the map).

One or more command ENTRIES made up of the following:

    The COMMAND’s symbol;

    One or more string representations of KEY-SEQUENCES which
    may be used to invoke the command when the ‘repeat-map’ is
    active;

    Optionally, the KEYWORD ‘:exitonly’ may follow the key sequences.

A single map definition may include any number of these command
entry constructs.

If a command construct ends with the ‘:exitonly’ keyword, the map
can invoke the command, but the command will *not* invoke that
map.

However, if the keyword is omitted, the command will bring up the
‘repeat-map’ whenever it is called using one of the keysequences
given in the ‘repeat-map’.  A given command may only store a
single map within its ‘repeat-map’ property, although a command
can be called from multiple repeat-maps.

Taking advantage of this fact, one may chain related repeat-maps
together in sequence."
  (while rlist
    (let* ((block (pop rlist))
           (mapname (concat "repeaters-" (pop block) "-rep-map")))
      (set (intern mapname)
           (let ((map (make-sparse-keymap))
                 (thing (pop block)))
             (while block
               (let ((thingnext (pop block)))
                 (while (stringp thingnext)
                   (define-key map (kbd thingnext) thing)
                   (setq thingnext (pop block)))
                 (if (eq thingnext :exitonly)
                     (setq thing (pop block))
                   (progn (put thing 'repeat-map (intern mapname))
                          (setq thing thingnext)))))
             map)))))

(defvar repeaters-repmaps
  '(("buffer-switch"
     previous-buffer                   "C-x C-<left>" "C-x <left>" "C-<left>" "<left>" "p"
     next-buffer                       "C-x C-<right>" "C-x <right>" "C-<right>" "<right>" "n")

    ("calendar-nav"
     calendar-forward-day              "C-f" "f"
     calendar-backward-day             "C-b" "b"
     calendar-forward-week             "C-n" "n"
     calendar-backward-week            "C-p" "p"
     calendar-forward-month            "M-}" "}" "]"
     calendar-backward-month           "M-{" "{" "["
     calendar-forward-year             "C-x ]"
     calendar-backward-year            "C-x [")

    ("char-line-nav"
     backward-char                     "C-b" "b"
     forward-char                      "C-f" "f"
     next-line                         "C-n" "n"
     previous-line                     "C-p" "p")

    ("defun-nav"
     beginning-of-defun                "C-M-a" "M-a" "a" "ESC M-a"
     end-of-defun                      "C-M-e" "M-e" "e" "ESC M-e")

    ("del-char"
     delete-char                       "C-d" "d")

    ("sexp-nav"
     backward-sexp                     "C-M-b" "b" "ESC M-b" ", , b"
     forward-sexp                      "C-M-f" "f" "ESC M-f" ", , f")
    
    ("paragraph-nav"
     backward-paragraph                "C-<up>" "<up>" "M-{" "M-[" "{" "["
     forward-paragraph                 "C-<down>" "<down>" "M-}" "M-]" "}" "]")

    ("sentence-nav"
     backward-sentence                 "M-a" "a"
     forward-sentence                  "M-e" "e"
     back-to-indentation               "M-m" "m"                     :exitonly)

    ("in-line-nav"
     move-end-of-line                  "C-a" "a"
     move-end-of-line                  "C-e" "e")

    ("page-nav"
     backward-page                     "C-x [" "["
     forward-page                      "C-x ]" "]")
    
    ("list-nav"
     backward-list                     "C-M-p" "p" "ESC M-p"
     forward-list                      "C-M-n" "n" "ESC M-n"
     backward-up-list                  "C-M-<up>" "C-M-u" "<up>" "u" "ESC M-u"
     down-list                         "C-M-<down>" "C-M-d" "<down>" "d" "ESC M-d")

    ("error-nav"
     next-error                        "C-x `" "`" "M-g M-n" "M-g n" "n"
     previous-error                    "M-g M-p" "M-p" "p")

    ("mid-top-bottom-move"
     recenter-top-bottom               "C-l" "l"
     move-to-window-line-top-bottom    "M-r" "r"
     back-to-indentation               "M-m" "m"                     :exitonly)

    ("fix-case"
     upcase-word                       "M-u" "u"

     ;; Easy way to manually set title case
     downcase-word                     "M-l" "l" "d"
     capitalize-word                   "M-c" "c")
    
    ("kill-word"
     kill-word                         "M-d" "M-<delete>" "d")
    
    ("kill-line"
     kill-line                         "C-k" "k")
    
    ("kill-sentence"
     kill-sentence                     "M-k" "k"
     backward-kill-sentence            "C-x DEL" "DEL")
    
    ("kill-sexp"
     kill-sexp                         "C-M-k" "k" "ESC M-k")

    ;; Yank same text repeatedly with “C-y y y y”...
    ("yank-only"
     yank                              "C-y" "y"
     yank-pop                          "M-y" "n"                     :exitonly)

    ;; Cycle through the kill-ring with “C-y n n n”...
    ;; You can reverse direction too “C-y n n C-- n n”
    ("yank-popping"
     yank-pop                          "M-y" "y" "n")
    
    ("kmacro-cycle"
     kmacro-cycle-ring-next            "C-x C-k C-n" "C-n" "n"
     kmacro-cycle-ring-previous        "C-x C-k C-p" "C-p" "p")

    ("tab-bar-nav"
     tab-next                          "C-x t o" "o" "n"
     tab-previous                      "C-x t O" "O" "p")

    ("transpose-chars"
     transpose-chars                    "C-t" "t")

    ("transpose-words"
     transpose-words                   "M-t" "t")

    ("transpose-sexps"
     transpose-sexps                   "C-M-t" "t" "ESC M-t")
    
    ("transpose-lines"
     transpose-lines                   "C-x C-t" "t")

    ;; M-< for beginning-of-buffer brings up this map, since you can
    ;; only scroll a buffer up when at its beginning.
    ("scroll-up"
     scroll-up-command                 "C-v" "v"
     beginning-of-buffer               "M-<" "<"
     end-of-buffer                     "M->" ">"                     :exitonly
     scroll-down-command               "M-v"                         :exitonly)

    ;; M-> for end-of buffer brings up this map, since you can only
    ;; scroll a buffer down when at its end.
    ("scroll-down"
     scroll-down-command               "M-v" "v"
     end-of-buffer                     "M->" ">"
     beginning-of-buffer               "M-<" "<"                     :exitonly
     scroll-up-command                 "C-v"                         :exitonly)

    ("scroll-otherwin"
     scroll-other-window               "C-M-v" "v" "ESC M-v"
     beginning-of-buffer-other-window  "M-<home>" "<"
     end-of-buffer-other-window        "M-<end>" ">"                 :exitonly
     scroll-other-window-down          "C-M-S-v" "M-v" "ESC M-V" "V" :exitonly)
    
    ("scroll-otherwin-down"
     scroll-other-window-down          "C-M-S-v" "M-v" "v" "ESC M-V" "V"
     end-of-buffer-other-window        "M-<end>" ">"
     beginning-of-buffer-other-window  "M-<home>" "<"                :exitonly
     scroll-other-window               "C-M-v" "C-v" "ESC M-v"       :exitonly)

    ("scroll-sideways"
     scroll-left                       "C-x <" "<"
     scroll-right                      "C-x >" ">")

    ("hippie-exp"
     ;; For navigating through expansion candidates. You can revert
     ;; to the original string by prefixing the next hippie-expand
     ;; invocation with universal-argument (“C-u /”).
     hippie-expand                     "M-/" "/")

    ("search-nav"
     isearch-repeat-forward            "C-s" "s" "C-M-s" "ESC M-s"
     isearch-repeat-backward           "C-r" "r" "C-M-r" "ESC M-r"
     isearch-exit                      "<enter>" "<return>" "RET"    :exitonly)

    ("undo-only-redo"
     undo-only                         "C-x u" "C-_" "_" "C-/" "/"
     undo-redo                         "C-?" "?" "r")

    ;; Repeat Maps for Org-Mode
    ("org-nav"
     org-backward-heading-same-level   "C-c C-b" "C-b" "b"
     org-forward-heading-same-level    "C-c C-f" "C-f" "f"
     org-previous-visible-heading      "C-c C-p" "C-p" "p"
     org-next-visible-heading          "C-c C-n" "C-n" "n"
     outline-up-heading                "C-c C-u" "C-u" "u")

    ("org-editing"
     org-metadown                      "M-<down>" "<down>"
     org-metaup                        "M-<up>" "<up>"
     org-demote-subtree                "C->" ">"
     org-promote-subtree               "C-<" "<")

    ("org-task"
     org-todo                          "C-c C-t" "C-t" "t"
     org-priority                      "C-c ," ","
     org-time-stamp                    "C-c ." "."
     org-schedule                      "C-c C-s" "C-s" "s"
     org-deadline                      "C-c C-d" "C-d" "d")
    
    ("word-nav"
     backward-word                     "M-b" "b"
     forward-word                      "M-f" "f"))
  
  "List of lists containing repeater-map definitions.

This must be in the form required by the
‘repeaters-define-repmaps’ function.")

(provide 'repeaters)
;;; repeaters.el ends here
