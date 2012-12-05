#!/bin/bash
#
# Secure the .sdl files in 'moul-scripts'
# Wed Dec 5 MST 2012	F. Holmer	v0.0
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# This little script uses libhsplasma available at 'https://github.com/H-uru/libhsplasma.git'
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
echo "  $DEST/*.sdl"
echo
echo "cp `pwd`/SDL.mbam $HOME/auth/default"
echo "cp $DEST/*.sdl $HOME/auth/default/SDL"
echo

cd $HOME/work
