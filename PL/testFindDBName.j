#!/usr/bin/perl
# Print info from DB/DBmaster.db
# Use: testFindDBName.j <part of name>
require "subCommon.pl";
require "subMemberDB.pl";
@name=@ARGV;
#############################
$HOME=$ENV{HOME};
&TIE( @DBrecLabels );
#############################
print "For Name string: ",$name[0],"\n$BlockSeparator\n";
%names=&FindDBName($name[0]);
# die keys %names, values %names;


#POD mergeArrays merge two array specified by the name, e.g., a1,a2, i.e., no $
# The output is an array that is an interleaving of @a1 and @a2
sub XmergeArrays
{ my ($a1,$a2)=@_;
  # print "merge: $#{$a1} $#{$a2} \n";
  my @out=();
  my $io=0;
  for(my $i=0;$i<=$#{$a1};$i++)
  { $out[$io++]=${$a1}[$i];
    $out[$io++]=${$a2}[$i];
  }
  @out
}

@recn=values %names ;
foreach $name (keys %names)
{ $rec=$names{$name};
  # print "Name: $name >>$rec\n";
  @val=&DBmasterInfo($rec);
  @val=&XmergeArrays(DBmasterColumnLabels,val);
  for($i=0;$i<=$#val;$i=$i+2)
  { print "$val[$i]:\t\t$val[$i+1]\n";
  }
  print "$BlockSeparator\n";
}
