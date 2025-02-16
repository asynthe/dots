#!/usr/bin/env bash

# Enabling and running the ssh-agent
#eval "$(ssh-agent -s)"
#ssh-add ~/.ssh/id_ed25519

mkdir -p ~/sync/{dots,notes,study}

git clone git@github.com:asynthe/dots.git ~/sync/dots
# This ones will ask for authentication as they're private repositories.
git clone git@github.com:asynthe/notes.git ~/sync/notes
git clone git@github.com:asynthe/study.git ~/sync/study
