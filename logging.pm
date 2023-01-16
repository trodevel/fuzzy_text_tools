#!/usr/bin/perl -w

#
# logging
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

###############################################

use strict;
use warnings;
use 5.010;
use utf8;

###############################################

package logging;

###############################################

my $IS_VERBOSE=0;

###############################################

sub set_log_level($)
{
    my ( $s ) = @_;

    $IS_VERBOSE = $s;
}

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

1;
