#!/bin/bash

git filter-branch --force --index-filter \
'git rm --cached --ignore-unmatch config/secret.exs' \
--prune-empty --tag-name-filter cat -- --all