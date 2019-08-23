#!/usr/bin/perl
require "subCommon.pl";
sub setDBvalues
{
  for(my $i=0;$i<=$#columnLabels;$i++) 
  { $DBcol{$columnLabels[$i]}=$i;
  }
###################################################################
}
#     Data items will have format Label(attribute), e.g. Mobility(wheelchair)
#
################################################
#@DBrecLabels=&MakeArray("DBmaster, DBrecName, DBrecSkills, DBrecSpecialNeeds,  DBAddressOnStreet");
@DBrecLabels=&arrayTXTfile("DB/DBrecLabels.txt");

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
  #@DBmasterColumnLabels
  for($i=0;$i<$#columnLabels;$i++)
  { ${$columnLabels[$i]}=$col[$DBcol{$columnLabels[$i]}]; 
  }
  my $dbrec=join("\t",@col) ;

  ${"$DBname.master"}{$dbrecno}=$dbrec; # add complete record to masterDB
  # add to pointer DBs into DBmasster by following keys
  ${"$DBname.NameRec"}{$LastNameFirstName}=$dbrecno; # add complete record to masterDB
  #
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
sub DBFirstNameLastName
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
#??  @street=map { $_=~ s/AddressesOn\///;$_;} <AddressesOn/*>;
#
###########################################
#TEST
#print join("\n",@DBmasterColumnLabels);
#print join("\n",@DBrecLabels);
1;
