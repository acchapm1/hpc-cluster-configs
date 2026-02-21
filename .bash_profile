# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  builtin source ~/.bashrc
fi

# Git prompt
if [ -f ~/.git-prompt.sh ]; then
  builtin source ~/.git-prompt.sh
fi
if [ -f ~/.git-completion.bash ]; then
  builtin source ~/.git-completion.bash
fi

# source aliases
if [ -f ~/.aliases ]; then
  builtin source ~/.aliases
fi

# import fuctions
if [ -f ~/.functions ]; then
  builtin source ~/.functions
fi
