#!/usr/bin/perl -w

#
# fuzzy_find_most_similar
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
require logging;
require read_write_text_file;

###############################################

sub collect($$$$)
{
    my ( $filename, $res_ref, $word, $should_ignore_case ) = @_;

    logging::print_debug( "reading file $filename ..." );

    open( my $fl, "<:encoding(utf8)", $filename ) or die "Couldn't open file for reading: $!\n";

    my $lines = 0;

    my $max_similarity = 0.0;

    while( my $line = <$fl> )
    {
        chomp $line;
        $lines++;

        my $similarity = fuzzy_find_most_similar::calc_similarity( $word, $line, $should_ignore_case );

        logging::print_debug( "word '$word', line '$line', similarity $similarity" );

        if( $similarity >= $max_similarity )
        {
            if( $similarity > $max_similarity )
            {
                logging::print_debug( "word '$word', line '$line', similarity $similarity - NEW MAXIMUM" );

                $max_similarity = $similarity;
                @$res_ref = ();
            }

            logging::print_debug( "word '$word', adding line '$line', similarity $similarity for current maximum" );

            my @match;

            push( @match, $lines );
            push( @match, $similarity );
            push( @match, $line );

            push( @$res_ref, \@match );
        }
    }
}

###############################################

sub process($$$$)
{
    my ( $filename, $output_file, $word, $should_ignore_case ) = @_;

    my @res;

    collect( $filename, \@res, $word, $should_ignore_case );

    my $size = scalar @res;

    #write_file( $output_file, \@outp );

    print "INFO: wrote $size most similar lines(s) from $filename to $output_file\n";
}

###############################################

sub print_help()
{
    print STDERR "\nUsage: fuzzy_find_most_similar.sh --input_file <input.txt> --output_file <output.txt> --word <word>\n";
    print STDERR "\nExamples:\n";
    print STDERR "\ncode_gen.sh --input_file data.txt --output_file data_uniq.h --word engineer\n";
    print STDERR "\n";
    exit
}

###############################################

my $input_file;
my $output_file;
my $word;
my $should_ignore_case = 0;
my $is_verbose = 0;

GetOptions(
            "input_file=s"      => \$input_file,   # string
            "output_file=s"     => \$output_file,  # string
            "word=s"            => \$word,         # string
            "ignore-case"       => \$should_ignore_case,   # flag
            "verbose"           => \$is_verbose  )     # flag
  or die("Error in command line arguments\n");

&print_help if not defined $input_file;
&print_help if not defined $output_file;
&print_help if not defined $word;

logging::set_log_level( $is_verbose );

binmode(STDOUT, "encoding(UTF-8)");

print STDERR "input_file          = $input_file\n";
print STDERR "output file         = $output_file\n";
print STDERR "word                = $word\n";
print STDERR "should_ignore_case  = $should_ignore_case\n";

process( $input_file, $output_file, $word, $should_ignore_case );

###############################################
1;
