#!/usr/bin/perl

use strict;
use warnings;

my %dict = ();
while (<STDIN>) { 
    chomp;
    my ($count, $word) = split ' ';
    $dict{$word} = $count;
}

open FILE, "<", "feature_words.txt";
my $i = 0;
while (<FILE>) { 
    chomp;
    if ($dict{$_}) { print "$i:$dict{$_},"; } 
    $i += 1;
}
close FILE;

