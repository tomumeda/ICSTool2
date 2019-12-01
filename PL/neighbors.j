#!/usr/bin/perl
require "subCommon.pl";

$DB="ParcelAddressByLonLat";
&TIE("$DB");
$DBaddress="MapStreetAddressLL";
&TIE("$DBaddress");
$DBneighbors="Neighbors";
&TIE("$DBneighbors");

@latlon=sort keys %{"$DB"};
@addresses=sort keys %{"$DBaddress"};

for(my $iaddresses=0;$iaddresses<=$#addresses;$iaddresses++)
{ my $address=$addresses[$iaddresses]; 
  my ($lat,$lon,$other)=split(/\t/,${"$DBaddress"}{$address});
  my $latlonref=join("\t",($lat,$lon));
  my $addressValue=join("\t",($address,$latlonref));
  #print "\n>>$addressValue";

  my $value=$addressValue.";" ;
  for(my $i=0;$i<=$#latlon;$i++)
  { $latlon=$latlon[$i];
    my $newvalue= join("\t",(${"$DB"}{$latlon},$latlon));
    if(&distll($latlon,$latlonref)<.0005
	and $newvalue ne $addressValue
    )
    { #print "\n>>",join("\t",(${"$DB"}{$latlon},$latlon)) ;
      $value.=$newvalue.";" ;
    }
  }
  print "\n\n$address >> $value";
  ${"$DBneighbors"}{$address}=$value;
}

sub distll	#LATLON distance in degrees
{ my ($ll1,$ll2)=@_;
  ($ll11,$ll12)=split(/\t/,$ll1);
  ($ll21,$ll22)=split(/\t/,$ll2);
  $ll1=($ll11-$ll21)/cos(37/180 *3.14159);
  $ll2=($ll12-$ll22);
  my $dist=sqrt( $ll1*$ll1+$ll2*$ll2);
}
 
