#!/usr/bin/perl
#
do "subCommon.pl";

$ICSdir=".";
$CSVmaster="$ICSdir/DB/MasterDB.csv";

sub deleteDuplicatesTab
{ my ($string)=@_;
  my @list=sort(split(/\t/,$string));
  for(my $i=0;$i<$#list;$i++)
  { if($list[$i] eq $list[$i+1])
    { $list[$i]="";
    }
  }
  @list=&deleteNullItems(@list);
  $string=join("\t",@list);
};

print $a="\tc\tb\tc\tc","\n";
print &deleteDuplicatesTab($a);
#print "\n",$a="a\tb\tc\td\te\t";
#print "\n",&deleteDuplicatesTab($a);
