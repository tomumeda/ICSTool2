#!/usr/bin/perl
# Print MemberDB.csv from DB/DBmaster.db
do "subMemberDB.pl";
#############################
#die "$ICSdir";
#############################
&TIE( @DBname );
open L3,">$file_csv.test";
#&PrintCol( @DBmasterColumnLabels ); # NOW included in .db as first record
@recn=sort {$a <=> $b} keys %DBmaster ;

for($i=0;$i<=$#recn;$i++)
{ $rec=$DBmaster{$recn[$i]};
  $rec=~s/\n//g;
  @col=split(/\t/, $rec);
  $#col=$#DBmasterColumnLabels;
  print ">>$i:$rec ($#col) \n";
  &PrintCol(@col);
}

