#!/bin/bash
#
# Generate server 'game' data from SDL files in 'moul-scripts'
# Sat Dec 29 16:22:28 MST 2012	F. Holmer	v0.0
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
# This little script uses libhsplasma available at 'https://github.com/H-uru/libhsplasma.git'
#
SRC=$HOME/work/moul-scripts/SDL
DEST=$HOME/work/ServerStructure/game/SDL

rm -rf $DEST

mkdir -p $DEST/common
mkdir -p $DEST/Garrison
mkdir -p $DEST/Teledahn

cp $SRC/*.sdl $DEST
cd $DEST

# Do the special cases (do I need to rename the encrypted SDL in 'auth' as well?)
mv PhilRelto.sdl philRelto.sdl
mv ahnonay.sdl Ahnonay.sdl
mv ahnonaycathedral.sdl AhnonayCathedral.sdl

mv grsnTrnCtrDoors.sdl Garrison/
mv tldnPwrTwrPeriscope.sdl Teledahn/
mv tldnVaporScope.sdl Teledahn/
mv tldnWRCCBrain.sdl Teledahn/
mv *.sdl common/

echo "
At this point the game files at $DEST should match what you want in the servers 'game' directory.
Just copy them over.

"
cd $HOME
