#!/bin/zsh
setopt null_glob

ROOT=${0:A:h:h}
BIN=$ROOT/mac-cleaner
PTY=$ROOT/tests/terminal.py
pass=0 fail=0

check() {
  local name=$1; shift
  if "$@"; then (( pass++ )); print "ok    $name"
  else (( fail++ )); print "FAIL  $name"; fi
}

setup() {
  SANDBOX=$(mktemp -d)
  export HOME=$SANDBOX/home MAC_CLEANER_TRASH_DIR=$SANDBOX/trash MAC_CLEANER_LANG=fr MAC_CLEANER_TEST=1
  export MAC_CLEANER_SKIP="brew docker" MAC_CLEANER_PROJECTS=$SANDBOX/home/code
  unset XDG_STATE_HOME NO_COLOR
  mkdir -p $HOME $MAC_CLEANER_TRASH_DIR
  HIST=$HOME/.local/state/mac-cleaner/history.tsv
}

teardown() { rm -rf $SANDBOX }

mkcaches() {
  mkdir -p $HOME/Library/Caches/com.test.app $HOME/Library/Logs $HOME/.npm/_cacache/x
  head -c 200000 /dev/urandom > $HOME/Library/Caches/com.test.app/blob
  print log > $HOME/Library/Logs/test.log
  print npm > $HOME/.npm/_cacache/x/entry
}

mkproject() {
  mkdir -p $HOME/code/$1/node_modules/dep
  print '{}' > $HOME/code/$1/package.json
  head -c 50000 /dev/urandom > $HOME/code/$1/node_modules/dep/index.js
  [[ $2 == old ]] && touch -t 202001010000 $HOME/code/$1/package.json
}

mkapp() {
  mkdir -p "$HOME/Applications/$1.app/Contents"
  /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string $2" "$HOME/Applications/$1.app/Contents/Info.plist" >/dev/null
}

empty_dir() { [[ -d $1 && -z $(ls -A $1) ]] }

print "== mac-cleaner tests"

check "syntaxe zsh" zsh -n $BIN

setup
VER=$(awk -F= '/^VERSION=/{print $2}' $BIN)
check "--version" eval '[[ $($BIN --version) == "mac-cleaner $VER" ]]'
check "--help FR" eval '$BIN --help | grep -q "Usage :"'
check "--help EN" eval 'MAC_CLEANER_LANG=en $BIN --help | grep -q "Usage:"'
check "commande inconnue -> code 1" eval '! $BIN nimportequoi >/dev/null'
teardown

setup; mkcaches
out=$(print 't' | $BIN caches --dry-run)
check "caches --dry-run ne supprime rien" eval '[[ -f $HOME/Library/Caches/com.test.app/blob && -f $HOME/.npm/_cacache/x/entry ]]'
check "caches --dry-run affiche l'aperçu" eval '[[ $out == *"[aperçu]"* ]]'
check "caches --dry-run n'écrit pas l'historique" eval '[[ ! -e $HIST ]]'
print 't' | $BIN caches >/dev/null
check "caches vide les dossiers" eval 'empty_dir $HOME/Library/Caches && empty_dir $HOME/Library/Logs && empty_dir $HOME/.npm/_cacache'
check "caches garde les dossiers eux-mêmes" eval '[[ -d $HOME/Library/Caches && -d $HOME/.npm/_cacache ]]'
check "caches écrit l'historique" eval 'grep -q "	m5	" $HIST'
teardown

setup; mkproject ancien old; mkproject actif new
print 't' | $BIN caches >/dev/null
check "node_modules inactif supprimé" eval '[[ ! -e $HOME/code/ancien/node_modules ]]'
check "node_modules actif gardé" eval '[[ -d $HOME/code/actif/node_modules ]]'
check "package.json jamais touché" eval '[[ -f $HOME/code/ancien/package.json ]]'
teardown

setup; mkcaches; print x > $MAC_CLEANER_TRASH_DIR/vieux.txt
$BIN auto --dry-run >/dev/null
check "auto --dry-run ne supprime rien" eval '[[ -f $HOME/Library/Caches/com.test.app/blob && -f $MAC_CLEANER_TRASH_DIR/vieux.txt ]]'
$BIN auto --yes >/dev/null
check "auto --yes vide caches et corbeille" eval 'empty_dir $HOME/Library/Caches && empty_dir $MAC_CLEANER_TRASH_DIR'
check "auto écrit l'historique" eval 'grep -q "	m9	" $HIST'
teardown

setup
mkapp ZzMcTestApp com.test.zzmc
mkdir -p "$HOME/Library/Application Support/ZzMcTestApp" $HOME/Library/Preferences
print x > $HOME/Library/Preferences/com.test.zzmc.plist
print x > $HOME/Library/Preferences/com.test.zzmc.helper.plist
print x > $HOME/Library/Preferences/com.test.zzmcother.plist
printf 'ZzMcTestApp\n1\no\n' | $BIN uninstall >/dev/null
check "désinstallation : app à la corbeille" eval '[[ -d $MAC_CLEANER_TRASH_DIR/ZzMcTestApp.app && ! -e $HOME/Applications/ZzMcTestApp.app ]]'
check "désinstallation : fichiers liés à la corbeille" eval '[[ -f $MAC_CLEANER_TRASH_DIR/com.test.zzmc.plist && -f $MAC_CLEANER_TRASH_DIR/com.test.zzmc.helper.plist && -d "$MAC_CLEANER_TRASH_DIR/ZzMcTestApp" ]]'
check "désinstallation : app voisine épargnée" eval '[[ -f $HOME/Library/Preferences/com.test.zzmcother.plist ]]'
teardown

setup
mkfile -n 3m $HOME/gros.bin; mkfile -n 1m $HOME/petit.bin
printf '2\n1\no\n' | $BIN large >/dev/null
check "gros fichiers : le gros part" eval '[[ -e $MAC_CLEANER_TRASH_DIR/gros.bin && ! -e $HOME/gros.bin ]]'
check "gros fichiers : le petit reste" eval '[[ -e $HOME/petit.bin ]]'
teardown

setup
mkdir -p $HOME/Downloads; print a > $HOME/Downloads/vieux.dmg; print b > $HOME/Downloads/recent.txt
touch -t 202001010000 $HOME/Downloads/vieux.dmg
printf '90\nt\no\n' | $BIN downloads >/dev/null
check "téléchargements : le vieux part" eval '[[ -e $MAC_CLEANER_TRASH_DIR/vieux.dmg ]]'
check "téléchargements : le récent reste" eval '[[ -e $HOME/Downloads/recent.txt ]]'
teardown

setup
mkdir -p $HOME/docs/sub
head -c 2200000 /dev/urandom > $HOME/docs/a.bin
cp $HOME/docs/a.bin $HOME/docs/sub/b.bin; touch $HOME/docs/sub/b.bin
head -c 2200000 /dev/urandom > $HOME/docs/c.bin
printf '\n1\nt\no\n' | $BIN duplicates >/dev/null
check "doublons : la copie part" eval '[[ -e $MAC_CLEANER_TRASH_DIR/b.bin && ! -e $HOME/docs/sub/b.bin ]]'
check "doublons : l'original reste" eval '[[ -e $HOME/docs/a.bin ]]'
check "doublons : le fichier de même taille mais différent reste" eval '[[ -e $HOME/docs/c.bin ]]'
teardown

setup
mkdir -p $HOME/Library/LaunchAgents
/usr/libexec/PlistBuddy -c 'Add :Label string com.test.zzagent' $HOME/Library/LaunchAgents/com.test.zzagent.plist >/dev/null
out=$(printf '1\no\n' | $BIN startup)
check "démarrage : agent listé" eval '[[ $out == *com.test.zzagent* ]]'
check "démarrage : agent désactivé" eval '[[ -e $MAC_CLEANER_TRASH_DIR/com.test.zzagent.plist && ! -e $HOME/Library/LaunchAgents/com.test.zzagent.plist ]]'
teardown

setup; mkcaches
print 't' | $BIN caches >/dev/null
out=$($BIN history)
check "historique : affiche le total" eval '[[ $out == *"Libéré au total"* ]]'
out=$(MAC_CLEANER_LANG=en $BIN history)
check "historique : en anglais" eval '[[ $out == *"Freed in total"* && $out == *"Clean caches"* ]]'
teardown

if (( $+commands[python3] )); then
  setup; mkcaches
  out=$(python3 -I $PTY $BIN -- 5 't\r' x q)
  check "terminal : touche du menu sans Entrée" eval '[[ $out == *"Caches et fichiers temporaires"* ]]'
  check "terminal : animation de fin sans erreur" eval '[[ $out == *"★ ✦ ⋆"* && $out != *"invalid"* && $out != *"bad "* ]]'
  check "terminal : nettoyage fait" eval 'empty_dir $HOME/Library/Caches'
  check "terminal : retour menu puis q" eval '[[ $out == *"À bientôt."* ]]'
  out=$(python3 -I $PTY $BIN ram -- 'n\r')
  check "terminal : la question RAM accepte une réponse" eval '[[ $out == *"(o/N) › n"* && $out != *"invalid"* ]]'
  teardown
fi

print "\n$pass ok, $fail échec(s)"
(( fail == 0 ))
