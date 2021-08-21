# repeaters
This package requires Emacs 28, which is still in development but can
be compiled from the [official git
sources](http://savannah.gnu.org/git/?group=emacs) or the [mirror repo
on GitHub](https://github.com/emacs-mirror/emacs).

## Objective
Easily define multiple repeat-maps in Emacs and associate them with
commands.

This package provides two things:
* a convenient function for defining multiple repeat-maps for Emacs’s
  new ‘repeat-mode’, and
* a set of small pre-defined repeat-maps for commands that might be
  called repeatedly.

By using ‘repeat-mode’ this way we can reduce the need to hold down
modifier keys when entering commands.  Hopefully this will be more
seamless and in keeping with Emacs conventions than other modal
editing options.

## Installation
To use, place repeaters.el within your load-path, and add something
like the following to your configuration:

```emacs-lisp
(require 'repeaters)
(repeaters-define-repmaps repeaters-repmaps)
(setq repeat-exit-key "g"
      repeat-exit-timeout 30)
(repeat-mode)
```

## Use
To define your own repeat maps, you could redefine any of the maps
defined in ‘repeaters.el’.  Or you could start from scratch.

To define or re-define repeat-maps, do something like this:

```emacs-lisp
(require 'repeaters)
(repeaters-define-repmaps
 '(;; Yank same text repeatedly with “C-y y y y”...
   ("yank-only"
    yank                              "C-y" "y"
    yank-pop                          "M-y" "n"                     :exitonly)

   ;; Cycle through the kill-ring with “C-y n n n”...
   ;; You can reverse direction too “C-y n n C-- n n”
   ("yank-popping"
    yank-pop                          "M-y" "y" "n")))
(repeat-mode)
```

The ‘repeaters-define-repmaps’ function takes a single argument, which
is a list of repeat-map definitions.

Each definition contains the following items:

- NAME is a string designating the unique portion of the
repeat-map’s name (to be constructed into the form
‘repeaters-NAME-rep-map’ as the name of the symbol for the map).

- One or more command ENTRIES made up of the following:

  * The COMMAND’s symbol;
  * One or more string representations of KEY-SEQUENCES which may be
      used to invoke the command when the ‘repeat-map’ is active;
  * Optionally, the KEYWORD ‘:exitonly’ may follow the key sequences.

A single map definition may include any number of these command entry
constructs.

If a command construct ends with the ‘:exitonly’ keyword, the map can
invoke the command, but the command will *not* invoke that map.

However, if the keyword is omitted, the command will bring up the
‘repeat-map’ whenever it is called using one of the keysequences given
in the ‘repeat-map’.  A given command may only store a single map
within its ‘repeat-map’ property.  But a command may be found in more
than one repeat-map.

This means that you can place related groups of commands into
different repeat-maps.  And you can jump from one repeat-map to
another depending on the command called.  The ‘yank-only’ and
‘yank-popping’ definitions shown above demonstrate the idea.

One benefit of this is that you can usually avoid having to explicitly
exit the map, because only a few keys have been remapped.  As soon as
you press a key which isn’t found in the current repeat-map, the
repeat-map goes away, and you can insert text freely.

If you prefer a style of editing which is more like
[evil-mode](https://github.com/emacs-evil/evil) or
[god-mode](https://github.com/emacsorphanage/god-mode), you could
create one or more *comprehensive* ‘repeat-map’ definitions, placing
most or all of the available keys into a single map.  This would be a
“command-mode” of sorts.  But then you would always need to explicitly
exit this ‘large-repeat-map-command-mode’ (by pressing the
‘repeat-exit-key’) before entering text.
