#!/usr/bin/perl
# Print list of street address
do "subMemberDB.pl";
#############################
&TIE( @DBname );
open L1,"|sort -u >StreetAddressList.d";
open L2,"|sort -u >StreetList.d";

@recn=sort {$a <=> $b} keys %DBmaster ;
for($i=0;$i<=$#recn;$i++)
{ $rec=$DBmaster{ $recn[$i] };
  @col=split(/\t/, $rec);
  # edit address  into vAddress form
  $col[$DBcol{"Street"}]=~/(\d*)\s*(.*)/;
  if($2) # edit old subAddress
  { 
    #print "\n:", $col[$DBcol{"Address"}];
#    $col[$DBcol{"Address"}]=~/(\d*)\s*(.*)/;
#    if($2) { $col[$DBcol{"Address"}]=~s/(\d*)\s*(.*)/$1=$2/; }
    print "\n:", $col[$DBcol{"Address"}];
  }
  print L1 "$col[$DBcol{'Street'}]\t$col[$DBcol{'Address'}]\t$col[$DBcol{'subAddress'}]\n";
  print L2 "$col[$DBcol{'Street'}]\n";
  #print L3 "$col[$DBcol{'Street'}]\t$col[$DBcol{'Street'}]\t$col[$DBcol{'subAddress'}]\n";
  if($col[$DBcol{'subAddress'}])
  { $address{$col[$DBcol{'Street'}]}.="$col[$DBcol{'Address'}]=$col[$DBcol{'subAddress'}]\t";
  }
  else
  { $address{$col[$DBcol{'Street'}]}.="$col[$DBcol{'Address'}]\t";
  }
}
foreach $street ( keys %address )
{ @address=split("\t",$address{$street});
  @address=&uniq(@address);
  $file="AddressesOn/$street";
  open L4,">$file";
  print L4 join("\n",@address),"\n";
}

