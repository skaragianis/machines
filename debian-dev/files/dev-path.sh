# Managed by ansible (debian-dev/tasks/bash_path.yml) — edits here are
# overwritten on the next provisioning run.
#
# dev's interactive shell is fish, which gets its PATH from chezmoi's
# conf.d/path.fish. Bash never reads that, so tools installed outside the
# default PATH are invisible to anything driving the box through bash — codex
# runs its commands as `bash -lc ...`, a login shell, which is why this lives in
# /etc/profile.d rather than ~/.bashrc: Debian's .bashrc returns early for
# non-interactive shells and would never run.
#
# Entries mirror what this repo installs outside the default PATH:
#   $PNPM_HOME, $PNPM_HOME/bin  pnpm itself and its global CLIs (tasks/node.yml)
#   ~/.cargo/bin                rustup/cargo, installed --no-modify-path
#   ~/.local/bin                uv and its tool shims (tasks/python_tools.yml)
#   ~/go/bin                    binaries from `go install`
#   /usr/local/go/bin           the Go toolchain (go/gofmt are also symlinked
#                               into /usr/local/bin, so this is belt-and-braces)
#
# Paths are $HOME-relative rather than hardcoded to dev, so this stays correct
# for whichever user logs in. The case guard makes re-sourcing idempotent —
# without it, nested login shells would stack duplicate entries onto PATH.
export PNPM_HOME="$HOME/.local/share/pnpm"

for _dev_path_dir in \
    "$PNPM_HOME" \
    "$PNPM_HOME/bin" \
    "$HOME/.cargo/bin" \
    "$HOME/.local/bin" \
    "$HOME/go/bin" \
    /usr/local/go/bin
do
    case ":$PATH:" in
        *":$_dev_path_dir:"*) ;;
        *) PATH="$_dev_path_dir:$PATH" ;;
    esac
done
unset _dev_path_dir

export PATH
