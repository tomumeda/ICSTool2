#!/usr/bin/perl
##!/usr/local/ActivePerl-5.24/bin/perl
require "subCommon.pl";
do "subMemberDB.pl";
$file_csv="DB/MasterDB.csv"; # OUTPUT name
open L1,">xoutQ";
open L2,">xout";
open L0,"$file_csv.20181031"; # input file -- change each month
open L3,">$file_csv"; # output file ; do not change L3
############################
while(<L0>)
{ #print;
  push(@lines,$_);
}
#die "$#lines: $lines[$#lines]";
############################
my $cnt=0;
for($il=0;$il<=$#lines;$il++)
{ $line=$lines[$il];
  while($line !~ /\r\n$/ and $il<$#lines ) # join lines without \r\n
  { #die "$il: $line\n";
    $line=~s/\n$//;
    $line.=$lines[++$il];
  }
  $line=~s/\r//g;
  $line=~s/(\n*)$//;
  # standardize phone numbers 
  
  # $line=~s/(\d\d\d).(\d\d\d).(\d\d\d\d)/($1)$2-$3/g;
  # print "\n>>>>$cnt: ",$line;

  #test portion
  @rec= &STRG4String($line) ;
  print L2 "\n>> $cnt ::\n";;
  print L1 join("\t",@rec),"\n";
  # change LastChanged data to Timestamp
  if($rec[$DBcol["Timestamp"]] and $rec[$DBcol["Timestamp"]]!~/Timestamp/ )
  { print "\n$il ::Timestamp:",$rec[$DBcol{Timestamp}]," ",$DBcol{LastChanged}," ",$rec[$DBcol{LastChanged}];
    $rec[$DBcol{LastChanged}]=$rec[$DBcol{Timestamp}];
  }
  # diagnostic output
  for($i=0;$i<=$#rec;$i++)
  { print L2 "$DBmasterColumnLabels[$i] : $rec[$i] \n";
  }
  # output new csv portion
  &PrintCol(@rec);
  $line=join(",",@rec);
  $cnt++;
  #if($cnt>3){ die; }
}
