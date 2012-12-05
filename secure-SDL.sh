#!/bin/bash
#
# Secure the .sdl files in 'moul-scripts'
# Wed Dec 5 MST 2012	F. Holmer	v0.0
#
SRC=$HOME/work/moul-scripts/SDL
DEST=$HOME/work/ServerStructure/auth/default/SDL
KEY=3b8c1dc62a3d951f14180a0c28841442	# default key

# Copy and secure the SDL files
rm -f $DEST/*.sdl
cp $SRC/*.sdl $DEST
cd $DEST
PlasmaCrypt droid -key $KEY -verbose *.sdl

# generate the manifest
ls -1 *.sdl|awk '{ print "SDL\\"$1; }' > ../SDL.txt
cd ..
$HOME/work/make-mbam.pl SDL.txt

echo "Generated file locations:"
echo "  `pwd`/SDL.mbam"
echo "   $DEST/*.sdl"
echo

cd $HOME/work
