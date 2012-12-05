#!/usr/bin/perl
# ----
# Copyright (C) 2012    F. Holmer
# Version 0.1   Wed Aug  1 12:56:58 MDT 2012
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
# ----
# convert a given text file to a .mbm manifest file
#
# Usage: mkmbm.pl manifest.txt
#   with files paths named in "manifest.txt" available and placed in current directory
#   Its easiest to run this from your CyanStructure directory
#
# This script assumes that it is being run from the top directory with the files contained 
#  here and in subdirectories. The results are also placed here and in subdirectories. 
#  This is controlled by the content of the manifest text files.
# We may want completely seperate source and destination dirs. The destination can be in the 'file'
#  dir of the server ;) Might make good command-line options
# It is also assumed that it will be run on the server, or at least a 'nix box.
#
# Input data format:
#   client\path\file.ext,server\path\file.ext.gz,n
#   ...
#
# Output data format:   (le) 
#   #records    (4 byte)    #Just one per file
#       entrysize           ( 4 byte)       # one of each of these per record
#       Clientpath          ( wide string)
#       serverpath          ( wide string)
#       uncompressedfileMD5 ( HEX wide string)
#       compresseFileMD5    ( hex wide string)
#       uncompressedSize    ( 6 byte weird)
#       compressedSize      ( 6 byte weird)
#       Empty               ( 2 bytes)
#       FileFlags           ( 4 bytes?)

use strict;
use warnings;

use File::Basename;
use IO::File;
use IO::Compress::Gzip qw(gzip $GzipError);
use Digest::MD5;

my $fh;
my $problems = 0;           # think positive
my $nil = "\000\000";
my $count = "$nil$nil";

# Encode the output strings
sub enc {
    my $input = shift;      # uses one argument
    my $strlen = length($input);
    my $output = "";

    for (my $i = 0; $i <= $strlen; $i++)  {
        $output .= pack("Cx", ord(substr($input, $i, 1)));
    }

    return $output;
}

my $inputname = $ARGV[0]; 
die "Usage:  $0 <textfile>\n" unless(-s $inputname);    # redo this to make it more informative

my $INF = IO::File->new();
$INF->open("< $inputname") or die "$!  $inputname is not accessable.";

# Derive an output .mbm filename from the input file name
(my $outname = $inputname) =~ s/\.txt$/.mbm/;
my $OUTH = IO::File->new();
$OUTH->open("> $outname") or die "$!  Can\'t create $outname.";
$OUTH->write(pack("L", 0), 4, 0); $OUTH->sync;

while (<$INF>)  {
    chomp;
    next if /^\s*#/;    # skip comments
    next unless /\S/;   # and blank lines

    my $startrec = $OUTH->tell;
    $OUTH->write(pack("L", 0), 4);            # write out an initial record size.
    $OUTH->sync;

    my ($clientF, $serverF, $type) = split(/,/);

    $clientF =~ s/^\s*\(.*?\)\s*$/\$1/;
    $clientF =~ s|\/|\\|g;                      # make damn sure that '\' is used in the path
    (my $clientFnix = $clientF) =~ s/\\/\//g;   # but 'nix likes '/'
    $OUTH->write( enc($clientF)  );
#   $OUTH->write($nil, 2);
    $OUTH->sync;
    
    $serverF =~ s/^\s*\(.*?\)\s*$/\$1/;
    $serverF =~ s|\/|//|g;
    (my $serverFnix = $serverF) =~ s/\\/\//g; 
    $OUTH->write( enc($serverF) );
#   $OUTH->write($nil, 2);
    $OUTH->sync;

    # lets see if the client file is available
    unless (-s $clientFnix)  {
        warn "\n\nCannot find $clientFnix. Skipping this one..\n\n";    # !!! this may be a place where we want to 'die'
        $problems++;
        $OUTH->seek($startrec, 0);
        next;
    }

    # gzip the client file to the destiation path
    # (will need to create the destination path if it doe not exist)
    my $path = dirname($serverFnix);
    `/bin/mkdir -p $path`;                                 #any errors will fall thru
    unless ( gzip $clientFnix => $serverFnix )  {
        $OUTH->close;
        die "$GzipError! Cannot compress $serverFnix";
    }
    print "\n$clientFnix -> $serverFnix ";

    # calc the MD5 hash of compressed and uncompressed files. Make a function out of these two
    $fh = IO::File->new;
    if ($fh->open("< $clientFnix"))  {
        binmode $fh;
        my $clientMD5 = enc(Digest::MD5->new->addfile($fh)->hexdigest);
        $fh->close;

#       $OUTH->write($clientMD5, 32);
        $OUTH->write($clientMD5);
    }
    if ($fh->open("< $serverFnix"))  {
        binmode $fh;
        my $serverMD5 = enc(Digest::MD5->new->addfile($fh)->hexdigest);
        $fh->close;

#       $OUTH->write($serverMD5, 32);
        $OUTH->write($serverMD5);
    }
    $OUTH->sync;

    # get get file sizes in bytes (we could use 'stat')
    my $ucsize = -s $clientFnix or die "$clientFnix size is zero";
    my $uc6bsize = pack("CCCCS",
                        ($ucsize & 0x00FF0000) >> 16,
                        ($ucsize & 0xFF000000) >> 24,
                        ($ucsize & 0xFF),
                        ($ucsize & 0x0000FF00) >> 8,
                        0);
    $OUTH->write($uc6bsize, 6);

    my $gzsize = -s $serverFnix or die "$serverFnix size is zero";
    my $gz6bsize = pack("CCCCS",                            # This is what will be written, 6 bytes of it anyway
                        ($gzsize & 0x00FF0000) >> 16,
                        ($gzsize & 0xFF000000) >> 24,
                        ($gzsize & 0xFF),
                        ($gzsize & 0x0000FF00) >> 8,
                        0);
    $OUTH->write($gz6bsize, 6);

    $OUTH->write($nil, 2);
    $OUTH->write(pack("L", $type), 4);

    # update the record length
    $OUTH->sync;
    my $here = $OUTH->tell; 
#   print ($here - $startrec);
    $OUTH->seek($startrec, 0); 
    $OUTH->write(pack("L", (($here - $startrec) - 4)), 4);
    $OUTH->seek(0, 2);

    $count++;
}

# Write out the final line count
$OUTH->seek(0, 0);
$OUTH->write(pack("L", $count), 4);
$OUTH->close;

print "\n $count records written, $problems problems detected.\n";
