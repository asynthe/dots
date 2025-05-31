#!/usr/bin/env bash

sshfs -o allow_other,IdentityFile=$HOME/sync/ben/pass/ssh/thinknya_nopass ben@100.122.54.91:/home/ben $HOME/server
