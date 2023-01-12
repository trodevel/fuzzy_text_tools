#!/usr/bin/perl

#
# Fuzzy Uniq Test.
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

require fuzzy_uniq;

binmode(STDOUT, "encoding(UTF-8)");

sub test_calc_dist($$$)
{
    my ( $name, $word_1, $word_2 ) = @_;

    my $res = fuzzy_uniq::calc_dist( $word_1, $word_2 );

    print "INFO: $name: dist = $res, word_1 '$word_1', word_2 '$word_2'\n";
}

sub test_calc_similarity($$$)
{
    my ( $name, $word_1, $word_2 ) = @_;

    my $res = fuzzy_uniq::calc_similarity( $word_1, $word_2 );

    print "INFO: $name: similarity = $res, word_1 '$word_1', word_2 '$word_2'\n";
}

sub test_01()
{
    test_calc_dist( 'test_01', "pattern", "pattrn" );
}

sub test_02()
{
    test_calc_dist( 'test_02', "pattrn", "pattern" );
}

sub test_03()
{
    test_calc_similarity( 'test_03', "pattrn", "pattern" );
}

sub test_04()
{
    test_calc_similarity( 'test_04', "pattern", "pattrn" );
}

sub test_05()
{
    test_calc_similarity( 'test_05', "pattern", "pattern" );
}

sub test_06()
{
    test_calc_similarity( 'test_06', "UX исследователь", "UX-исследователь" );
}

sub test_07()
{
    test_calc_similarity( 'test_07', "UI/UX дизайнер", "UX дизайнер" );
}

sub test_08()
{
    test_calc_dist( 'test_08', "UI/UX дизайнер", "UX дизайнер" );
}

test_01();
test_02();
test_03();
test_04();
test_05();
test_06();
test_07();
test_08();
