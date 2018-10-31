#!/usr/bin/perl

open L,"ResponseTeam.txt";
while(<L>)
{ s/[\s=]//g;
  print;
}
