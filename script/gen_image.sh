#!/bin/sh

if [ -z $1 ]; then
  DIR=.
else
  mkdir -p $1
  DIR=$1
fi

SIZES="32 64 128 256 512"
FORMATS="jpg png gif"

for format in $FORMATS; do
  if [ ! -d $DIR/$format ]; then
    mkdir -p $DIR/$format
  fi
done

gen_rand() {
  DIR=$1
  convert -size 1080x1080 plasma:fractal $DIR/orig.jpg

  for size in $SIZES; do
    for format in $FORMATS; do
      echo "convert -resize ${size}x${size} $DIR/orig.jpg $DIR/$format/img-${size}x${size}.$format"
      convert -resize ${size}x${size} $DIR/orig.jpg $DIR/$format/img-${size}x${size}.$format
    done
  done
}

gen_rand $DIR