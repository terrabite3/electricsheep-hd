#!/bin/bash
#
#

NFRAMES=360
W=1920
H=1080
FPS=30

# $1 is the ID
# $2 is the start frame
# $3 is the end frame
render () {
  if ! [[ -f movies/$1 ]]; then
    # Touch the output file so other nodes don't attempt it
    touch movies/$1.avi
    # Make stills out of the animated flame file, first the first part of the animation
    mkdir -p frames/$1/ 2>/dev/null

    env in=animated_genomes/$1.flame prefix=frames/$1/ format=jpg jpeg=95 begin=$2 end=$3 flam3-animate
    mencoder mf://frames/$1/*.jpg -mf w=$W:h=$H:fps=$FPS:type=jpg -ovc copy -oac copy -o movies/$1.avi
    rm -rf frames/$1/
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

  # Create a new flame file with enough frames to loop
  env template=anim_template.flame sequence=tmp.flame nframes=$NFRAMES flam3-genome  > animated_genomes/$BOTH_ID.flame

  render $BOTH_ID  $NFRAMES  2*$NFRAMES-1

  render $ID  0  $NFRAMES-1


  OLD_FLAME=$FLAME
  OLD_ID=$ID

done

