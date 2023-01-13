#!/usr/bin/perl

#
# Fuzzy Uniq
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

use strict;
use warnings;
use utf8;
use String::Approx;

package fuzzy_uniq;

sub calc_dist($$)
{
    my ( $word_1, $word_2 ) = @_;

    my $res = String::Approx::adist( $word_1, $word_2 );

    return $res;
}

sub max($$)
{
    my ( $a, $b ) = @_;

    if( $a > $b )
    {
        return $a;
    }

    return $b;
}

sub sq_sum($$)
{
    my ( $v_1, $v_2 ) = @_;

    my $v_1_p = $v_1 * $v_1;
    my $v_2_p = $v_2 * $v_2;

    my $v_1_2_s = $v_1_p + $v_2_p;

    my $sq = sqrt( $v_1_2_s );

    my $res = $sq;

    return $res;
}

sub calc_similarity_core($$)
{
    my ( $word_1, $word_2 ) = @_;

    my $dist_1 = calc_dist( $word_1, $word_2 );
    my $dist_2 = calc_dist( $word_2, $word_1 );

    my $len_1 = length $word_1;
    my $len_2 = length $word_2;

    if( $len_2 == 0 )
    {
        return 0.0;
    }

    if( $len_1 == 0 )
    {
        return 0.0;
    }

    my $diff = sq_sum( $dist_1, $dist_2 );

    my $len = sq_sum( $len_1, $len_2 );

    my $res = 100.0 * ( $len - $diff ) / $len;

    #print "DEBUG: calc_similarity_core: $len_1:'$word_1', $len_2:'$word_2', d1 $dist_1, d2 $dist_2, len=$len, diff=$diff, sim $res\n";

    return $res;
}

sub calc_similarity($$@)
{
    my ( $word_1, $word_2, $should_ignore_case ) = @_;

    if( defined $should_ignore_case )
    {
        #print "DEBUG: calc_similarity: should_ignore_case = $should_ignore_case\n";

        if(  $should_ignore_case == 1 )
        {
            return calc_similarity_core( lc( $word_1 ), lc( $word_2 ) );
        }
    }

    return calc_similarity_core( $word_1, $word_2 );
}

1;
