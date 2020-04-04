#!/usr/bin/perl
require "subMemberDB.pl";

my @new=&arrayTXTfile( "DB/reorder.csv.d");
#print "@new";
open L,"DB/Downloads/MasterDB.20200404125808.csv";
open L1,">DB/MasterDB.reordered.csv";
my $lastAddrees;
my @line=();
$cnt=0;
while(<L>)
{ $cnt++;
  @col= &STRG4String($_) ;
  my $vAddress=&vAddressFromArray(
    $col[$DBcol{StreetName}],$col[$DBcol{StreetAddress}],$col[$DBcol{subAddress}] );

  next if( ($col[$DBcol{InvolvementLevel}] eq "No Involvement" ) and ($cnt > 2) );

  #print ">>$cnt,$col[$DBcol{InvolvementLevel}]>>",
  #$col[$DBcol{InvolvementLevel}] eq "No Involvement",">>",
  #($col[$DBcol{InvolvementLevel}] =~ m/"No Involvement"/i ),
  #"<<\n" ;

  if(($cnt > 2) and ($vAddress ne $lastAddress))
  { #print L1 "=\n";
  }
  $lastAddress=$vAddress;

  my @newcol;
  for(my $i=0;$i<=$#col;$i++)
  { $newcol[$i]= $col[$DBcol{$new[$i]}];
  }
  if($cnt<=2)
  { print L1 '"',join('","', @newcol),'"',"\n";
  }
  else
  { push(@line,'"'.join('","', @newcol).'"');
    print '"'.join('","', @newcol).'"',"\n";
  }
}
print L1 join("\n",sort(@line));

