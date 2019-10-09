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
@header= &STRG4String($tmp) ;
$header=join("\t",@header); print $header;
print L1 "$header\n"; close L1;

open L1,">$file_csv.Header";
print L1 join("\n",@header),"\n" ; close L1;
#########################
$descriptor=<L>;	# 	second record must be descriptor	
@descriptor=&STRG4String($descriptor);
print join("\n=",@descriptor),"=";

die "XXXX .csv file not in proper order XXX" if($descriptor[0] ne "0");

open L1,">$file_csv.Descriptor";
for($i=0;$i<=$#header;$i++)
{ print L1 "$header[$i]\t$descriptor[$i]\n";
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


