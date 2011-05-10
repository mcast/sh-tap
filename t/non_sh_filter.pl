#! /usr/bin/perl

use strict;
use warnings;

my %skip;
@skip{ <DATA> } = ();

while (<>) {
    s{^\./}{};
    next if m{^\.git/|~$};
    next if exists $skip{$_}; # note trailing LF
    print;
}

__DATA__
.gitignore
COPYING
README.txt
bin/unhd
t/checkbashisms_filter.pl
t/non_sh_filter.pl
t/t_funcs.binsafe.txt
