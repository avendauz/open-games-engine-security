#!/bin/bash

while inotifywait -e close_write --format '%f' . | grep --line-buffered '\.lhs$'; do
    echo "Change detected. Running script..."
    lhs2TeX -o latex-dissertation.tex latex-dissertation.lhs
    sleep 5s
done