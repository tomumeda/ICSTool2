#!/usr/bin/perl
#!/usr/local/ActivePerl-5.24/bin/perl

require "subCommon.pl";
# generates DB/DBmember.db from MemberDB.csv
chmod 0777,"DB";
unlink <DB/DB*.db>;
$file_csv="DB/MasterDB.csv";
###
open L,"$file_csv" || die "Can't open $file_csv";
open L1,">$file_csv.Header";
#########################
$tmp=<L>;	#Print Header
@rec= &STRG4String($tmp) ;
$tmp=join("\t",@rec);
print $tmp;
print L1 "$tmp\n"; close L1;
#########################
open L1,">$file_csv.Descriptor";
$tmp=<L>;	
@rec= &STRG4String($tmp) ;
$tmp=join("\t",@rec);
die "XXXX .csv file not in proper order XXX" if($rec[0] ne "0");
print $tmp;
print L1 "$tmp\n"; close L1;
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


