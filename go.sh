#!/bin/bash
#
#

trap cleanup_and_die INT

cleanup_and_die() {
  if [[ -f $IN_PROGRESS ]] && [[ $(stat -c %s $IN_PROGRESS) -eq 0 ]]; then
    echo "Deleting $IN_PROGRESS"
    rm $IN_PROGRESS
  fi
  die "$@"
}

yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || cleanup_and_die "cannot $*"; }

usage () {
  echo "Usage: $0 [-s skip]" 1>&2
  echo "    -s skip  :  Skip this many valid avi files, so we don't wait for a slow node"
  exit 1
}

SKIP=0

while getopts ":s:" opt; do
  case "${opt}" in
    s)
      SKIP=${OPTARG}
      ;;
    *)
      usage
      ;;
  esac
done



NFRAMES=360
W=1920
H=1080
FPS=30

# $1 is the ID
# $2 is the animated flame
# $3 is the start frame
# $4 is the end frame
render () {
  if ! [[ -f movies/$1.avi ]]; then

    # The skip feature allows a slow node to work on video far in advance
    # This way there won't be a gap in the video while we wait for the slow node
    if [[ $SKIP -gt 0 ]]; then
      SKIP=$SKIP-1
      echo "Skipping $1"
    else
      echo "Starting $1"
      # Touch the output file so other nodes don't attempt it
      touch movies/$1.avi
      IN_PROGRESS=movies/$1.avi
      # Make stills out of the animated flame file, first the first part of the animation
      mkdir -p frames/$1/ 

      try env in=animated_genomes/$2.flame prefix=frames/$1/ format=jpg jpeg=95 begin=$3 end=$4 flam3-animate
      try mencoder mf://frames/$1/*.jpg -mf w=$W:h=$H:fps=$FPS:type=jpg -ovc copy -oac copy -o movies/$1.avi
      rm -rf frames/$1/
    fi
  fi
}


# We should already have mounted the NFS share
[ ! -d movies ] && echo 'movies share not created' && exit 1
#mkdir movies 2>/dev/null
mkdir animated_genomes 2>/dev/null

sed "s/WIDTH/$W/" animated.template | sed "s/HEIGHT/$H/" > anim_template.flame

FLAME_LIST=genomes/*.flam3
# Set the last flame as the previous to create a loop transition
OLD_FLAME=`echo $FLAME_LIST | awk '{ print $NF }'`

for FLAME in $FLAME_LIST; do

  ID=`basename $FLAME | sed 's/.flam3//'`
  OLD_ID=`basename $OLD_FLAME | sed 's/.flam3//'`

  # Merge old and new flames into a single file to make the animation from
  echo '<flames name="Batch">' > tmp.flame
  cat $OLD_FLAME $FLAME  >> tmp.flame
  echo '</flames>' >> tmp.flame

  BOTH_ID=${OLD_ID}_${ID}

  
  if [[ -f movies/$ID.avi ]] && [[ -f movies/$BOTH_ID.avi ]]; then
    continue
  fi
  
  # The skip feature allows a slow node to work on video far in advance
  # This way there won't be a gap in the video while we wait for the slow node
  if [[ $SKIP -gt 1 ]]; then
    SKIP=$SKIP-2
    echo "Skipping $BOTH_ID"
    echo "Skipping $ID"

    OLD_FLAME=$FLAME
    OLD_ID=$ID
    continue
  fi

  # Create a new flame file with enough frames to loop
  try env template=anim_template.flame sequence=tmp.flame nframes=$NFRAMES flam3-genome  > animated_genomes/$BOTH_ID.flame

  END=$(($NFRAMES + $NFRAMES - 1))
  render $BOTH_ID  $BOTH_ID  $NFRAMES  $END 

  render $ID  $BOTH_ID  0  $NFRAMES-1

  rm animated_genomes/$BOTH_ID.flame

  OLD_FLAME=$FLAME
  OLD_ID=$ID

done

