# debian-dev

Provisions a fresh Debian machine as a dev server. Run from the Mac.

## Manual prerequisites

1. **Create the machine**: install Debian Trixie, set a strong root password, create a `dev` user with a normal password, and install the SSH server.
2. **Machine IP**: note the IP address of the machine. You'll be prompted for this when you run the playbook (or pass it with
   `-e machine_ip=<ip>` to skip the prompt).

## Control-node (Mac) prerequisites

- `ansible` (installed via the repo Brewfile).
- `sshpass` for the first password-based run: `brew install sshpass`.
- `~/.ssh/id_ed25519.pub` present (installed into dev's authorized_keys).
- Ghostty installed (provides the `xterm-ghostty` terminfo for `infocmp`).
- Install collections once: `ansible-galaxy collection install -r requirements.yml`.

## First run (password bootstrap)

```bash
cd debian-dev
ansible-playbook site.yml --ask-pass -e machine_ip=192.168.65.10
```

After bootstrap, SSH password auth is disabled (key-only) and `dev` is a sudoer.

## Re-runs (key auth)

```bash
cd debian-dev
ansible-playbook provision.yml
```

Prompts only for `dev`'s sudo password. Idempotent — safe to run repeatedly.

## Post-run manual steps

1. Add the printed GitHub public key at <https://github.com/settings/keys>.
2. If the chezmoi init/apply task failed because that key wasn't on GitHub yet, re-run `provision.yml` once it's added.
3. (Optional) In VS Code install **Open Remote - SSH** and connect to the host.

## Dotfiles

Dotfiles are managed with [chezmoi](https://www.chezmoi.io/), sourced from
`git@github.com:skaragianis/dotfiles.git` (see `dotfiles_repo` in
`group_vars/debian_dev.yml`) and applied automatically during provisioning.

## Usage

```bash
ssh dev@<machine-ip>
tmux new -s <project-name>
```
