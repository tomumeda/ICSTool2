#!/usr/bin/perl

require "subCommon.pl";
# generates DB/DBmember.db from MemberDB.csv
chmod 0777,"DB";
unlink <DB/DB*.db>;
$file_csv="DB/MasterDB.csv";
###
open L,"$file_csv" || die "Can't open $file_csv";
open L1,">$file_csv.Header";
#########################
$tmp=<L>;	 #Print Header 
$tmp=~s/ //g;	 #expect NO spaces in Header
@rec= &STRG4String($tmp) ;
$tmp=join("\t",@rec);
print $tmp;
print L1 "$tmp\n"; close L1;

open L1,">$file_csv.Header.txt";
print L1 join("\n",@rec),"\n" ; close L1;
@header=@rec;

#########################
$descriptor=<L>;	
@rec=&STRG4String($descriptor);
print "$descriptor";

die "XXXX .csv file not in proper order XXX" if($rec[0] ne "0");

$tmp=join("\t",@rec);


@description=@rec;
#	die $tmp;

open L1,">$file_csv.Descriptor";
for($i=0;$i<=$#header;$i++)
{ print L1 "$header[$i]\t$description[$i]\n";
}
close L1;
#########################
# needs to be here: relies on above code
do "subMemberDB.pl";
#########################
&TIE( @DBname );
my $cnt=0;
while(<L>)
{ print;
  @rec= &STRG4String($_) ;
  print ">> @rec \n\n";
  &UpdateDB($cnt,@rec);
  $cnt++;
}
&UNTIE( @DBname );
chmod 0666,<DB/*>;


