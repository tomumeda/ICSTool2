#!/usr/bin/perl
require "subCommon.pl";
#
$test{"a"}="2";

$test{"a"}=&tabListAdd($test{"a"},4);
print "\n",$test{"a"};
print "\n",&tabListDelete($test{"a"},2);

#
# tabListDelete delete $item in $tabList[tab separated list]
# returns [tab separated list]
#
sub tabListDelete
{ my ($tabvar,$item)=@_;
  my @tab=split(/\t/,$tabvar);
  @tab=&deleteElement($item,@tab);
  my $out=join("\t",@tab);
  $out;
}
#
# tabListAdd adds $item to $tabList[tab separated list]
# returns [tab separated list]
#
sub tabListAdd
{ my ($tabvar,$item)=@_;
  my @tab=split(/\t/,$tabvar);
  push(@tab,$item);
  my $out=join("\t",@tab);
  $out;
}
