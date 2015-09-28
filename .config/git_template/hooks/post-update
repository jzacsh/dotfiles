#!/usr/bin/env bash
#
# Emits WARNINGs if TODOs are found throughout codebase. Intended as a
# nagging (not blocking) reminder to address my TODOs.
#   man 5 githooks | less +/^\ *post-update
set -e
declare -r currentRoot="$(readlink -f "$PWD")"


findRepoContents() {
  find "$currentRoot" -type f ! -path "$currentRoot"'/.git*'
}

stripGitIgnoredFiles() {
  # if `git` is broken (as usual) in hook execution, use this instead:
  # find ./ -type f ! -path '.git/*' -name '.gitignore' | while read file; do cat "$file";done

  while read file; do
    [ -z "$(git check-ignore "$file")" ] && echo "$file"
  done
}

gitListRepoContents() {
  # if `git` is broken (as usual) in hook execution, use this instead:
  #   findRepoContents | stripGitIgnoredFiles
  git ls-tree --full-tree -r --name-only HEAD
}

scrapeFile() { grep '\bTODO\b' --line-number --with-filename $@; }

cd "$currentRoot"
scrapeFile $(gitListRepoContents) > /dev/null && {
  # from https://github.com/jzacsh/yabashlib/tree/5210e33f2f203070f677f571
  col_red_='\e[1;31m'
  col_end_='\033[0m'  # end cap

   echo -e "\n${col_red_}[WARNING]${col_end_}\t'TODO()'s found ...\n" >&2
}
gitListRepoContents | while read file;do
  scrapeFile "$file" >&2
done
