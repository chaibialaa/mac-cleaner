# mac-cleaner

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
mac-cleaner caches       # clean app caches, logs, Xcode DerivedData, npm and Composer caches
```

- Uninstalled apps and large files go to the **Trash**, so you can put them back.
- Only emptying the Trash and cleaning caches delete files for good, and both ask first.
- Apple system apps are never uninstalled.
- The interface follows your system language (English or French). Force it with `MAC_CLEANER_LANG=en` or `fr`.
- `NO_COLOR=1` disables colors and animations.

Grant **Full Disk Access** to your terminal (System Settings › Privacy & Security) for accurate Trash sizes and leftover detection.

---

## Français

Un petit nettoyeur macOS pour le terminal : libérer la RAM, vider la corbeille, désinstaller une app avec ses fichiers, trouver les gros fichiers, nettoyer les caches. Installation : `brew install chaibialaa/tap/mac-cleaner`, puis `mac-cleaner`.

## License

MIT
