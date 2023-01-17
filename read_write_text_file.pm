#!/usr/bin/perl -w

#
# read_write_text_file
#
# Copyright (C) 2023 Dr. Sergey Kolevatov
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

# 1.0 - 23116 - initial commit

my $VER="1.0";

###############################################

use strict;
use warnings;
use 5.010;
use utf8;

require logging;

###############################################

sub read_file($$)
{
    my ( $filename, $array_ref ) = @_;

    logging::print_debug( "reading file $filename ..." );

    open( my $fl, "<:encoding(utf8)", $filename ) or die "Couldn't open file for reading: $!\n";

    my $lines = 0;

    while( my $line = <$fl> )
    {
        chomp $line;
        $lines++;

        push( @$array_ref,  $line );

        #logging::print_debug( "line: $line" );
    }

    logging::print_debug( "read $lines lines(s) from $filename" );
}

###############################################

sub write_file($$)
{
    my ( $filename, $array_ref ) = @_;

    logging::print_debug( "writing file $filename ..." );

    open( my $fl, ">:encoding(utf8)", $filename ) or die "Couldn't open file for writing: $!\n";

    my $size = scalar @$array_ref;

    for my $i ( @$array_ref )
    {
        print $fl $i . "\n";
    }

    logging::print_debug( "wrote $size lines(s) to $filename" );
}

###############################################
1;
