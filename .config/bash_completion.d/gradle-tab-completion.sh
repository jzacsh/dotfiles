__haveFileInAncestor() {
  local d=./
  while [ "$d" != '/' ] && [ ! -f "$d"/"$1" ]; do
    d="$(readlink -f "$d"/../)"
  done
  [ -f "$d"/"$1" ]
}
__scrapeMd5HashOfStdin() { md5sum | sed -e 's| .*$||g'; }

_gradleCompletion() {
  local commands cur="${COMP_WORDS[COMP_CWORD]}"

  local gradle_cmd='gradle'
  # Allow local gradle wrappers to override installed `gradle`
  [ -x ./gradlew ] && gradle_cmd='./gradlew'
  [ -x ../gradlew ] && gradle_cmd='../gradlew'
  {
    type -p "$gradle_cmd" >/dev/null 2>&1 &&
      __haveFileInAncestor build.gradle
  } || return 0

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

  local gradle_files_checksum
  if [ -f build.gradle ]; then
    # If we have a gradle file, then we're really autocomplete-ing for *all*
    # gradle tasks, recursively. Let's determine if the state of gradle tasks
    # beneath us has changed since last check
    gradle_files_checksum="$(
      find . -name build.gradle |
        xargs md5sum |
        __scrapeMd5HashOfStdin
    )"
  else
    gradle_files_checksum="no_local_build.gradle_$(
      stat \
        --printf '%n\n%i\n' \
        "$(readlink -f "$(pwd)")" |
      __scrapeMd5HashOfStdin
    )"
  fi

  local command_cache="$cache_dir"/"$gradle_files_checksum"
  if [[ ! -f "$command_cache" ]]; then # not cached! boo-urns!
    printf '\nWARNING: building cache of Gradle tasks... :( ' >&2

    local tasksOutput
    tasksOutput="$("$gradle_cmd" --console=plain --quiet tasks)"
    if [ -z "tasksOutput" ] | [ $? -ne 0 ];then
      printf \
        ' bash tab completion fail\n\tsomething wrong with gradle: `%s`\n%s' \
        "$gradle_cmd" "$COMP_LINE" >&2
      return 1
    fi

    commands="$(
      printf '%s\n' "$tasksOutput" |
        \grep '^\w*\ -\ ' |
        awk '{print $1}' |
        tr '\n' ' '
    )"

    [[ -n "$commands" ]] && echo "$commands" > "$command_cache"

    # TODO: why doesn't first `tab` (ie: cache-miss) generate output from
    # bash-completion. Fix, then delete this hack:
    #printf '%s\n' $commands | column
    printf '.. done! :)\n%s' "$COMP_LINE" >&2
  fi
  [[ ! -f "$command_cache" ]] && return 0 # no tasks

  commands="$(< "$command_cache")"

  # Bash completion API:
  COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
}

complete -F _gradleCompletion -- gradle
complete -F _gradleCompletion -- gradlew
complete -F _gradleCompletion -- ./gradlew
