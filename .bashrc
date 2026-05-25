# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) PATH="$HOME/.local/bin:$PATH" ;; esac
case ":$PATH:" in *":$HOME/bin:"*)        ;; *) PATH="$HOME/bin:$PATH"        ;; esac
export PATH

# Stop here for non-interactive shells (scp, rsync, ssh host cmd).
# PATH above is still applied so remote commands resolve user binaries.
case $- in *i*) ;; *) return ;; esac

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

unset rc

export EDITOR='vim'
export VISUAL='vim'
export PROMPT_DIRTRIM=1
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export COLORTERM=truecolor

HISTTIMEFORMAT="%F|%T "
HISTCONTROL=ignoreboth
HISTIGNORE="ls:ll:pwd"
HISTSIZE=1000000

# Git tab completion (no prompt — see C5 in TOFIX.md)
if [ -f ~/.git-completion.bash ]; then
  builtin source ~/.git-completion.bash
fi

# Aliases
if [ -f ~/.aliases ]; then
  builtin source ~/.aliases
fi

# Shell functions
if [ -f ~/.functions ]; then
  builtin source ~/.functions
fi
