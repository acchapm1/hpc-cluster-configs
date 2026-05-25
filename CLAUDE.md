# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Dotfiles and shell environment for HPC login/compute nodes (Rocky Linux 9.7 / RHEL-based). The repository is the source of truth; users install it onto a node by cloning it to `~/.dotfiles` and copying files into `$HOME`. There is no application to build or test — changes are validated by re-running the installer.

See `AGENTS.md` for the full style guide (bash strict mode, 2-space indent, `${HOME}` over `~`, logging conventions). It is the authoritative coding-conventions doc for this repo; do not duplicate its contents here.

## Common Commands

`just` is the primary entry point. The `Justfile` and `install.sh` implement the same install flow — keep them in sync when changing either.

```bash
just                  # list recipes
just install          # full install: backup + dotfiles + dirs + vim/tmux plugins + binaries
just sync-from-home   # reverse direction: copy live $HOME dotfiles back into the repo
just git-update "msg" # sync-from-home + add + commit + push (the main editing workflow)
just config           # print resolved DOTFILES_REPO / INSTALL_DIR / BACKUP_DIR
```

Individual install steps (useful when iterating on one piece): `just dotfiles`, `just dirs`, `just vim-plugins`, `just tmux-plugins`, `just binaries`.

Remote install (what end users run): `curl -fsSL https://raw.githubusercontent.com/acchapm1/hpc-cluster-configs/main/install.sh | bash`.

## Architecture Notes That Aren't Obvious From One File

- **Two install paths, one behavior.** `install.sh` is the canonical remote installer (designed for `curl | bash`); the `Justfile` is the local-developer convenience wrapper. Both read the same `DOTFILES` / `DOTDIRS` lists and produce the same result. When adding a new dotfile, update both lists (`DOTFILES=(...)` in `install.sh` and `dotfiles := "..."` in `Justfile`).

- **`install.sh` detects piped vs. local execution.** When piped (`curl | bash`, stdin not a tty), it clones `${DOTFILES_REPO}` to `~/.dotfiles` and installs from there. When run locally (`./install.sh`), it rewrites `INSTALL_DIR` to its own directory and installs from the working copy. The `Justfile` always assumes `~/.dotfiles` — running `just install` from a clone in a different path will install from `~/.dotfiles`, not from where you ran it.

- **Edit-in-place workflow.** The intended editing loop is: edit files in `$HOME` directly → `just sync-from-home` (or `just git-update "msg"`) to pull them back into the repo. Editing files in the repo and then running `just install` also works, but `sync-from-home` is what the Justfile is optimized for.

- **Backups are timestamped per run.** `BACKUP_DIR` is evaluated once at script/Justfile load to `~/.dotfiles_backup/YYYYMMDD_HHMMSS/`. Re-running install creates a new backup dir; backups accumulate until manually cleaned (`just clean-backups` only removes the *current* run's dir).

- **Vendored binaries.** `glow` and `just` ship as committed binaries (the `glow` binary is ~17MB) so HPC nodes without internet egress can still install them. They are installed to `~/.local/bin/`, which the installer warns about if not on `PATH`. Don't replace these with download steps without considering air-gapped nodes.

- **`.tmux/` is a runtime directory, not in the repo.** Only `.tmux.conf` is committed. The `.tmux/plugins/tpm` tree is cloned by `install_tmux_plugins` at install time. The `dotdirs` list in `Justfile`/`install.sh` references `.tmux` because `sync-from-home` copies it back from `$HOME` if it exists locally — be careful that this doesn't pull plugin trees into commits.
