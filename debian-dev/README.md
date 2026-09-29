# debian-dev

Provisions a fresh Debian machine as a dev server. Run from the Mac.

## Manual prerequisites

1. **Create the machine**: install Debian Trixie, set a strong root password, create a `dev` user with a normal password, and install the SSH server.
2. **Machine IP**: note the IP address of the machine. You'll be prompted for this when you run the playbook (or pass it with
   `-e machine_ip=<ip>` to skip the prompt).

## Control-node (Mac) prerequisites

- `ansible` (installed via the repo Brewfile).
- `sshpass` for the first password-based run: `brew install sshpass`.
- The Mac's public key listed in `dev_authorized_keys` (see [SSH access](#ssh-access)).
- Ghostty installed (provides the `xterm-ghostty` terminfo for `infocmp`).
- Install collections once: `ansible-galaxy collection install -r requirements.yml`.

## First run (password bootstrap)

```bash
cd debian-dev
ansible-playbook site.yml --ask-pass -e machine_ip=<machine_ip>
```

After bootstrap, SSH password auth is disabled (key-only) and `dev` is a sudoer. You *MUST* copy the new public key over to github before running again to complete the installation.

## Re-runs (key auth)

```bash
cd debian-dev
ansible-playbook provision.yml
```

Prompts only for `dev`'s sudo password. Idempotent — safe to run repeatedly.

## Post-run manual steps

1. Add the printed GitHub public key at <https://github.com/settings/keys>.
2. If the chezmoi init/apply task failed because that key wasn't on GitHub yet, re-run `provision.yml` once it's added.
3. Join the tailnet: `ssh dev@<machine-ip> sudo tailscale up`, then follow the printed auth URL. Provisioning installs and starts Tailscale but never authenticates it — no auth key lives in this repo. Only needed once; re-runs leave the existing login alone.
4. Accept the Syncthing device on your other devices — see [Syncthing](#syncthing).
5. (Optional) In VS Code install **Open Remote - SSH** and connect to the host.

## SSH access

`dev_authorized_keys` in `group_vars/debian_dev/main.yml` lists every public key that
may log in as `dev`. It is installed with `exclusive: true`, so it is the single
source of truth — a key that isn't in the list is removed from the host on the
next run, and hand-editing `authorized_keys` on the machine won't survive.

To grant another machine (e.g. the Ubuntu laptop) SSH access:

1. On that machine, print its public key (`cat ~/.ssh/id_ed25519.pub`; run
   `ssh-keygen -t ed25519` first if it has none).
2. Add that line to `dev_authorized_keys`.
3. Re-run `provision.yml` **from a machine that already has access** — password
   auth is off, so a new machine cannot grant itself entry.

The new machine only needs an SSH client; it doesn't need Ansible. Playbooks are
still run from the Mac.

## Syncthing

Syncthing runs as `dev` and shares the Sync folder (folder ID `default`,
`~/Sync`) with the devices in `syncthing_peers` (`group_vars/debian_dev/main.yml`).
Its ignore patterns (`!/Todo`, then `*`) mean **only `~/Sync/Todo`** is ever
downloaded or sent. The other devices still send the server the list of files in
the whole folder (names, sizes, dates), but no file contents. The ignore file is
written before the folder is added and re-applied on every run.

Any other folder or device in the server's config is deleted on every run.
The server never accepts folders automatically, and no device can introduce
others to it. Peers are dialled at tailnet addresses. Global discovery, relays,
NAT traversal and LAN discovery are off, and the firewall only admits tailnet
traffic. The device key and API key are generated on the host and never leave it.

The GUI listens on loopback only. To open it, tunnel:
`ssh -L 8385:127.0.0.1:8384 dev@<host>`, then browse to <http://127.0.0.1:8385>.

Nothing changes on the other devices beyond accepting the server. On each peer,
add the server's device ID (printed at the end of the run) with address
`tcp://<server-tailnet-ip>:22000`, then share the Sync folder with it.

To add a peer, add its ID and tailnet address to `syncthing_peers` and re-run.

## Dotfiles

Dotfiles are managed with [chezmoi](https://www.chezmoi.io/), sourced from
`git@github.com:skaragianis/dotfiles.git` (see `dotfiles_repo` in
`group_vars/debian_dev/main.yml`) and applied automatically during provisioning.

## Usage

```bash
ssh dev@<machine-ip>
tmux new -s <project-name>
```
