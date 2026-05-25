# .bash_profile
#
# Login shells read this and stop — they do not also read .bashrc.
# Source .bashrc so login and non-login shells get the same environment.
# All real config lives in .bashrc.

if [ -f ~/.bashrc ]; then
  builtin source ~/.bashrc
fi
