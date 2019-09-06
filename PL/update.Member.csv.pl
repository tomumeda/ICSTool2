#!/usr/bin/perl
# summary:
# 	copy $file_csv to $file_csv.last
# 	read $file_csv
#	inquire on member name
#	display form populated by member info
#	save $file_csv
#use strict;
use warnings;
#use CGI;
#use CGI::Carp qw(fatalsToBrowser); # Remove this in production
# my $q = new CGI;
require "subCommon.pl";
require "subCSVmember.pl";
#
$DBname="MasterDB.test";
## generates DB/DBmember.db from MemberDB.csv
$file_csv="DB/$DBname.csv";
#############
open L,"$file_csv" || die "Can't open $file_csv";
open L1,">$file_csv.Header";
#########################
# First record
#########################
$tmp=<L>;	#Print Header
@columnLabels=@rec= &STRG4String($tmp) ;
#for(my $i=0;$i<=$#columnLabels;$i++)
#{ $DBcol{$columnLabels[$i]}=$i;}

$tmpN=join("\n",@rec);
$tmpT=join("\t",@rec);
print $tmpT;
print L1 "$tmpN\n"; close L1;
#########################
# Second record
#########################
$tmp=<L>;	
open L1,">$file_csv.Descriptor";
@columnDesc=@rec=&STRG4String($tmp) ;
$tmp=join("\t",@rec);
die "XXXX .csv file not in proper order XXX" if($rec[0] ne "0");

for($i=0;$i<=$#columnLabels;$i++)
{ print L1 "$columnLabels[$i]\t$columnDesc[$i]\n"; 
}
close L1;
###################################
@dataDescrip=split(/\t/,$tmp);
######################### DBs used for this program
@DBs=("$DBname.master","$DBname.NameRec");
#########################
&TIE( @DBs );
my $cnt=0;
while(<L>)
{ #print;
  @rec= &STRG4String($_) ;
  #print ">> @rec \n\n";
  $LastNameFirstName="$rec[1].$rec[2]";
  &UpdateDB($cnt,@rec);
  $cnt++;
}
# 
@MemberNames=keys %{$DBs[1]};
die ">> ",join("\n",@MemberNames);
# Query member name
#######################
#########################################################

sub printForm
{ my($q)=@_;

  print $q->start_form(
            -name => 'main',
            -method => 'POST',
        ); 
	
    print $q->start_table;

       print $q->Tr(
         $q->td("$columnLabels[1]: "),
         $q->td(
           $q->textfield(-name => "$columnLabels[0]", -size => 50)
         )
       );

       print $q->Tr(
         $q->td("$columnLabels[2]: "),
         $q->td(
           $q->textfield(-name => "$columnLabels[2]", -size => 50)
         )
       );

       print $q->Tr(
         $q->td("$columnLabels[3]: "),
         $q->td(
           $q->textfield(-name => "$columnLabels[3]", -size => 50)
         )
       );

       print $q->Tr(
          $q->td("$columnLabels[4]: "),
          $q->td(
            $q->radio_group(
              -name => 'age',
              -values => [
                  '0-12', '13-18', '18-30', '30-40', '40-50', '50-60', '60-70', '70+'
              ],
              -rows => 4,
            )
          )
        );

    print $q->end_table;
  print $q->end_form;
} 

