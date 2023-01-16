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
use utf8;
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

sub process($$$$$)
{
    my ( $filename, $output_file, $similarity_pct, $should_ignore_case, $is_sorted ) = @_;

    if( $is_sorted == 1 )
    {
        process_sorted( $filename, $output_file, $similarity_pct, $should_ignore_case );
    }
    else
    {
        process_unsorted( $filename, $output_file, $similarity_pct, $should_ignore_case );
    }
}

###############################################

sub read_file($$)
{
    my ( $filename, $array_ref ) = @_;

    print_debug( "reading file $filename ..." );

    open( my $fl, "<:encoding(utf8)", $filename ) or die "Couldn't open file for reading: $!\n";

    my $lines = 0;

    while( my $line = <$fl> )
    {
        chomp $line;
        $lines++;

        push( @$array_ref,  $line );

        #print_debug( "line: $line" );
    }

    print_debug( "read $lines lines(s) from $filename" );
}

###############################################

sub write_file($$)
{
    my ( $filename, $array_ref ) = @_;

    print_debug( "writing file $filename ..." );

    open( my $fl, ">:encoding(utf8)", $filename ) or die "Couldn't open file for writing: $!\n";

    my $size = scalar @$array_ref;

    for my $i ( @$array_ref )
    {
        print $fl $i . "\n";
    }

    print_debug( "wrote $size lines(s) to $filename" );
}

###############################################

sub convert_array_to_map($$)
{
    my ( $array_ref, $map_ref ) = @_;

    my @array = @$array_ref;

    my $size = scalar @array;

    for my $i (0 .. ( $size - 1 ) )
    {
        $map_ref->{$i} = $array[$i];

        #print_debug( "convert_array_to_map: $i - $array[$i]" );
    }
}

###############################################

sub process_unsorted($$$$)
{
    my ( $filename, $output_file, $similarity_pct, $should_ignore_case ) = @_;

    my @inp;

    read_file( $filename, \@inp );

    my $size = scalar @inp;

    my %inp_map;

    convert_array_to_map( \@inp, \%inp_map );

    my $lines = 0;
    my $uniq_lines = 0;

    keys %inp_map;

    my @outp;

    while( my( $k, $v ) = each %inp_map )
    {
        $lines++;

        my $w_1 = $v;

        push( @outp, $w_1 );

        delete $inp_map{$k}; # delete current element

        my $new_size = scalar keys %inp_map;

        print_debug( "comparing $lines/$size word '$w_1', with $new_size words" );

        foreach my $k2 (keys %inp_map)
        {
            my $w_2 = $inp_map{ $k2 };

            my $similarity = fuzzy_uniq::calc_similarity( $w_1, $w_2, $should_ignore_case );

            print_debug( "word_1 '$w_1', word_2 '$w_2', similarity $similarity" );

            if( $similarity < $similarity_pct )
            {
                print_debug( "word_1 '$w_1', word_2 '$w_2', similarity $similarity - DIFFERENT" );

                $uniq_lines++;
            }
            else
            {
                print_debug( "word_1 '$w_1', word_2 '$w_2', similarity $similarity - SIMILAR" );

                delete $inp_map{$k2}; # delete similar element
            }
        }
    }

    write_file( $output_file, \@outp );

    print "INFO: read $lines lines(s) from $filename, wrote $uniq_lines to $output_file\n";
}

###############################################

sub process_sorted($$$$$)
{
    my ( $filename, $output_file, $similarity_pct, $should_ignore_case, $is_sorted ) = @_;

    unless( -e $filename )
    {
        print STDERR "ERROR: file $filename doesn't exist\n";
        exit;
    }

    print_debug( "reading file $filename ..." );
    print_debug( "writing file $output_file ..." );

    open( my $fl, "<:encoding(utf8)", $filename ) or die "Couldn't open file for reading: $!\n";
    open( my $fl_o, ">:encoding(utf8)", $output_file ) or die "Couldn't open file for writing: $!\n";

    my $lines = 0;
    my $uniq_lines = 0;

    my $prev_line = undef;
#    my $has_print_prev_line = 0;

    while( my $line = <$fl> )
    {
        chomp $line;
        $lines++;

        if( defined $prev_line )
        {
            my $similarity = fuzzy_uniq::calc_similarity( $line, $prev_line, $should_ignore_case );

            print_debug( "prev_line '$prev_line', line '$line', similarity $similarity" );

            if( $similarity < $similarity_pct )
            {
                $uniq_lines++;

                print $fl_o $line . "\n";
            }
            else
            {
#                $has_print_prev_line = 1;
            }
        }
        else
        {
            print_debug( "line '$line', no prev_line" );

            $uniq_lines++;

            print $fl_o $line . "\n";
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
my $should_ignore_case = 0;

GetOptions(
            "input_file=s"      => \$input_file,   # string
            "output_file=s"     => \$output_file,  # string
            "similarity=i"      => \$similarity_pct,   # integer
            "ignore-case"       => \$should_ignore_case,   # flag
            "verbose"           => \$IS_VERBOSE   )    # flag
  or die("Error in command line arguments\n");

&print_help if not defined $input_file;
&print_help if not defined $output_file;
&print_help if not defined $similarity_pct;

binmode(STDOUT, "encoding(UTF-8)");

print STDERR "input_file          = $input_file\n";
print STDERR "output file         = $output_file\n";
print STDERR "similarity          = $similarity_pct\n";
print STDERR "should_ignore_case  = $should_ignore_case\n";

process( $input_file, $output_file, $similarity_pct, $should_ignore_case, 0 );

###############################################
1;
