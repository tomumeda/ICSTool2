#!/usr/bin/perl
require "subCommon.pl";
require "subMemberDB.pl";

#$LastName="LastName";
#$FirstName="FirstName";
#$SkillsForEmergency="Fire Suppression, Aid, Search and Rescue, Communications, Archetect";
#############################
sub add2skill
{ my ($skill,$n)=@_;
  if( (my $i=&MemberQ(@SkillsForEmergency,$skill) ) ge 0 )
  { $skill[$n]=$SkillsForEmergency[$i];
    @SkillsForEmergency=&deleteArrayIndex($i,@SkillsForEmergency); 
  }
}
sub googleForm
{
$SkillsForEmergency=~s/\s*,\s*/,/g;
@SkillsForEmergency=split(/,/,$SkillsForEmergency);
undef @skill;
&add2skill("Fire Suppression",0);
&add2skill("First Aid",1);
&add2skill("Search and Rescue",2);
&add2skill("Communications",3);
if($#SkillsForEmergency ge 0)
{ $skill[4]=join(",",@SkillsForEmergency);
}

$form=<<___EOR;
https://docs.google.com/forms/d/e/1FAIpQLScpas-7EhJVfWUVG5HgScWJEkgtB6Cxjyk0cMOiPjZtfOLbiQ/viewform?usp=pp_url
&entry.1752260636=$LastName
&entry.359761687=$FirstName
&entry.1973771313=$StreetName
&entry.1645123309=$StreetAddress
&entry.1786188533=$subAddress
&entry.792241242=$DivisionBlock
&entry.1511866050=$HomePhone
&entry.569410759=$CellPhone
&entry.2695614=$EmailAddress
&entry.758588162=$OtherContactInfo
&entry.1177561975=$skill[0]
&entry.1177561975=$skill[1]
&entry.1177561975=$skill[2]
&entry.1177561975=$skill[3]
&entry.1177561975=__other_option__
&entry.1177561975.other_option_response=$skill[4]
&entry.1053611898=$CertClasses
&entry.383791721=$BirthYear
&entry.1003188876=$EmergencyContatInfo
&entry.1113678854=$SpecialNeeds
&entry.1119698127=$Visitors
&entry.788091415=$Pets
&entry.1693846876=$EmergencyEquipment
&entry.205920954=$GasShutOffValveInfo
&entry.1772334084=$Comments
&entry.1435760554=$InactiveMember
___EOR

$form=<<___EOR;
https://docs.google.com/forms/d/e/1FAIpQLSeB2Rb0b8B_itvKfdwsY-TydxA8qo9_J4wjK7K6Y_BqoS5IIg/viewform?usp=pp_url
&entry.1752260636=$LastName
&entry.359761687=$FirstName
&entry.1973771313=$StreetName
&entry.1645123309=$StreetAddress
&entry.1786188533=$subAddress
&entry.792241242=$DivisionBlock
&entry.1511866050=$HomePhone
&entry.569410759=$CellPhone
&entry.2695614=$EmailAddress
&entry.758588162=$OtherContactInfo
&entry.1177561975=$skill[0]
&entry.1177561975=$skill[1]
&entry.1177561975=$skill[2]
&entry.1177561975=$skill[3]
&entry.1177561975=__other_option__
&entry.1177561975.other_option_response=$skill[4]
&entry.1053611898=$CertClasses
&entry.383791721=$BirthYear
&entry.1003188876=$EmergencyContatInfo
&entry.1113678854=$SpecialNeeds
&entry.1119698127=$Visitors
&entry.788091415=$Pets
&entry.1693846876=$EmergencyEquipment
&entry.656293127=$ACAlertSignUp
&entry.205920954=$GasShutOffValveInfo
&entry.1772334084=$Comments
&entry.1435760554=$InactiveMember
___EOR

@form=split(/\n/,$form);
@form=map {($_ =~ m/=$/)?"":$_} @form;
@form=&deleteNullItems(@form);
return join("",@form);
}
#  Example string
sub dataListHTML
{ my $out;
  for(my $i=0; $i<$#DBmasterColumnLabels;$i=$i+1)
  { $label=$DBmasterColumnLabels[$i];
    $out.="$label: ${$label}\n";
  }
  $out;
}
# &dataListHTML;
1
