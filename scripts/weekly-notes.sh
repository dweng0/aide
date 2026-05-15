#!/bin/bash

base_filename="weekly-roundup"
filepath="${HOME}/notes"

current_week=$(date +"%V")
current_day=$(date +"%A")

filename="${base_filename}-${current_week}.md"
full_path="${filepath}/${filename}"

if [ -f "$full_path" ]; then
  echo "File already exists. Opening the file..."
  vim "$full_path"
  exit 0
fi

previous_week=$((current_week - 1))
previous_filename="${base_filename}-${previous_week}.md"
previous_full_path="${filepath}/${previous_filename}"

if [ -f "$previous_full_path" ]; then
  previous_modified=$(stat -f %m "$previous_full_path")
  current_time=$(date +%s)
  time_diff=$((current_time - previous_modified))

  if [ "$time_diff" -lt 604800 ]; then
    echo "The previous file is less than a week old. Cannot create a new file."
    if ! grep -q "^## $current_day$" "$previous_full_path"; then
      printf "\n\n## %s\n\n" "$current_day" >> "$previous_full_path"
    fi
    open "$previous_full_path"
    exit 1
  fi
fi

touch "$full_path"
printf -- "---\ntitle: Weekly roundup, week %s\n---\nThis week I worked on the following:\n\n## %s\n\n" \
  "$current_week" "$current_day" >> "$full_path"

echo "File created: $full_path"
open "$full_path"
