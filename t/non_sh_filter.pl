#! /usr/bin/perl -w

use strict;

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
t/sh_file_count.txt
t/t_funcs.binsafe.txt
