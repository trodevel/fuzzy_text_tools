#!/usr/bin/perl -w

#
# fuzzy_uniq
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

# 1.0 - 23112 - initial commit

my $VER="1.0";

###############################################

use strict;
use warnings;
use 5.010;
use Getopt::Long;

require fuzzy_uniq;

###############################################

my $IS_VERBOSE=0;

###############################################

sub print_debug($)
{
    my ( $s ) = @_;

    if( $IS_VERBOSE == 1 )
    {
        print "DEBUG: $s\n";
    }
}

###############################################

sub process($$$)
{
    my ( $filename, $output_file, $similarity_pct ) = @_;

    unless( -e $filename )
    {
        print STDERR "ERROR: file $filename doesn't exist\n";
        exit;
    }

    print_debug( "reading file $filename ..." );
    print_debug( "writing file $output_file ..." );

    open( my $fl, "< $filename" ) or die "Couldn't open file for reading: $!\n";
    open( my $fl_o, "> $output_file" ) or die "Couldn't open file for writing: $!\n";

    my $lines = 0;
    my $uniq_lines = 0;

    my $prev_line = undef;

    while( <$fl> )
    {
        chomp;
        $lines++;

        my $line = $_;

        if( defined $prev_line )
        {
            my $similarity = fuzzy_uniq::calc_similarity( $line, $prev_line );

            print_debug( "line '$line', prev_line '$prev_line', similarity $similarity" );

            if( $similarity < $similarity_pct )
            {
                $uniq_lines++;
                print $fl_o $line . "\n";
            }
        }

        $prev_line = $line;

        #print_debug( "lines: $line" );
    }

    print "INFO: read $lines lines(s) from $filename, wrote $uniq_lines to $output_file\n";
}

###############################################

sub print_help()
{
    print STDERR "\nUsage: fuzzy_uniq.sh --input_file <input.txt> --output_file <output.txt> --similarity <similarity_pct>\n";
    print STDERR "\nExamples:\n";
    print STDERR "\ncode_gen.sh --input_file data.txt --output_file data_uniq.h --similarity 90\n";
    print STDERR "\n";
    exit
}

###############################################

my $input_file;
my $output_file;
my $similarity_pct;

GetOptions(
            "input_file=s"      => \$input_file,   # string
            "output_file=s"     => \$output_file,  # string
            "similarity=i"      => \$similarity_pct,   # integer
            "verbose"           => \$IS_VERBOSE   )    # flag
  or die("Error in command line arguments\n");

&print_help if not defined $input_file;
&print_help if not defined $output_file;
&print_help if not defined $similarity_pct;

print STDERR "input_file  = $input_file\n";
print STDERR "output file = $output_file\n";
print STDERR "similarity  = $similarity_pct\n";

process( $input_file, $output_file, $similarity_pct );

###############################################
1;