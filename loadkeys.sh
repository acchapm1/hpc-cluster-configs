#!/bin/bash

eval $(ssh-agent -s)

for key in ~/.ssh/*; do
  if [[ ! "$key" == *.pub ]]; then
    ssh-add "$key" 2>/dev/null
  fi
done

ssh-add -L
