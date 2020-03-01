#!/usr/bin/perl
require "subMemberDB.pl";

my @new=&arrayTXTfile( "DB/reorder.csv.d");
#print "@new";
open L,"DB/MasterDB.csv.test.csv";
open L1,">DB/MasterDB.reordered.csv";
my $lastAddrees;
my $cnt=0;
while(<L>)
{ @col= &STRG4String($_) ;
  my $vAddress=&vAddressFromArray(
    $col[$DBcol{StreetName}],$col[$DBcol{StreetAddress}],$col[$DBcol{subAddress}] );
  if(($cnt++ ge 2) and ($vAddress ne $lastAddress))
  { #print L1 "=\n";
  }
  $lastAddress=$vAddress;

  my @newcol;
  for(my $i=0;$i<=$#col;$i++)
  { $newcol[$i]= $col[$DBcol{$new[$i]}];
  }
  print L1 '"',join('","', @newcol),'"',"\n";
}




