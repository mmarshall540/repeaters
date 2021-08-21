# repeaters
Easily define multiple repeat-maps in Emacs and associate them with commands.

This package is a proof-of-concept.  It provides a function for
easily defining multiple repeat-maps and associating them with
commands.  It also provides a default set of repeat-maps to
reduce the need for modifier keys when entering commands.

Repeat maps are a feature of Emacs 28, which this package requires.

To use, you can place this file within your load-path, and add
something like the following to your configuration:

(require 'repeaters)
(repeaters-define-repmaps repeaters-repmaps)
(setq repeat-exit-key "g"
      repeat-exit-timeout 30)
(repeat-mode)
