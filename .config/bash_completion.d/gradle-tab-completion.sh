_gradle() {
  local commands

  local gradle_cmd='gradle'
  # Allow local gradle wrappers to override installed `gradle`
  [ -x ./gradlew ] && gradle_cmd='./gradlew'
  [ -x ../gradlew ] && gradle_cmd='../gradlew'

  local cache_dir="${TMPDIR:-/tmp}/gradle_tabcompletion_cache"
  mkdir -p "$cache_dir" || {
    printf \
      'Fatal: "%s" bash-completion failed building caching dir:\n\t%s\n' \
      "$FUNCNAME" "$cache_dir" >&2
    return 1
  }
  printf \
    "Cache of bash-completion data, built by %s's '%s' shell function" \
    "$(whoami)" "$FUNCNAME" > "$cache_dir"/README

  # TODO: include the gradle version in the checksum?  It's kinda slow
  #local gradle_version=$($gradle_cmd --version --quiet --no-color | grep '^Gradle ' | sed 's/Gradle //g')
  
  local gradle_files_checksum='no_gradle_files'
  if [ -f build.gradle ]; then
    # If we have a gradle file, then we're really autocomplete-ing for *all*
    # gradle tasks, recursively. Let's determine if the state of gradle tasks
    # beneath us has changed since last check
    gradle_files_checksum="$(
      find . -name build.gradle |
        xargs md5sum |
        md5sum |
        sed -e 's| .*$||g'
    )"
  fi

  local command_cache="$cache_dir"/"$gradle_files_checksum"
  if [[ -f "$command_cache" ]]; then # cached! yay!
    commands=$(< "$command_cache")
  else # not cached! boo-urns!
    local tasksOutput
    tasksOutput="$("$gradle_cmd" --console=plain --quiet tasks)"
    if [ -z "tasksOutput" ] | [ $? -ne 0 ];then
      printf \
        '\nbash tab completion fail; something wrong with gradle:\n\t%s\n' \
        "$gradle_cmd" >&2
      return 1
    fi

    commands=$(
      echo "$tasksOutput"
        grep ' - ' |
        awk '{print $1}' |
        tr '\n' ' '
    )

    [[ -n "$commands" ]] && echo $commands > "$command_cache"
  fi
  COMPREPLY=( $(compgen -W "$commands" -- "${COMP_WORDS[COMP_CWORD]}") )
}

complete -F _gradle gradle
complete -F _gradle gradlew
complete -F _gradle ./gradlew
