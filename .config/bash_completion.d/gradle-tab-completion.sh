thiscript="$(readlink -f "$0")"
_gradle() {
  set -e

  local cur=${COMP_WORDS[COMP_CWORD]}
  local gradle_cmd='gradle'

  if [ -x ./gradlew ]; then gradle_cmd='./gradlew';fi

  if [ -x ../gradlew ];then gradle_cmd='../gradlew';fi

  local commands=''
  local cache_dir="${TMPDIR:-/tmp}/gradle_tabcompletion"
  mkdir -p "$cache_dir"
  printf \
    'Cache of bash-completion data, built by `%s` in script:\n\t%s\n' \
    "$FUNCNAME" "$thiscript" > README

  # TODO: include the gradle version in the checksum?  It's kinda slow
  #local gradle_version=$($gradle_cmd --version --quiet --no-color | grep '^Gradle ' | sed 's/Gradle //g')
  
  local gradle_files_checksum='';
  if [[ -f build.gradle ]]; then # top-level gradle file
      gradle_files_checksum=($(find . -name build.gradle | xargs md5sum | md5sum))
  else # no top-level gradle file
    gradle_files_checksum='no_gradle_files'
  fi

  if [[ -f "$cache_dir/$gradle_files_checksum" ]]; then # cached! yay!
    commands=$(cat $cache_dir/$gradle_files_checksum)
  else # not cached! boo-urns!
    commands=$($gradle_cmd --no-color --quiet tasks | grep ' - ' | awk '{print $1}' | tr '\n' ' ')
    if [[ -n "$commands" ]]; then
      echo "$commands" > "$cache_dir"/"$gradle_files_checksum"
    fi
  fi
  COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
}
unset thiscript # hack to keep track of messes i make

complete -F _gradle gradle
complete -F _gradle gradlew
complete -F _gradle ./gradlew
