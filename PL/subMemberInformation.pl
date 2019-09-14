#!/usr/bin/perl

do "subCommon.pl";
require "subMemberDB.pl";

sub initialFormData
{ 
  $Timestamp=$timestamp;
  &TIE("MapStreetAddressesEmPrep");
  my @streets=keys %MapStreetAddressesEmPrep;
  
  push(@streets,"( Other )");
  unshift(@streets,"( Choose )");

  $values{"StreetName"}= join("\t",@streets);
  $size{"StreetName"}=30;
  if($StreetName)
  { $defaults{"StreetName"}=$StreetName;
  }
  else
  { $defaults{"StreetName"}="( Choose )";
  }
  $multiple{"StreetName"}="";
  &UNTIE("MapStreetAddressesEmPrep");

  $values{"DivisionBlock"}= join("\t", split(/,/,"A1,A2,A3,B1,B2,B3,C1,C2,C3"));
  $defaults{"DivisionBlock"}="$DivisionBlock";
  $columns{"DivisionBlock"}=4;

  @InactiveMember=split(/,/,"Yes,No");
  $values{"InactiveMember"}= join("\t",@InactiveMember);
  if(!$InactiveMember){$InactiveMember="No";}
  $defaults{"InactiveMember"}="$InactiveMember";
  $columns{"InactiveMember"}=0;

  @SkillsForEmergency=split(/,/,"FireSuppression,SearchAndRescue,Communications,FirstAid");
  $values{"SkillsForEmergency"}= join("\t",@SkillsForEmergency);

  my @tmp=split(/,/, $SkillsForEmergency);
  @tmp=map {my $tmp=&clean_name($_);$tmp} @tmp;
  @tmp=join("\t",@tmp);
  $defaults{"SkillsForEmergency"}=join("\t",@tmp);
  # print "<br>YYY Skills::@tmp";

  @ACAlertSignUp=split(/,/,"No,Yes");
  $values{"ACAlertSignUp"}= join("\t",@ACAlertSignUp);
  $defaults{"ACAlertSignUp"}= $ACAlertSignUp;

  #$CERTClasses= "";

  my @list=&readTXTfile("Descriptor");
  for($i=0;$i<=$#list;$i++)
  {  
    # print "XXXDescriptor  $list[$i]<br>";
    my ($label,$text)=split(/\t/,$list[$i]);
    my $red= &COMMENT("(required)");
    $text=~s/\(required\)/$red/;
    $descriptor{$label}=$text;

    #print "YY: $descriptor{$label},$text <br>";
  }
};

sub memberForm
{ &initialFormData;
  print <<___EOR;
  <table width=100%>
  <tr> 
  <th id="head" colspan="3"> Member Information Form </th>
  </tr> 
  <tr> 
  <td text-align:center width="20%" color:red > Label  </td>
  <td text-align:center width="40%"> Information  </td>
  <td text-align:center width="40%"> Description  </td>
  </tr> 
___EOR

  my @list=&readTXTfile("FormData");

  for(my $i=0;$i<=$#list;$i++)
  { $_=$list[$i];
    ($label,$type,$parameters)=split("\t",$_);
    # print "<br>($label,$type,$parameters)";

    if($type eq "date")
    { print $q->Tr
      ( $q->td ("$label:"),
	$q->td ( $q->textfield("$label","${$label}",20,20)),
	$q->td("<small>".$descriptor{$label})
      );
    }

    if($type eq "number")
    { print $q->Tr
      ( $q->td ("$label:"),
	$q->td ( "<input type=number name=$label value=${$label} >"),
	$q->td("<small>".$descriptor{$label})
      );
    }

    if($type eq "email")
    { print $q->Tr
      ( $q->td ("$label:"),
        $q->td( "<input type=textfield name=$label placeholder=your\@email.address value='${$label}' > "
	),
	$q->td("<small>".$descriptor{$label})
      );
    }

    if($type eq "textfield")
    { print $q->Tr
      ( $q->td ("$label:"),
	$q->td ( $q->textfield("$label",${$label},40,55)),
	$q->td("<small>".$descriptor{$label})
      );
      #print "YY: $label , $descriptor{$label}<br>";
    }

    if($type eq "textarea")
    { print $q->Tr
      ( $q->td ("$label:"),
	$q->td ( $q->textarea("$label","${$label}",04,50)),
	$q->td("<small>".$descriptor{$label})
      );
    }

    if($type eq "radio_group")
    { my @values=split(/\t/,$values{$label});
      print $q->Tr
      ( $q->td("$label:"),
	$q->td
	( $q->radio_group
	  ( "$label",
	    [split(/\t/,$values{$label})],
	    [split(/\t/,$defaults{$label})],
	    $columns{$label}
	  )
	),
	$q->td("<small>".$descriptor{$label})
      );
    }

    if($type eq "checkbox_group")
    { my @values=split(/\t/,$values{$label});
      my @default=split(/\t/,$defaults{$label});
      #	substitute values names
      # print "<br>XXX1 @values;;@default";
      @other=&deleteElements($values{$label},@default);
      my $other=join("; ",@other);
      # print "<br>other:@other::$other";
      @default=&deleteElements( join("\t",@other) , @default);
      # print "<br>XXX2 @other;;@default";
      @default=map {&string_NoBlank($_)} @default; # names have no spaces
      my $i;
      @default=map { 
	if(($i=&MemberQlc(@values,$_)) ge 0) 
	{ $tmp=$values[$i] }
	else
	{ $tmp=$_ };$tmp
      } @default;
      print $q->Tr
      ( $q->td("$label:"),
	$q->td
	( $q->checkbox_group
	  ( -name=>"$label",
	    -values=>[@values],
	    -default=>[@default],
	    -linebreak=>1
	  ),
          "<br><input type=textfield name=$label placeholder='( Other )' 
	    value='$other' -size=100> " 
	),
	$q->td("<small>".$descriptor{$label})
      );
    }

    if($type eq "scrolling_list")
    { my @values=split(/\t/,$values{$label});
      # print "ZZZ $defaults{$label}";
      my @other=split(/\t/,$defaults{$label});
      @other=&deleteElements($values{$label},@other);
      my $other=join(";",@other);
      my @default=split(/\t/,$defaults{$label});
      if($#other>=0)
      { @default="( Other )";
      }
      print $q->Tr
      ( $q->td("$label:"),
	$q->td
	( $q->scrolling_list
	  ( "$label",
	    [split(/\t/,$values{$label})],
	    #[split(/\t/,$defaults{$label})],
	    [@default],
	    "-size=>$size{$label} -multiple=>$multiple{$label}" 
	  )
	),
	$q->td("<small>".$descriptor{$label})
      );

      if($values{$label}=~m/Other/)
      { print $q->Tr
	( $q->td ("( Other )$label:"),
	  $q->td ( $q->textfield("$label","$other",40,80)),
	  $q->td("<small>".$descriptor{$label})
	);
      }
    }

    if($type eq "tel")
    { print $q->Tr(
	$q->td("$label "),
	$q->td(
	  " <input type=tel name=$label
	    placeholder=format[123-456-7890]
	    value='${$label}'
	    pattern=[0-9]{3}[-]{0,1}[0-9]{3}[-]{0,1}[0-9]{4} size=15> "
	),
	$q->td("<small>".$descriptor{$label})
      )
    }
  }
  print <<___EOR;
  </table>
___EOR
  $q->param("LastForm","memberForm");
  &hiddenParam($q,'LastForm');
};

$Timestamp=$timestamp;
@colNames=&readTXTfile("Header.txt");
# die "@colNames";
my $colNames=join(",",@colNames);

# Outputs a footer line and end html tags
sub output_end 
{ my ($q) = @_;
  print $q->end_html;
}

#######################################################333

# Outputs a web form
sub output_form 
{
        my ($q) = @_;
        print $q->start_multipart_form( -name => 'main', -method => 'POST');
	#####################################
	&memberForm;
	#####################################
        print $q->Tr(
           $q->td($q->submit(-name=>'action', -value=>'Submit Info')),
	   $q->td($q->submit(-name=>'action', -value=>'Cancel')),
           $q->td($q->submit(-name=>'action', -value=>'Downloads'))
	  ,$q->td('&nbsp;')
        );
	print $q->hr;
	print "<br> Images to be added";
	print $q->hr;

        print $q->end_form;
};

sub readTXTfile
{ my $file=$_[0];
  my @items=();
  open L,"$CSVroot.$file" || die;
  while(<L>)
  { chop;
    next if(/^\s*$/);	# no blank line
    next if(/^#/ );	# no comment lines
    # print "===$_\n";
    push @items,$_;
  }
  close L;
  return @items
};

sub FindMyName
{ my $search=@_[0];
  my @search=split(/[\s,;]/,$search);
  #  print "<br> SEARCH===@search===";
  undef %foundnames;
  my $i,%foundnames;
  my @name=keys %DBrecName;
  # print "===name:  @name ===<br>";
  for($i=0;$i<=$#name;$i++)
  { if( &AllMatchQ($name[$i],@search)==1 )
    { $foundnames{$name[$i]}=$DBrecName{$name[$i]} ;
    }
  }
  return(%foundnames);
}

sub  SetNewNameVars
{ for(my $i=0;$i<=$#colNames;$i++)
   { next if( $colNames[$i] eq "LastName" or $colNames[$i] eq "FirstName");
     ${$colNames[$i]}=" ";
     undef ${$colNames[$i]};
   }
   #$HomePhone="000-000-0000";
   #$CellPhone="000-000-0000";
   #$EmailAddress="your\@email.address";
   $DivisionBlock="-";
   $SkillsForEmergency="-\t\t\t\t\t";
   # $defaults{"SkillsForEmergency"}=$SkillsForEmergency;
   $InactiveMember="No";
   $ACAlertSignUp="No";
}

sub loadNameData
{ 
  @colNames=&readTXTfile("Header.txt");
  # print "HEADER @colNames ===";
  @colNames=map { my $tmp=&clean_name($_);$tmp } @colNames;
  $colNames=join(",",@colNames);
  $DBrecNumber=${"DBrecName"}{"$LastName\t$FirstName"};
  #
  if($DBrecNumber>1 #	and $action ne "New Name"
  )
  { &SetDBrecVars($DBrecNumber);
    # print "XXX CERT $CERTClasses;;<br> ";
    @SkillsForEmergency=split(/,/,$SkillsForEmergency);
    @SkillsForEmergency=map {$tmp=&clean_name($_);$tmp} @SkillsForEmergency;
  }
  else
  { &SetNewNameVars;
  }
  $Timestamp=$timestamp;
  #	Make into standard format
  $HomePhone=~s/^[^\d]*(\d{3})[^\d]*(\d{3})[^\d]*(\d{4})(\d*)$/$1-$2-$3/;
  $CellPhone=~s/^[^\d]*(\d{3})[^\d]*(\d{3})[^\d]*(\d{4})(\d*)$/$1-$2-$3/;
  #print "<br>XXX HomePhone $HomePhone";
}


sub undefDBvar
{ for(my $i=0;$i<$#DBmasterColumnLabels;$i++)
  { my $var=$DBmasterColumnLabels[$i]; #TEST print "<br>undef $var>>${$var}\n";
    undef ${$var};
  }
}

sub undefList
{ my $list=@_[0];
  my @list=split(/,/,$list);
  for(my $i=0;$i<=$#list;$i++)
  { my $var=$list[$i]; #TEST 
    # print "<br>undef $var>>${$var}\n";
    undef ${$var};
  }
}

sub keepOnlyParams
{ my $list=@_[0];
  my @list=split(/,/,$list);
  foreach my $name ( @params )
  { if( &MemberQlc(@list,$name)<0 )
    { undef ${$name};
    }
    else
    { #undef ${$name}; #TEST
    }
  }
}

sub checkData
{ my $required="FirstName,LastName,EmailAddress";
  my @list=split(/,/,$required);
  my $missing="";
  foreach my $name (@list)
  { # print "NNN $name ${$name} NNN";
    if( "${$name}" eq "")
    { $missing.=" $name";
    }
  }
  if($missing ne "") { return("$missing"); }
  else { return("ok"); }
}

sub UpdateDBvariables
{ my ($dbrecno)=@_;
  undef @col;
  my @col=();
  for($i=0;$i<$#DBmasterColumnLabels;$i++)
  { 
    #DB format adjust
    $SkillsForEmergency=join(",",@SkillsForEmergency);	
    #DB format adjust
    
    $col[ $DBcol{$DBmasterColumnLabels[$i]} ]=${$DBmasterColumnLabels[$i]};
    # print "<br>DDD UpdateDB:: $DBmasterColumnLabels[$i];;${$DBmasterColumnLabels[$i]};;@{$DBmasterColumnLabels[$i]}";
  }
  my $dbrec=join("\t",@col);
# @DBname=&MakeArray("DBmaster, DBrecName, DBrecAddress, DBrecSkills, DBSpecialNeeds, DBAddressOnStreet, DBrecEmergencyEquipment, DBcontactInfo, DBrecPets, DBrecVisitors");
  ${"DBmaster"}{$dbrecno}=$dbrec; # add complete record to masterDB
  #
  # add to pointer DBs into DBmasster by following keys
  #if($InactiveMember!~/yes/i)
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
  # print "<br><br>WWWW ",${"DBmaster"}{$dbrecno},"EEEE";;
}

1;
