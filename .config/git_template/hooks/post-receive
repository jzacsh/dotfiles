#!/usr/bin/env bash
#
# Clones updated repo to relative mirror in ~/back/src/, assuming:
#   1. repo is a `--bare` git repo in ~/src/
#   2. a regular `clone` of it lives in ~/back/src/ with the same path
#
# For git API utilized in this script, see:
#   man 5 githooks | less +/^\ *post-receive
set -e
declare -r srcsRoot="$(readlink -f ~/src)"
declare -r clonesRoot="$(readlink -f ~/back/src)"

declare -r currentRoot="$(readlink -f "$PWD")"
declare -r repoRelative="${currentRoot/$srcsRoot}"
[ -e "$srcsRoot"/"$repoRelative" ]  # sanity check


gitRmRepoContents() {
  git ls-files --others -i --exclude-standard | while read file; do
    rm -v "$file"  # git is so fng complicated stackoverflow.com/a/15931542
  done
  git clean -d --force -x  # rm untracked files and such
  if [ -n "$(git ls-files)" ]; then
    git rm -rf *
  fi
}

expectedCloneTo="${clonesRoot}${repoRelative}"
# Empty previous contents of backup
if [ -e "$expectedCloneTo" ];then
  { [ "$expectedCloneTo" != '/' ] && [ -n "$expectedCloneTo" ]; } &&
    find "$expectedCloneTo" -mindepth 1 -exec rm --recursive --force {} +;
fi

# Clone a fresh backup of repo
mkdir -p "$expectedCloneTo"
git clone --quiet "$currentRoot" "$expectedCloneTo"
expectedCloneTo="$(readlink -f "$expectedCloneTo")"

git \
  --work-tree="$expectedCloneTo" \
  --git-dir="$currentRoot" \
  checkout --force
(( $? )) && echo 'Failed' || echo 'Done'
