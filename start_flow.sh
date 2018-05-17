#!/bin/bash

temp_file=`date +%s`
file1=$1
file2=$2
name1=$3
name2=$4
frame=$5
title=$6

if [[ ! -f $file1 && ! -f $file2 ]];
then 
    echo "File not found!"
    exit 0
fi

# Convert from encoded to RAW with upscale to 1080p
ffmpeg -y -i $file1 -f rawvideo -vcodec rawvideo -pix_fmt yuv420p -s 1920x1080 -vframes $frame -r 25 ${temp_file}_${file1}.yuv
# Convert from encoded to RAW with upscale to 1080p
ffmpeg -y -i $file2 -f rawvideo -vcodec rawvideo -pix_fmt yuv420p -s 1920x1080 -vframes $frame -r 25 ${temp_file}_${file2}.yuv

# Split Screen from Video 1 and Video 2
ffmpeg -y -f rawvideo -vcodec rawvideo -s 1920x1080 -r 25 -pix_fmt yuv420p -i ${temp_file}_${file1}.yuv -f rawvideo -vcodec rawvideo -s 1920x1080 -r 25 -pix_fmt yuv420p -i ${temp_file}_${file2}.yuv -filter_complex "[0]crop=iw/2:ih:0:0, pad=iw*2:ih[left];[1]crop=iw/2:ih:0:0[right];[left][right]overlay=w" ${temp_file}_${name1}_${name2}.yuv

# Clean up raw files to save space
rm -f ${temp_file}_${file1}.yuv ${temp_file}_${file2}.yuv

# Overlay the bitrate information
ffmpeg -y -f rawvideo -vcodec rawvideo -s 1920x1080 -r 25 -pix_fmt yuv420p -i ${temp_file}_${name1}_${name2}.yuv  -i img/${name1}.png -i img/${name2}.png -filter_complex "[0:v][1:v] overlay=35:40 [tmp];[tmp][2:v] overlay=1770:40" -pix_fmt yuv420p ${temp_file}_${name1}_${name2}_overlay.yuv
# Create proxy for QA
ffmpeg -y -f rawvideo -vcodec rawvideo -s 1920x1080 -r 25 -pix_fmt yuv420p -i ${temp_file}_${name1}_${name2}_overlay.yuv -c:v libx264 -preset ultrafast -qp 0 ${title}_${name1}_${name2}.mp4


# Create High Q Prores

ffmpeg -y -f rawvideo -vcodec rawvideo -s 1920x1080 -r 25 -pix_fmt yuv420p -i ${temp_file}_${name1}_${name2}_overlay.yuv -c:v prores_ks -profile:v 3 ${title}_${name1}_${name2}_ProRes.mov
# Clean up
rm -f ${temp_file}_${name1}_${name2}.yuv
rm -r ${temp_file}_${name1}_${name2}_overlay.yuv

