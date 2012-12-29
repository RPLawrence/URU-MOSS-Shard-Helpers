#!/bin/bash
#
# Generate python.pak from python scripts in 'moul-scripts'
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
# This little script uses libhsplasma available at 'https://github.com/H-uru/libhsplasma.git'
#
SRC=$HOME/work/moul-scripts/Python
DEST=$HOME/work/ServerStructure/auth/default/Python
KEY=3b8c1dc62a3d951f14180a0c28841442	# default key

# Make the .prc files. Be sure you are using python2.7
cd $SRC
rm -rf *.pyc
python2.7 -m compileall .

# create and secure the .pak file
rm -f $DEST/python.pak $DEST/../Python.mbam
PyPack -c -live $KEY system/*.pyc plasma/*.pyc ki/*.pyc *.pyc $DEST/python.pak
cd $DEST/..
echo 'Python\python.pak' > Python.txt
$HOME/work/make-mbam.pl Python.txt

echo "Files generated:"
echo "  $DEST/python.pak"
echo "  `pwd`/Python.mbam"
echo
echo "cp $DEST/python.pak $HOME/auth/default/Python"
echo "cp `pwd`/Python.mbam $HOME/auth/default"
echo

cd $HOME/work
