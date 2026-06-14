# The Unified Workspace

## This project

- Builds a tiny image with:
    - The utilities, compilers, interpreters, and package managers I use. 
    - My bash, tmux, and neovim configs.
    - Git, podman, and OpenSSH
    - A single admin user with passwordless sudo
    - SSH login access to that user for any with any public key in `authorized_keys`
- Starts a container that:
    - Mounts the host user's ssh keys
    - Mounts the host user's `~/projects` folder
    - Publishes its SSH port on the host at `:22222`

This environment lives on my homeserver and is used as a single workspace that can be accessed by my household's many clients. It offers a declarative, atomic environment that unites each of my devices into one tmux session and one set of git worktree states. 

## Deploy

### Requirements

To deploy the unified workspace you will need a relatively modern x86 Linux host with:
 - Sudo
 - Podman
 - Static network address (_I recommend a DHCP entry, NetBIOS name, or local DNS entry - avoid exposing this to the internet as it mounts its host's user's private key_)

### Steps

On your intended host:

1. `git clone https://github.com/TadghW/worktop-container.git`
2. `cd worktop-container`
3. `git submodule update --init --recursive` (see "Customise!" if you don't want my config)
4.  Set the `USER`, `USER_GIT_EMAIL`, and `USER_GIT_NAME` `ARG`s at the top of `Dockerfile`
5.  Populate `authorized_keys` with the public ssh keys of the client devices you intend to access the space with
6.  Replace the network address in `start-worktop.sh` and `refresh-worktop.sh` with the address you intend to use
7.  Run `build-worktop-image.sh` and `start-worktop.sh` - (or one-shot it with `refresh-worktop.sh`!)

## Customise!

To customise the workspace:

- `Dockerfile` exposes the arguments: `UID`, `GID`, `USER`, `GROUP`, `USER_GIT_EMAIL`, `USER_GIT_NAME`, `USER_GIT_DEFAULT_BRANCH`
- Make sure you have all of the packages you want on the apk install list in at the top of the `Dockerfile`
- Replace my `dotfiles` submodule with your own dotfiles
- Remove the `ohmyposh` and `catppuccin-tmux` install lines (unless you want them)
- Replace my `.bashrc` and `.bash_profile` installs with whatever shell you prefer

## The Default Configuration

If you want to use the default configuration (my config):


- I recommend using [Rio](https://rioterm.com/) as your terminal emulator - it's very cross-platform and easy to configure. You can see my Rio config in `dotfiles/rio/`.
- Remember to find and apply a theme to your terminal emulator for maximum eye-comfort :)
- You'll be launched automatically into a `tmux` session when you log in. This behaviour is configured in `dotfiles/.bashrc-auto-tmux`, which is renamed to `.bashrc` on installation, and sourced by `.bash_profile` when you log in to the container. To use my `tmux` config:
  1. Prefix is `Ctrl + A`
  2. `Prefix + -` for vertical split `Prefix + |` for horizontal. 
  3. `Prefix + Arrow keys` to resize a pane
  4. `Prefix + ` `h`, `j`, `k`, and `l` for navigation.
  5. `Prefix + x` to close a pane
  6. `Prefix + c` to create a new window
  7. Close all panes to close a window
  8. `Prefix + n` to move to the next window
  9. `Prefix + p` to move to the previous window
  10. `Prefix + {NUMBER}` to move to a specific window
  11. `Prefix + r` reloads the config.
- My text editor is `nvim` with `lazy-nvim`, `Mason`, `telescope`, `neotree`, and `alpha-nvim`:
  1. Leader is `space`
  2. `Leader + e` to open neotree
  3. `Leader + b` to open neotree on open buffers
  4. `Leader + tab` to swap between windows
  5. `Leader + fs` to search context for strings
  6. `Leader + ff` to search context for files.
  7. Otherwise, stock navigation
- For `nvim` and `ohmyposh` (my shell prompt fancy-ifier) to render properly you'll need to configure your terminal emulator to use an font that has been patched with many nerdy icons - I recommend looking through through nerd-fonts to find one you like. I like `JetbrainsMono`.
- I have no alias other than the one I use to connect to the workspace which is `worktop` - avoid using this from within the workspace as it will nest.

## Notes
- `sshd` is the container entrypoint and `start-worktop.sh` and `refresh-worktop.sh` assume you want port forwarding for easy access - but you can attach with `attach-to-worktop.sh` if you want to run locally
- `sshd` is run with flags `-D -e` and will pipe logs to stderr - if you run into issues accessing the workspace over SSH check the logs from the host with `sudo podman logs worktop-container`
- `start-worktop.sh` and `refresh-worktop.sh` rw mount the host's ~/projects folder because that's where I expect to work, that's not a magic folder just my personal convention
- There's a loop in `start-worktop.sh` and `refresh-worktop.sh` that looks for id_rsa and id_ed25519 keys on the host to ro mount to the container. If you have another key type you want mounted add it to line 8 (`for key in id_ed25519... rsa; do`).

## To-do:
- Workspace currently builds its own SSH host keys at build time. This sucks: each rebuild will change the server identity which trips SSH host key warnings on clients. You can reset the expected host key by clearing your `known_hosts` entry for that host, but a better approach would be the programmatic creation of dedicated persistent host key sets for the container when the user first runs `start-worktop.sh` and `refresh-worktop.sh` and mounting those host keys to the container.
- Arm64 version for Apple Silicon
- Might as well expand the list of key types in `start-worktop.sh` and `refresh-worktop.sh` 
