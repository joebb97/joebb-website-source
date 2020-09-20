#!/bin/sh

# If a command fails then the deploy stops
set -e

printf "\033[0;32mDoing rebuild of public folder...\033[0m\n"

# Build the project.
hugo -D # if using a theme, replace with `hugo -t <YOURTHEME>`

# Go To Public folder
cd public

# Add changes to git.
git add .

# Commit changes.
msg="rebuilding site $(date)"
if [ -n "$*" ]; then
    msg="$*"
fi
git commit -m "$msg"
