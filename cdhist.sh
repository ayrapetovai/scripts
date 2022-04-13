# This script keeps track on changing directories [cd] while walling through the file system.
# It remembers visited directories and allows to go to previous directory, like 'next' and 'back' buttons
# on a web-browser tab.

# 'Alt+,' - go back, 'Alt+.' - go next. Limit is 40 elements. No history polluting.

# Installation

# This scripts uses HISTIGNORE variable.
# This script needs bash-preexec functionality from this file:
#$ curl https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh
# Source bash-preexec at the end of bash profile (e.g. ~/.bashrc, ~/.profile, or ~/.bash_profile)
#$ echo '[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh' >> ~/.bashrc

# Then
#$ curl https://raw.githubusercontent.com/ayrapetovai/scripts/main/cdhist.sh -o ~/.cdhist.sh
#$ echo '[[ -f ~/.cdhist.sh ]] && source ~/.cdhist.sh' >> ~/.bashrc

export _CDHIST_MAX_SIZE=40
export _CDHIST_SIZE=0
export _CDHIST_PREV=""
export _CDHIST_NEXT=""

__cdhist_preexec() {
  local COMMAND="$1"
  if [[ "$COMMAND" = cd* ]]; then
    local ARGUMNET="${COMMAND##* }" # "abc def" -> "def"
    if [ -d "$ARGUMNET" ] &&
      [ "$ARGUMNET" != "." ] &&
      [ "$ARGUMNET" != "-" ] &&
      # if absolute path of target directory is not current working directory
      [ $(readlink -f "$ARGUMNET") != "$PWD" ] &&
      [ "$PWD" != "${_CDHIST_PREV##*:}" ]; # ":a:b:c" -> "c"
      then
      _CDHIST_SIZE=$((_CDHIST_SIZE + 1))
      _CDHIST_PREV="$_CDHIST_PREV:$PWD"
      if [ $_CDHIST_SIZE -eq $_CDHIST_MAX_SIZE ]; then
        _CDHIST_PREV=":${_CDHIST_PREV#:*:}" # ":a:b:c: -> ":b:c"
        _CDHIST_SIZE=$((_CDHIST_SIZE - 1))
      fi
      _CDHIST_NEXT=""
    fi
  fi
}

go-back() {
  if [ -n "$_CDHIST_PREV" ]; then
    local TARGET_DIR="${_CDHIST_PREV##*:}" # ":a:b:c" -> "c"
    _CDHIST_PREV="${_CDHIST_PREV%:*}"      # ":a:b:c" -> ":a:b"
    if [ "$PWD" != "${_CDHIST_NEXT##*:}" ]; then
      _CDHIST_NEXT="$_CDHIST_NEXT:$PWD"
    fi
    cd $TARGET_DIR || return
    _CDHIST_SIZE=$((_CDHIST_SIZE - 1))
  else
    _CDHIST_SIZE=0
  fi

  # Get the current cursor coordinate.
  #IFS=';' read -sdR -p $'\E[6n' ROW COL
  #local current_row=$(echo "${ROW#*[}")

  # Move the cursor up then delete that line
  #tput cup $((current_row - 2)) 0 && tput el
}

go-next() {
  if [ -n "$_CDHIST_NEXT" ]; then
    local TARGET_DIR="${_CDHIST_NEXT##*:}" # ":a:b:c" -> "c"
    _CDHIST_NEXT="${_CDHIST_NEXT%:*}"      # ":a:b:c" -> ":a:b"
    if [ "$PWD" != "${_CDHIST_PREV##*:}" ]; then
      _CDHIST_PREV="$_CDHIST_PREV:$PWD"
    fi
    cd $TARGET_DIR || return
    _CDHIST_SIZE=$((_CDHIST_SIZE + 1))
  fi

  # Get the current cursor coordinate.
  #IFS=';' read -sdR -p $'\E[6n' ROW COL
  #local current_row=$(echo "${ROW#*[}")

  # Move the cursor up then delete that line
  #tput cup $((current_row - 2)) 0 && tput el
}

if [[ -z $CDHIST_INSTALLED ]]; then

  # if bash is runing in interactive mode
  if [[ $- == *i* ]]; then

    if [ ${#preexec_functions[@]} -eq 0 ]; then
      echo "ERROR: no bash-preexec found."
      echo "    download it"
      echo "curl https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh"
      echo "    and install"
      echo "echo '[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh' >> ~/.bashrc"
      return 1
    fi

    if [ -z $HISTIGNORE ]; then
      export HISTIGNORE=go-next:go-back
    else
      export HISTIGNORE="$HISTIGNORE:go-next:go-back"
    fi

    preexec_functions+=(__cdhist_preexec)

    # Alt+,
    #bind -x '"\e\,": go-back'
    bind '"\e\,": "\C-ex\C-ugo-back\C-m\C-y\C-b\C-d"'

    # Alt+.
    #bind -x '"\e.": go-next'
    bind '"\e.": "\C-ex\C-ugo-next\C-m\C-y\C-b\C-d"'

    export CDHIST_INSTALLED="yes"
  fi
fi
