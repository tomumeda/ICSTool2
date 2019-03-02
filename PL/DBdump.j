#!/usr/bin/perl
require "subCommon.pl";
require "subDamageReport.pl";

#&TIE(DBrecSpecialNeeds);
$DB="DBrecPets";
$DB="DBrecVisitors";
$DB="DBrecEmergencyEquipment";
$DB="DBrecSpecialNeeds";
$DB="DBSpecialNeeds";

$DB="ParcelStreetAddresses";
$DB="ParcelInfoByAddress";
$DB="AddParcelAddress";
$DB="ParcelLonLatByAddress";

$DB="DBAddressOnStreet";

$DB="DBrecAddress";
$DB="MapStreetAddressLLEmPrep";
$DB="MapStreetAddressPIXEmPrep";
$DB="MapStreetAddress";
$DB="NoParcelAddressLL";
$DB="MapStreetAddressLL";
$DB="DBMaster";
&TIE($DB);
@key=sort keys %{$DB};
for(my $i=0;$i<=$#key;$i++)
{ print "========\n";
  print ">>$key[$i]:\n >",join("\n >",split(/\t/,${$DB}{$key[$i]})),"\n";
}
 






