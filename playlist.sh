#!/bin/bash
#
#

PLAYLIST=movies/playlist.m3u

echo "#EXTM3U" > $PLAYLIST

FLAME_LIST=genomes/*.flam3
# Set the last flame as the previous to create a loop transition
OLD_FLAME=`echo $FLAME_LIST | awk '{ print $NF }'`
OLD_ID=`basename $OLD_FLAME | sed 's/.flam3//'`

for FLAME in $FLAME_LIST; do

  ID=`basename $FLAME | sed 's/.flam3//'`

  if [[ $OLD_ID != "" ]]; then
    echo "${OLD_ID}_${ID}.avi" >> $PLAYLIST
  fi
  
  echo "$ID.avi" >> $PLAYLIST
  echo "$ID.avi" >> $PLAYLIST
  echo "$ID.avi" >> $PLAYLIST

  OLD_ID=$ID

done
