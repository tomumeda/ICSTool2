#!/usr/bin/perl
require "subCommon.pl";
do "subMemberDB.pl";
$file_csv="DB/MasterDB.csv"; # OUTPUT name
open L1,">xoutQ";
open L2,">xout";
open Lduplicate,">csvFix.duplicate.names";
open L0,"$file_csv.20190801"; # input file -- change each month
open L3,">$file_csv"; # output file ; do not change L3
############################
$lineSep="n";
while(<L0>)
{ #print;
  #die "ONE LINE:",$_;
  $lineSep="rn" if($_=~m/\r/);

  chop; #TEST for openoffice
  
  push(@lines,$_);
}
# die "lineSep: ($lineSep)";
# die "LINES: $#lines: $lines[$#lines]";

############################
my $cnt=0;
for($il=0;$il<=$#lines;$il++)
{ $line=$lines[$il];
  #	line separators:  \r\n for GoogleSheet.csv
  #	line separators:  \n for OpenOffice.csv
  if($lineSep eq "rn")
  { while($line !~ /\r\n$/ and $il<$#lines ) # join lines without \r\n
    { #die "$il: $line\n";
      $line=~s/\n$//;
      $line.=$lines[++$il];
    }
    $line=~s/\r//g;
  }
  #$line=~s/(\n*)$//;
  
  #test portion
  @rec= &STRG4String($line) ;
  print L2 "\n>> $cnt ::\n";;
  print L1 join("==",@rec),"==\n";
  # change LastChanged data to Timestamp
  if($rec[$DBcol["Timestamp"]] and $rec[$DBcol["Timestamp"]]!~/Timestamp/ )
  { print "\n$il ::Timestamp:",$rec[$DBcol{Timestamp}]," ",$DBcol{LastChanged}," ",$rec[$DBcol{LastChanged}];
    $rec[$DBcol{LastChanged}]=$rec[$DBcol{Timestamp}];
  }
  # diagnostic output
  for($i=0;$i<=$#rec;$i++)
  { print L2 "$DBmasterColumnLabels[$i] : $rec[$i] \n";
  }
  $name="$rec[$DBcol{LastName}].$rec[$DBcol{FirstName}]";
  #print $name,"\n";
  $namecnt{$name}++;
  # output new csv portion
  &PrintCol(@rec);
  $line=join(",",@rec);
  $cnt++;
  #if($cnt>3){ die; }
}
foreach $name (keys %namecnt)
{ if($namecnt{$name} >1)
  { print "\nDUPLICATE NAME $name : $namecnt{$name}";
    print Lduplicate "DUPLICATE NAME $name : $namecnt{$name} \n";
  }
}
