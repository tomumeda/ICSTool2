#!/usr/bin/perl
#
$str='abc"def"\n';
$test=$str;
$test=~s/[^"]//g;
print length($test)%2;
