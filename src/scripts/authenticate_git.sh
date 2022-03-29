#! /bin/bash
echo "$GITHUB_PAT" > github_pat.txt
gh auth login --with-token < github_pat.txt
