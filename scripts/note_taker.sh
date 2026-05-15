#!/bin/bash

file="$1"

if [ ! -f "$file" ]; then
  touch "$file"
fi

vim "$file"
