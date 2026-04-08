#!/bin/bash

inotifywait -m -e close_write --format '%f' . --include '.*\.lhs$' | while read FILE 
do
    echo "Change detected in $FILE. Running script..."
    lhs2TeX -o latex-dissertation.tex latex-dissertation.lhs
    sleep 5s
done