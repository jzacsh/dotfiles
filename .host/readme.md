# Script Forest
Allows for machine and OS-specific dotfiles and environment scripts.

This is an _organizational_ solution to a very specific problem: using the same
exact dotfiles repo for every machine I have an account on, but wanting
specific shell functions and dotfiles configured per-machine or per-distro.

## Forest Entry
Run [`pick`](pick) script from interactive or non-interactive shell start-up _(I use
`~/.bashrc`)_, causing the following under `$HOME/.host/*`:
+ **distro**-specific scripts to trigger, prefixed with "distro." (eg: [`distro.ubuntu`](distro.ubuntu))
+ **host**-specific scripts to trigger, prefixed with "host." (eg: [`host.jznuc`](host.jznuc))

Note: Directories in this tree are arbitrary structures various scripts make
use of and expect to find. There is no logic in `pick` that is aware of
directories.

### Diagram of Execution on Arch Linux
```
  +--------------------+      +-----------------------------------+
  | bashrc calls `pick`| -->  | `pick` runs distro and host files |
  +--------------------+      +-----------------------------------+
                                               |
                                               |
                                   +------------------------+        
                                   | `$ source distro.arch` |
                                   +------------------------+
                                               |
                                               |
                                  +--------------------------+        
                                  | `$ source host.blackbox` |
                                  +--------------------------+
```
