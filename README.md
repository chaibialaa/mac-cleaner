# mac-cleaner

[![tests](https://github.com/chaibialaa/mac-cleaner/actions/workflows/tests.yml/badge.svg)](https://github.com/chaibialaa/mac-cleaner/actions/workflows/tests.yml)

A tiny, dependency-free macOS cleaner for the terminal. One zsh script, no daemon, no telemetry.

```
     ┌┬┐┌─┐┌─┐   ┌─┐┬  ┌─┐┌─┐┌┐┌┌─┐┬─┐
     │││├─┤│  ───│  │  ├┤ ├─┤│││├┤ ├┬┘
     ┴ ┴┴ ┴└─┘   └─┘┴─┘└─┘┴ ┴┘└┘└─┘┴└─
```

## Install

```sh
brew install chaibialaa/tap/mac-cleaner
```

## Usage

```sh
mac-cleaner              # interactive menu
mac-cleaner ram          # free inactive memory (sudo purge)
mac-cleaner trash        # empty the Trash
mac-cleaner uninstall    # remove an app and its leftovers in ~/Library
mac-cleaner large        # find large files in your home folder
mac-cleaner caches       # app caches, logs, Xcode, npm, Composer, Gradle, Homebrew, Docker, idle node_modules
mac-cleaner downloads    # old files in ~/Downloads
mac-cleaner startup      # login items, launch agents and daemons, and disable them
mac-cleaner duplicates   # identical files (same content), keeps the oldest copy
mac-cleaner auto         # everything safe in one pass: caches, logs, dev caches, Homebrew, Trash
mac-cleaner history      # what was freed, and when
```

Options, for any command:

```sh
--dry-run, -n   # preview what would be done, delete nothing
--yes, -y       # do not ask for confirmation (e.g. `mac-cleaner auto --yes` in a weekly job)
```

- Uninstalled apps, large files, old downloads, duplicates and startup items go to the **Trash**, so you can put them back.
- Only emptying the Trash and cleaning caches delete files for good, and both ask first.
- Docker and `node_modules` are listed in `caches` but left out of `auto`. Docker volumes are never touched.
- `node_modules` folders are scanned in your home folder. Point to other folders with `MAC_CLEANER_PROJECTS="$HOME:/path/to/projects"`. A project counts as idle when none of its files changed in 90 days.
- Skip some cache entries with `MAC_CLEANER_SKIP="brew docker"`.
- Apple system apps are never uninstalled.
- The interface follows your system language (English or French). Force it with `MAC_CLEANER_LANG=en` or `fr`.
- `NO_COLOR=1` disables colors and animations.

History is kept in `~/.local/state/mac-cleaner/history.tsv`.

Grant **Full Disk Access** to your terminal (System Settings › Privacy & Security) for accurate Trash sizes and leftover detection.

---

## Français

Un petit nettoyeur macOS pour le terminal : libérer la RAM, vider la corbeille, désinstaller une app avec ses fichiers, trouver les gros fichiers, les vieux téléchargements et les doublons, nettoyer les caches (y compris Xcode, Gradle, Homebrew, Docker, node_modules), gérer ce qui se lance au démarrage, tout nettoyer d'un coup avec `mac-cleaner auto`, et voir l'historique. `--dry-run` montre ce qui serait fait sans rien supprimer. Installation : `brew install chaibialaa/tap/mac-cleaner`, puis `mac-cleaner`.

## Tests

```sh
zsh tests/run.zsh
```

Each test runs in a throwaway home folder with its own Trash, so nothing on your Mac is touched.

## License

MIT
