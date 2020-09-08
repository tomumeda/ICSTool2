#!/usr/bin/perl
use lib ("/Users/Tom/Sites/ICSTool/Lib", "/home/tom/Sites/ICSTool/Lib");
require "subMemberDB.pl";

my @files=sort <DB/Downloads/MasterDB.*.csv>;
my $CSVfile = $files[-2];
open L,"$CSVfile";
open L1,">DB/diffMasterCSV.out";
open L2,">DB/diffMasterCSV.diff.txt";

&TIE( @DBname );
################################
print L2 "Differences between 
MasterDB (DB) to $CSVfile (CSV)\n";

my @notInDB=();
my @line=();
while(<L>)
{ 
  next if( ($. < 3) );	# skip Header
  my @col= &STRG4String($_) ;
  my $firstname=$col[$DBcol{FirstName}];
  my $lastname=$col[$DBcol{LastName}] ;
  my %dbname=&FindDBName("$firstname,$lastname");
  my $rec=$dbname{"$lastname	$firstname"};

  my @dbcol=&DBmasterInfo($rec);
  my $firstnameDB="";
  my $lastnameDB="";
  my $involvementDB="";

  $firstnameDB=$dbcol[$DBcol{FirstName}];
  $lastnameDB=$dbcol[$DBcol{LastName}] ;
  $involvementDB=$dbcol[$DBcol{InvolvementLevel}] ;

  my @diffQ=();
  my $val,$valDB;
  if( ($firstnameDB eq $firstname and $lastnameDB eq $lastname )
      and $involvementDB =~ m/Active/ )
  { # CHECK for differences 
    for(my $i=1;$i<=$#DBmasterColumnLabels;$i++) # ignores Timestamp
    { my $label=$DBmasterColumnLabels[$i];
      $val= $col[$DBcol{$label}];
      $val=~s/[\r\n]/ /g;
      $val=~s/;//g;
      $valDB= $dbcol[$DBcol{$label}];
      $valDB=~s/[\r\n]/ /g;
      $valDB=~s/;//g;
      if( $val ne $valDB )
      { push @diffQ,$label;
      }
    }
    ##############################3
    if( $#diffQ > -1 ) 	# there are changes
    { print L2 " \n=========== \n$firstname, $lastname ("
      , $dbcol[$DBcol{Timestamp}],")";
      foreach my $label (@diffQ)
      { $val= $col[$DBcol{$label}];
	$valDB= $dbcol[$DBcol{$label}];
	$val=~s/[\r\n]/ /g;
	$valDB=~s/[\r\n]/ /g;
	print L2 "\n ---$label---\n\t DB: "
	,$valDB
	,"\n\tCSV: "
	,$val
      }
      print L2 "\n";
    }
    elsif( !$firstnameDB or !$lastnameDB )
    { 
      push @notInDB,"$lastname	$firstname @diffQ";
      print L1 "\nnotInDB: $rec, $lastname	$firstname, $involvementDB, @diffQ";
    }
  }
}

print L2 "\n\n====Names not in DB===\n",join("\n",sort(@notInDB));



