#!/usr/bin/env bash
#
# Fresh Install: Executable Sanity List
#
# This is a note to myself on which binaries I expect for my sanity.
#
# This list is packaged safely with my dotfiles, so I have a nearby sanity list
# to check when I'm creating a username on a new machine. Usually a new
# username installation looks like this, for me:
set -x

printf 'use https://gist.github.com/jzacsh/838e4a6bde61bb545ba1 instead' >&2
exit 99

(( BASH_VERSINFO[0] < 4 )) &&
    echo 'holy shit, scratch everything else in this checklist...' >&2

cd  # home dir

# system-check: ensure something sensible comes out
git --version || sudo apt-get install git

sudo apt-get install build-essential checkinstall colordiff &&

    # Unpack my bag o scripts:
    git clone http://github.com/jzacsh/bin &&
    mkdir bin/local

    mkdir -p tmp/{build,src} &&
    pushd tmp/build

    curl -O http://hg.gerg.ca/vcprompt/archive/tip.tar.gz &&
    tar -xvf tip.tar.gz

    # system-check: ensure something sensible comes out
    type -p autoconf &&
    pushd vcprompt* &&
    autoconf &&
    ./configure &&
    make &&
    mv -v vcprompt ~/bin/local &&
    popd &&  # vcrompt-*
    popd  # tmp/build

echo 'WARNING: watch this output and delete old versions of these!!'
while read line ; do
  [[ $line =~ ^XDG ]] || continue  # skip; not a DIR configuration

  tmp="${line/XDG*=/}"  # get the config value

  # strip surrounding quotes
  tmp="${tmp%\"}"
  tmp="${tmp#\"}"

  # evaluate the env vars; eg: "$HOME/foo"
  dir="$(eval echo -n "$tmp")"

  mkdir -p "$dir"
done < back/dots/user-dirs.dirs

# Unpack my bag o dots:
mkdir -p back/dots && \
    git clone http://github.com/jzacsh/dotfiles back/dots
for dot in ~/back/dots/.*; do
  f="$(basename "$dot")"
  [[ -e "$f" ]] &&
      printf '\nZOMG dot exists!\t"%s"\n' "$f" >&2 ||
      ln -sv "$dot"
done

# the one set of vim dots I don't carry around:
mkdir ~/.vim/bundle &&
    cd ~/.vim/bundle &&
    git clone https://github.com/scrooloose/syntastic.git

# all below could just as well in ~/bin/local/ (rather than sudo/`-g` global)

# s/apt-get/whatever-package-mgr/
sudo apt-get install tmux irssi htop &&
  # system-check: ensure something sensible comes out
  type -p easy_install &&
  sudo easy_install http://closure-linter.googlecode.com/files/closure_linter-latest.tar.gz

# system-check: ensure something sensible comes out
npm --version &&
  sudo npm install -g jshint PrettyCSS karma phantomjs grunt gulp

# Stuff that can't be public or automated
printf 'Copy from some other machine or backup the following:\n%s\n' \
    '.ssh/config/*' '.aws/config'
