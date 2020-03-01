#!/usr/bin/perl
# List {people} by Address.
require "subMemberInformation.pl";
&initialization;
&TIE("DBmaster");
&TIE("Neighbors");
##################################################3
my $vAddress="Le Roy Ave=1643=";
my $neighbors=$Neighbors{$vAddress};
my @addressesLL=split(/;/,$neighbors);
my @addresses=map { @_=split(/\t/,$_);$_[0] } @addressesLL;
my @LL=map { my @a=split(/\t/,$_);"$a[1]\t$a[2]" } @addressesLL;
my @LLref=split(/\t/,$LL[0]);

for(my $i=0;$i<=$#addressesLL;$i++)
{ my @names=&WhoIsAtAddress($addresses[$i]);
  #print "\n\n$addresses[$i], $LL[$i]";
  my @LLadd=split(/\t/,$LL[$i]);
  my $dd= sqrt( 
    ($LLadd[0]- $LLref[0])**2+ 
    (($LLadd[1]- $LLref[1])/cos(37/180*3.14159))**2 );
  if($dd lt .0006)
  {
  print "\n$addresses[$i] , @LLadd, @LLref $dd";
}
  #$display{$addresses[$i]}= join("\n",@names);
};
#print "@addressesLL";

