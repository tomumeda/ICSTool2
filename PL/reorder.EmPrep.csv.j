#!/usr/bin/perl
require "subMemberDB.pl";

my @new=&arrayTXTfile( "DB/reorder.csv.d");
#print "@new";
open L,"DB/Downloads/MasterDB.20200701070101.csv";
open L1,">DB/MasterDB.reordered.csv";
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

  my @newcol;
  for(my $i=0;$i<=$#col;$i++)
  { $newcol[$i]= $col[$DBcol{$new[$i]}];
  }
  if($cnt<=2)
  { print L1 '"',join('","', @newcol),'"',"\n";
  }
  else
  { push(@line,'"'.join('","', @newcol).'"');
    #	print '"'.join('","', @newcol).'"',"\n";
  }
}
my @out=();
@line=sort(@line);
$out[0]=$line[0];
for(my $i=1;$i<=$#line;$i++)
{ 
  my @last=&STRG4String( $line[$i-1] ); 
  my @next=&STRG4String( $line[$i] ); 
  # die "@next\n XXX \n@last XXX ";
  if( $last[0] ne $next[0] or $last[1] ne $next[1] or $last[2] ne $next[2] 
  )
  { push(@out,"");
  }
  #	print "$line[$i]\n";
  push(@out,$line[$i]);
}


print L1 join("\n",@out);

