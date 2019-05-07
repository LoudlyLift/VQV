#!/bin/bash

WDIR=$(mktemp -d)

for file in $(find ./ -type f \( -iname \*.hevc -o -iname \*.mp4 \)); do
	FNAME=$(rev <<< "$file" | cut -d '/' -f 1 | rev)
	OF="$WDIR/$FNAME"
	../bin/script.bash "$file" "$OF"
	du -s "$file" >> inputs.txt
	du -s "$OF" >> outputs.txt
done

rm -r "$WDIR"
