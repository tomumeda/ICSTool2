#!/usr/bin/perl

print "====PERL ENV:\n"; map {print "$_  : $ENV{$_} \n"} keys %ENV;

