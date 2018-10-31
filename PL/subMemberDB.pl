#!/usr/bin/perl
require "subCommon.pl";
# .csv 
$file_csv="DB/xMasterDB.csv";
# DBmaster column definitions # SHOULD this be compatible with MasterDB.csv??
$DBmasterColumnLabels=<<___EOR;
Timestamp
LastName
FirstName
StreetName
StreetAddress
subAddress 
HomePhone
CellPhone
Email Address
OtherContactInfo
SkillsForEmergency
CERTClasses
BirthYear
EmergencyContactInfo
SpecialNeeds
Visitors
Pets
EmergencyEquipment
GasShutOffValveInfo 
Comments
InactiveMember
DivisionBlock
___EOR
$DBmasterColumnLabels=~s/\(.*\)//g; # remove comments, i.e., ()
$DBmasterColumnLabels=~s/ *//g; # remove blanks
@DBmasterColumnLabels=split(/\n/,$DBmasterColumnLabels); # get from MasterDB

for(my $i=0;$i<=$#DBmasterColumnLabels;$i++)
{ $DBcol{$DBmasterColumnLabels[$i]}=$i;
}

@street=map { $_=~ s/AddressesOn\///;$_;} <AddressesOn/*>;
$InputExamples=<<___EOR;
SpecialNeeds		Mobility(wheelchair), Child( Bob (1 yrs) )
SkillsForEmergency	FirstAid, SearchAndRescue, FireSuppression, Communications, ShelterLogistics
Pets			Cat(Tabby,name:Pancake), Dog(Retriever)
EmergencyEquipment	Ladder(12 ft), Shelter(4 person), Cribbing, Tools(crowbar)
Visitors		HouseKeeper(Paul on Thursday)
Email			for EmPrep communications
InactiveMember		DO NOT DISPLAY
___EOR
@InputExamples=split(/\n/,$InputExamples);
foreach my $entry (@InputExamples)
{ $entry=~s/\t{2,}/\t/g;
  my ($label,$example)=split(/\t/,$entry);
  $InputExamples{$label}=$example;
}
#     Data items will have format Label(attribute), e.g. Mobility(wheelchair)
#
######
# The following are definitions carried over from ./EMPREP/Resources
# subMemberDB.pl.  May need reorganization to be generally
# compatible with it.
# But for now we will copy code for this development.
# Define name and label arrays
@DBname=&MakeArray("DBmaster, DBrecName, DBrecAddress, DBrecSkills, DBSpecialNeeds, DBAddressOnStreet, DBrecEmergencyEquipment, DBcontactInfo, DBrecSpecialNeeds, DBrecPets, DBrecVisitors");
# Pointer files into DBMaster
#     DBrec____ -> pointer into DBMaster for ____. 
#     	A search should retrieve all records that satisfy criteria.
#
#     DBrecName -> {LastName,FirstName}
#     DBrecAddress -> {StreetName=StreetAddress=subAddress}
#     DBrecSkill -> {Skills:{FirstAid,Organizational,SearchRescue,FireSuppression,Communications}}
#     DBSpecialNeeds -> %{Street=Address}->{subAddress,SpecialNeeds,Pets,Visitors}
#     DBAddressOnStreet -> %{Street} -> @Address 	#parcel address
#     DBEmergencyEquipment -> %{} -> {Street,Address,subAddress}
# tab's separate items within {}
################################################
@DBrecLabels=&MakeArray("DBmaster, DBrecName, DBrecSkills, DBrecSpecialNeeds,  DBAddressOnStreet");

# returns an array from a quoted CSV record 
sub XXCSVtoArray
{ my $line=$_[0];
  local $qcnt,$item,@items,$i,$chr,@chrs;
  $qcnt=0; $#chrs=-1; $#items=-1;
  for($i=0;$i<=length($line);$i++)
  { $chr=substr($line,$i,1);
    push(@chrs,$chr);
    if($chr=~'"'){ $qcnt++; }
    if( $chr=~"," && ($qcnt==0||$qcnt==2) && length(@chrs)>0 )
    { $item=join("",@chrs);
      chop($item);
      push(@items,$item);
      $qcnt=0; $#chrs=-1;
    }
  }
  push(@items,join("",@chrs));
  return @items;
}

# merges $value into ${$type}{$key}
sub MergeKeyValue
{ my ($DB,$key,$value)=@_;
  return if(!$key or !$value); # TEST if this disrupts program
  my @tmp=split(/\t/,${$DB}{$key});
  #print "$DB,$key,$value<br>\n";
  push @tmp,$value;
  @tmp=&uniq(@tmp);
  my $tmp=join("\t",@tmp);
  ${$DB}{$key}=$tmp;
}

# Updates DB master and pointer DB's from one record reference into DBmaster
# The names in $DBcol correspond to Spreadsheet column names 
sub UpdateDB
{ my ($dbrecno,@col)=@_;
  my $FirstName=$col[$DBcol{FirstName}]; 
  my $LastName= $col[$DBcol{LastName}];
  my $StreetName= $col[$DBcol{StreetName}];
  my $StreetAddress= $col[$DBcol{StreetAddress}];
  my $subAddress= $col[$DBcol{subAddress}];
  my $HomePhone= $col[$DBcol{HomePhone}];
  my $CellPhone= $col[$DBcol{CellPhone}];
  my $EmailAddress= $col[$DBcol{EmailAddress}];
  my $SkillsForEmergency= $col[$DBcol{SkillsForEmergency}];
  my $SpecialNeeds=$col[$DBcol{SpecialNeeds}];
  my $Pets=$col[$DBcol{Pets}];
  my $Visitors=$col[$DBcol{Visitors}];
  my $EmergencyEquipment=$col[$DBcol{EmergencyEquipment}];
  my $InactiveMember=$col[$DBcol{InactiveMember}];
  my $dbrec=join("\t",@col) ;

# XX@DBname=&MakeArray("DBmaster, DBrecName, DBrecAddress, DBrecSkills, DBSpecialNeeds, DBAddressOnStreet, DBrecEmergencyEquipment, DBcontactInfo, DBrecPets, DBrecVisitors");

  ${"DBmaster"}{$dbrecno}=$dbrec; # add complete record to masterDB
  # add to pointer DBs into DBmasster by following keys
  if($InactiveMember!~/yes/i)
  { 
    &MergeKeyValue("DBrecName","$LastName\t$FirstName",$dbrecno);
    &MergeKeyValue("DBrecAddress","$StreetName=$StreetAddress=$subAddress",$dbrecno); 
    &MergeKeyValue("DBAddressOnStreet","$StreetName",$StreetAddress); 
    &MergeKeyValue("DBrecSkills","$SkillsForEmergency",$dbrecno);
    &MergeKeyValue("DBrecEmergencyEquipment","$EmergencyEquipment",$dbrecno); 
    &MergeKeyValue("DBrecSpecialNeeds","$SpecialNeeds",$dbrecno); 
    &MergeKeyValue("DBrecPets","$Pets",$dbrecno); 
    &MergeKeyValue("DBrecVisitors","$Visitors",$dbrecno); 

    # add contact info for StreetName=StreetAddress=subAddress
    my $str="";
    if($HomePhone) { $str.="HomePhone:$HomePhone\n"; }
    if($CellPhone) { $str.="CellPhone:$CellPhone\n"; }
    if($EmailAddress) { $str.="EmailAddress:$EmailAddress\n"; }
    if($str ne "")
    { $str="($LastName,$FirstName)\n$str";
      &MergeKeyValue("DBcontactInfo","$StreetName=$StreetAddress=$subAddress",$str);
    }
    # add Special consideration for StreetName=StreetAddress=subAddress
    my $name="FirstLastName:$FirstName:$LastName\t";
    $str="";
    if($SpecialNeeds) { $str.="SpecialNeeds:$SpecialNeeds\t"; }
    if($Pets) { $str.="Pets:$Pets\t"; }
    if($Visitors) { $str.="Visitors:$Visitors\t"; }
    if($str ne "")
    { &MergeKeyValue("DBSpecialNeeds","$StreetName=$StreetAddress=$subAddress","$name$str");
    }

  }
}

# 
# Member Info array from DBmaster index.
sub DBmasterInfo
{ my @ids=@_;
  my $id = 1*$ids[0]; #only first id
  my $rec=$DBmaster{ $id };
  my @col=split(/\t/, $rec);
  return(@col);
}

# return "LastName.FirstName" string from DBmaster index
sub DBname
{ my ($index)=@_;
  my @col=&DBmasterInfo($index);
  my $FirstName=$col[$DBcol{FirstName}]; 
  my $LastName= $col[$DBcol{LastName}];
  return("$LastName.$FirstName");
}

# Print (in HTML format)
# Contact Info from an array of indices into DBmaster.
sub PrintContactInfo
{ my @ids=@_;
  foreach my $id (@ids)
  { $id*=1; # need number
    my $rec=$DBmaster{ $id };
    my @col=split(/\t/, $rec);
    next if( $col[$DBcol{InactiveMember}] =~ /yes/i );
    print "($id) : ",
    " $col[$DBcol{FirstName}] $col[$DBcol{LastName}] :: ",
    " $col[$DBcol{Address}] $col[$DBcol{Street}] $col[$DBcol{subAddress}] ",
    ":: Phone( $col[$DBcol{Phone}] ) ",
    ":: Cell( $col[$DBcol{Cell}] ) ",
    ":: Email( $col[$DBcol{Email}] )",
    ":: Visitors( $col[$DBcol{Visitors}] )",
    "<br>\n" ;
  }
  return(1);
}

# finds in DBrecName from string match arguements.  
# Can be multiple test with separators
# Returns hash{name}-->recNum)
sub FindMemberName
{ my $search=@_[0];
  my @search=split(/[\s,;]/,$search);
  my $i,%foundnames;
  my @name=keys %DBrecName;
  for($i=0;$i<=$#name;$i++)
  { if( &AllMatchQ($name[$i],@search)==1 )
    { $foundnames{$name[$i]}=$DBrecName{$name[$i]} ; 
    }
  }
  return(%foundnames);
}

# finds ActiveMember in DBrecName from string match arguements.  
# Can be multiple test with separators
# Returns a hash of DBrecNames-->recNum<TAB>recNum...)
sub FindDBName
{ my $search=@_[0];
  my @search=split(/[\s,;]/,$search);
  my $i;
  my %foundnames=();
  #delete $foundnames{keys %foundnames};
  #####??????????
  my @name=keys %DBrecName;
  for($i=0;$i<=$#name;$i++)
  { 
    if( &AllMatchQ($name[$i],@search)==1 )
    { 
      my $tname=$name[$i];
      # die &AllMatchQ( $tname,@search ),":", &ActiveMember( $DBrecName{$tname}),":",length($DBrecName{$tname}),":",$tname;
      if( &AllMatchQ( $tname,@search ) and &ActiveMember( $DBrecName{$tname}) )
      { $foundnames{$tname}=$DBrecName{$tname};
      }
    }
  }
  # die (">>FindDBName:@search >>??  ??>> ",keys %foundnames);
  return(%foundnames);
}

# lists names found for $FindByName for selection. Returns rec#.
sub MemberNamesFound
{ print $q->h2("Names found for ($FindByName)");
  my @rec=();
  my $i,%label,$name,%result; 
  %result=&FindDBName( $FindByName );
  foreach $name (keys %result)
  { my @masterrecno=split(/\t/,$result{$name});
    for($i=0;$i<=$#masterrecno;$i++)
    { my $recno = $masterrecno[$i];
      next if( ! &ActiveMember($recno) );
      my @col=split( /\t/,  $DBmaster{ $recno } );
      $label{ $recno}="@col[0,1] --->(@col[2,3])" ;
      push(@rec,$recno);
    }
  }
  print 
    $q->radio_group(-name=>'SelectName', -values=>[ @rec ],
    -linebreak=>'yes', -default=>$rec[0],
    -labels=>\%label), "<P>";
}

# returns (LastName,FirstName) or () depending upon ActiveMember or InactiveMember
sub ActiveMember 
{ my ($id) = @_;
  my $rec=$DBmaster{ $id };
  # die "$id, $rec";
  my @col=split(/\t/, $rec);
  if( $col[$DBcol{InactiveMember}] =~ /yes/i ) { return () }
  else { return ( $col[$DBcol{LastName}],$col[$DBcol{FirstName}] ) }
}

# returns Lastname\tFirstname from Lastname.Firstname 
sub dotName2LastFirst
{ my $name=$_[0];
  $name =~s/\./\t/;
  return $name;
}

# Set DB variable from  DBmaster referenced by $rec
sub SetDBrecVars
{ my $rec=@_[0];
  my @rec=split(/\t/,$DBmaster{$rec});
  for(my $i=0;$i<=$#DBmasterColumnLabels;$i++)
  { my $label=$DBmasterColumnLabels[$i];
    ${$label}=$rec[$DBcol{$label}];
    # if(${"LastName"} eq "Umeda" ) { print "$label ${$label}\n"; }
  } 
  # if(${"LastName"} eq "Umeda" ) { die "@rec"; }
}

# Updates DB master from one record reference into DBmaster
sub WriteDBrecVars
{ my $rec=@_[0];
  my @rec=();
  for(my $i=0;$i<=$#DBmasterColumnLabels;$i++)
  { my $label=$DBmasterColumnLabels[$i];
   $rec[ $DBcol{$label} ]=${$label};
  } 
  $DBmaster{$rec}=join("\t",@rec);
}

