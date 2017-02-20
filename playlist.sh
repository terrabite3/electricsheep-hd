#!/bin/bash
#
#

echo "#EXTM3U" > movies/playlist.m3u

FLAME_LIST=genomes/*.flam3
# Set the last flame as the previous to create a loop transition
OLD_FLAME=`echo $FLAME_LIST | awk '{ print $NF }'`
OLD_ID=`basename $OLD_FLAME | sed 's/.flam3//'`

for FLAME in $FLAME_LIST; do

  ID=`basename $FLAME | sed 's/.flam3//'`

  if [[ $OLD_ID != "" ]]; then
    echo "${OLD_ID}_${ID}.avi" >> movies/playlist.m3u
  fi
  
  echo "$ID.avi" >> movies/playlist.m3u
  echo "$ID.avi" >> movies/playlist.m3u
  echo "$ID.avi" >> movies/playlist.m3u
  
  OLD_ID=$ID

done
