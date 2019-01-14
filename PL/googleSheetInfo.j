#!/usr/bin/perl
#
require "subCommon.pl";
# generates DB/DBmember.db from MemberDB.csv
$file_csv="DB/googleSheet.csv";
###
open L,"$file_csv" || die "Can't open $file_csv";
open L1,">$file_csv.Header";
#########################
$tmp=<L>;	#Print Header
$tmp=~s/\s+//g;

@rec= &STRG4String($tmp) ;
$tmp=join("\t",@rec);
print $tmp;
print L1 "$tmp\n"; close L1;

$DBmasterColumnLabels=join("\n",@rec);
open L1,">DB/DBmasterColumnLabels.txt";
print L1 $DBmasterColumnLabels;
#########################
open L1,">$file_csv.Descriptor";
$tmp=<L>;	
@rec= &STRG4String($tmp) ;
$tmp=join("\n",@rec);
die "XXXX .csv file not in proper order XXX" if($rec[0] ne "0");
print $tmp;
print L1 "$tmp\n"; close L1;
#########################

