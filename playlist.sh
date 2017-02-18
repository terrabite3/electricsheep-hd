#!/bin/bash
#
#

echo "#EXTM3U" > movies/playlist.m3u

for FLAME in genomes/*.flam3; do

  ID=`basename $FLAME | sed 's/.flam3//'`

  if [[ $OLD_ID != "" ]]; then
    echo "${OLD_ID}_${ID}.avi" >> movies/playlist.m3u
  fi
  
  echo "$ID.avi" >> movies/playlist.m3u
  echo "$ID.avi" >> movies/playlist.m3u
  echo "$ID.avi" >> movies/playlist.m3u
  
  OLD_ID=$ID

done
