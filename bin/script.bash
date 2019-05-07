#!/bin/bash
IF=$1 #Input File
OF=$2 #Output File

format=$(rev <<< "$IF" | cut -d '.' -f 1 | rev)

WDIR=$(mktemp -d) #Working DIRectory
FL="${WDIR}/left.${format}"
FC="${WDIR}/center.${format}"
FR="${WDIR}/right.${format}"


size=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$IF")
width=$(cut -d 'x' -f 1 <<< "$size")
height=$(cut -d 'x' -f 2 <<< "$size")

third=$(($width / 3))
left=$third
right=$((2*$third))

ffmpeg -i "$IF" -b:v 0.25M -filter:v "crop=$left:$height:0:0" "$FL"
ffmpeg -i "$IF" -b:v 0.50M -filter:v "crop=$((right-left)):$height:$left:0" "$FC"
ffmpeg -i "$IF" -b:v 0.25M -filter:v "crop=$((width-right)):$height:$right:0" "$FR"

ffmpeg -i "$FL" -i "$FC" -i "$FR" -b:v 1.0M -filter_complex hstack=inputs=3 "$OF"

rm -r "$WDIR"
