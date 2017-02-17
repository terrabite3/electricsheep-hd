#!/bin/bash
#
#

FLAME=""

echo "#EXTM3U" > movies/playlist.m3u

for FLAME in genomes/*.flam3; do

  ID=`basename $FLAME | sed 's/.flam3//'`

  if [[ $OLD_FLAME != ""]]
    echo "$OLD_ID.avi" >> movies/playlist.m3u
    echo "$OLD_ID.avi" >> movies/playlist.m3u
    echo "$OLD_ID.avi" >> movies/playlist.m3u
  fi

  echo "${OLD_ID}_${ID}.avi" >> movies/playlist.m3u

  OLD_ID=$ID

done
