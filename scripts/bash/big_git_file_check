#!/usr/bin/env bash

# Taken from:
# https://stackoverflow.com/questions/9456550/how-can-i-find-the-n-largest-files-in-a-git-repository

git rev-list --objects --all \
| git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \
| sed -n 's/^blob //p' \
| sort --numeric-sort --key=2 \
| tail -n 10 \
| cut -c 1-12,41- \
| $(command -v gnumfmt || echo numfmt) --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest
