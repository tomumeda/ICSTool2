#!/usr/bin/perl
use lib ("/Users/Tom/Sites/ICSTool/Lib", "/home/tom/Sites/ICSTool/Lib");
require "subMemberDB.pl";

my @files=sort <DB/Downloads/MasterDB.*.csv>;

my $CSVfile = $files[-1];
open L,"$CSVfile";
open L1,">DB/diffMasterCSV.out";

&TIE( @DBname );
################################

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
  $firstnameDB=$dbcol[$DBcol{FirstName}];
  $lastnameDB=$dbcol[$DBcol{LastName}] ;
  $involvementDB=$dbcol[$DBcol{InvolvementLevel}] ;

  if($involvementDB =~ /Active/)
  { my @diffQ=();
    for(my $i=1;$i<=$#DBmasterColumnLabels;$i++)
    { my $label=$DBmasterColumnLabels[$i];
      if( $col[$DBcol{$label}] ne $dbcol[$DBcol{$label}])
      { push @diffQ,$label;
      }
    }
    if( $#diffQ > -1 )
    { print " \n=========== \n$firstname, $lastname ";
# -> $involvementDB -> $firstnameDB, $lastnameDB:
      #      @diffQ \n";
      foreach my $label (@diffQ)
      { 
	print "\n$label:\n\tDB: ",$dbcol[$DBcol{$label}],"\n\tCSV: ",$col[$DBcol{$label}];
      }
    }
  }
  else
  { push @notInDB,"$lastname	$firstname";
  }

  if($. >80)
  { #print join(" ",@DBmasterColumnLabels);
    print "\n\n====Names not in DB:\n",join("\n",@notInDB);
    die;
  }

}


