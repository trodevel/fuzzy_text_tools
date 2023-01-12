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

sub calc_similarity($$)
{
    my ( $word_1, $word_2 ) = @_;

    my $dist = calc_dist( $word_1, $word_2 );

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

    my $max_len = $len_1;

    if( $len_2 > $len_1 )
    {
        $max_len = $len_2;
    }

    if( $dist < 0 )
    {
        $dist = -1 * $dist;
    }

    my $res = 100.0 * ( $max_len - $dist ) / $max_len;

    return $res;
}

1;
