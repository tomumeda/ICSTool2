#!/usr/bin/perl
#do "subCommon.pl";
#do "subICSWEBTool.pl";

@radiosurveyParm=(); #global variable
my @radiosurveychoice=&arrayTXTfile("Lists/RadioSurveyChoices.txt");
my @list;
for(my $i=0;$i<=$#radiosurveychoice;$i++)
{ my $data=$radiosurveychoice[$i];
  my ($damage,$choices,$multiple)=split(/:/,$data);
  #my @choice=split(/,/,$choices);
  my $assessment=$damage;
  push (@radiosurveyParm,$assessment);
  push (@radiosurveyChoices,$choices);
  $radiosurveyChoices{$assessment}=$choices;
  push (@radiosurveyMultiple,$multiple);
  if($multiple =~ /multiple/)
  { push(@list,"\@$assessment");
  }
  else
  { push(@list,"$assessment");
  }
}
$radiosurveyParmlist=join(",",@list);
#print "$radiosurveyParmlist";
#print "\n@radiosurveyChoices";
################################################################

sub RadioSurvey
{ my ($q)=@_;
  ######################################
  # NewStreet NewAddress update
  my $street = $q->param("SelectStreet" );
  my $address = $q->param("SelectAddress" );
  my $subaddress = $q->param("SelectSubAddress" );
  my $DamageAddress = $q->param("DamageAddress" );
  if($DamageAddress)
  { ($street,$address,$subaddress)=&StringvAddress($DamageAddress);
    $vAddress = $DamageAddress;
    $q->param("vAddress",$vAddress);
    $q->param("SelectStreet",$street);
    $q->param("SelectAddress",$address);
    $q->param("SelectSubAddress",$subaddress);
  }
  my $newstreetname=$q->param("NewStreetName");
  my $newaddress=$q->param("NewAddress");
  if( $newstreetname and $newstreetname ne "")
  { $street=$newstreetname;
    $q->delete("SelectStreet");
    $q->param("SelectStreet",$street );
    # ADD street name to list
    my $f = "AddressesOn/$street"; 
    if( ! -e $f ) 
    { open L,">$f";
    }
  }
  if( $newaddress and $newaddress ne "New Address") 
  { $address=$newaddress;
    $q->delete("SelectAddress");
    $q->param("SelectAddress",$address );
    #print "###:",$newaddress;
    my @address=&arrayTXTfile("AddressesOn/$street");
    &saveArray2TXTfile("AddressesOn/$street",&uniq(@address,$address));
  }
  $q->delete("NewStreetName");
  $q->delete("NewAddress");
  #########################################
  if( $address and $street )
  { 
    &RadioSurveyForm($q);
    $q->param("LastAction","RadioSurveyForm");
    my @actions=('Submit');
    &SubmitActionList(@actions);
    # 
    &DisplayHistory($BlockSeparator,"$address $street"); 
    &hiddenParam($q,"UserName,UserAction,SelectStreet,vAddress,SelectAddress,SelectSubAddress,LastAction"); 
    print $q->endform;
  }
  else
  { &StreetAddressForm($q,$street,$address,
      "UserName,UserAction,SelectStreet,SelectAddress,LastAction"); 
  }
}

sub RadioSurveyForm
{ my $q=@_[0];
  my $street=$q->param("SelectStreet");
  my $address=$q->param("SelectAddress");
  my $subaddress=$q->param("SelectSubAddress");
  my $vAddress=$q->param("vAddress");
  if ( ! $vAddress )
  { $vAddress=&vAddressStringFromParam($q); #VADD
    $q->param("vAddress",$vAddress);
  }
  # print "DEBUG: $streetaddress, $street, $address, $subaddress ($vAddress)<br>";
  my $lastq=$q;
  $q=&restore_DamageAssessment($vAddress);
  if($lastq ne $q)
  { print $q->h3("Update Radio Reception Report");
  }
  else
  { print $q->h3("Radio Reception Report");
  }
  print $q->h6("[$vAddress]");
  print hr;
  #################################
  my @personnel=keys %$RoleByName_ref;
  ######################
  print $q->start_multipart_form;
  print <<___EOR;
<input type=submit name=UserAction value="Map:Location:$vAddress">
___EOR
  print hr;
  #######
  print &BOLD("Reported By: ");
  $q->delete('ReportedBy');
  print $q->popup_menu(-name=>"ReportedBy",-values=>[@personnel],-default=>$UserName),"<br>";
  #################################
  # ADD response team for address
  if(1 eq 2)
  {
  my ($teamName_ref,$teamLocation_ref)=&TeamInfo; #ONLY need for all teams?
  my @team;
  $#team=-1;
  foreach my $team ( keys %$teamLocation_ref)
  { if( $teamLocation_ref->{$team} =~ /$vAddress/ )
    { push(@team,$team);
    }
  }
  }
  #######
  print hr;
  ##
  for(my $i=0;$i<=$#radiosurveyParm;$i++)
  { my $assessment=$radiosurveyParm[$i]; 
    my @choice=split(/,/,$radiosurveyChoices{$assessment});
    my $multiple=$radiosurveyMultiple[$i];
    my $damage=$assessment;
    $damage=~s/Assessment$//;
    @value=$q->param($assessment); 
    $value=$value[0];
    if($multiple)
    { #####################
      # SCROLLING version
      print "<table border=1 width=700 cellspacing=0 cellpadding=5>
      <tr><td>";
      print &BOLD("$damage:</td><td>");
      print $q->scrolling_list(-name=>"$assessment",-values=>[@choice],-default=>[@value],-multiple=>'true');
      print "</td></tr>";
      print "</table>";
    }
    else
    { #########################
      # POPUP menu version
      print " <table border=1 width=700 cellspacing=0 cellpadding=5>";
      print "<tr><td>",&BOLD("$damage: "),"</td><td>";
      print $q->popup_menu(-name=>"$assessment",-values=>[@choice],-default=>$value);
      print "</td></tr>";
      print " </table>";
      #####################
    }
  }
  print &BOLD("Notes"),"<br>";
  $q->delete("Notes"); # New Notes
  print $q->textarea(-name=>'Notes',-rows=>2,-columns=>40);
  print hr;
}

sub save_RadioSurvey
{ my ($q) = @_;
  my $vAddress=&vAddressStringFromParam($q);
  my $statusfile = "Damages/$vAddress";
  my $logfile = "DamageLogs/$vAddress";
  $q->param('UXtime',$UXtime);
  $q->param('StreetAddress',$vAddress); #VADD ??
  $q->param('vAddress',$vAddress);
  $q->param('time',$timestr);
  ########################
  my $parmlist=$radiosurveyParmlist.",SelectStreet,SelectAddress,SelectSubAddress,Notes,UXtime,UserName,Notes,ReportedBy,vAddress";
    &addParmsCGIfile($q,$statusfile,$parmlist);
  ###################### Log file
  my $parmOut=$radiosurveyParmlist.",SelectStreet,SelectAddress,SelectSubAddress,Notes,UXtime,UserName,Notes,ReportedBy,time,vAddress";
  &logParmsCGIfile($q,$logfile,$parmOut);
}

sub RadioSurveyReview
{ my $q=@_[0];
  #convert submit value to label 
  if( $UserAction =~ "List Radio Reception Assessments")
  { $UserAction = "ReviewRadioAssessmentData:List";
  }
  if( $UserAction =~ "Map Radio Reception Assessments")
  { $UserAction = "ReviewRadioAssessmentData:Map";
  }
  #
  if($UserAction =~ "ReviewRadioAssessmentData:List")
  { &RadioSurveyList($q);
  }
  elsif( $UserAction eq "ReviewRadioAssessmentData:Map")
  { $UserAction="Map:Location:";
    &ViewMap($q);
  }
  else
  { print $q->h3("Review Radio Reception Assessment Data");
    print hr;
    my %labels;
    $labels{"ReviewRadioAssessmentData:Map"}="Map Radio Reception Assessments";
    $labels{"ReviewRadioAssessmentData:List"}="List Radio Reception Assessments";
    #print $q->radio_group(-name=>"UserAction",
      #print $q->scrolling_list(-name=>"UserAction",
      #  -values=>[keys %labels],
      #-labels=>\%labels,
      #-linebreak=>"true");
      #print $q->submit('action','Go');
      #print hr;

    my $cmd="<fieldset><table border=1 width=940 cellspacing=0 cellpadding=5> ";
    $cmd.="<tr>";
    $cmd.="<td> <input type=submit name='UserAction' 
      value='Map Radio Reception Assessments' label='Map Radio Reception Assessments' </td></tr>";
    $cmd.="<td> <input type=submit name='UserAction' 
      value='List Radio Reception Assessments' label='List Radio Reception Assessments' </td></tr>";
    $cmd.="</table></fieldset>";
    print $cmd,hr;

    print $q->submit('action','Home');
    $q->param("LastAction","$UserAction");
    $q->param("UserName","$UserName");
    &hiddenParam($q,'UserName,LastAction');
  }
  #################################
  print $q->endform;
}

sub RadioSurveyData
{ my $q=@_[0];
  my $line,$data,@address,$rec;
  $rec="";
  my @parms=@radiosurveyParm;
  push @parms,"Notes";
  foreach my $file (<Damages/*>)
  { my @out;
    if (open(FILE,$file)) 
    { my $q = new CGI(FILE);  # Throw out the old q, replace it with a new one
      close FILE;
      my $address=$q->param("vAddress");
      #print " $address";
      for(my $i=0;$i<=$#parms;$i++)
      { my $value=$q->param($parms[$i]);
	if($value)
	{ my $line="$parms[$i]=$value";
	  push @out,$line;
	}
      }
      if($#out>-1)
      { $rec.="Address=$address;".join(";",@out)."\t";
      }
    }
  }
  $rec;
}

sub RadioSurveyList
{ my $q=@_[0];
  print $q->h3("Radio Reception Assessments by Address");
  print hr;
  my $data,@address;
  my @data=split(/\t/,&RadioSurveyData($q));
  for($i=0; $i<=$#data; $i++)
  { undef @out;
    my @items=split(";",$data[$i]);
    for($j=0; $j<=$#items;$j++)
    { my $key,$value,$line;
      ($key,$value)=split(/=/,$items[$j],2);
      { my $line=&COLOR("blue",$key.": ")."$value <br>";
	push @out,$line;
      }
    }
    if($#out>-1)
    { print "@out";
      print hr;
    }
  }
  &hiddenParam($q,'UserName,LastAction');
  print $q->submit('action','Home');
}

sub RadioSurveyPlot
{ my $q=@_[0];
  my @color=("black","blue","brown","pink","red");
  my @data=split(/\t/,&RadioSurveyData($q));
  for($i=0; $i<=$#data; $i++)
  { undef @out;
    my $address,$color;
    my @items=split(";",$data[$i]);
    for($j=0; $j<=$#items;$j++)
    { my $key,$value,$line;
      ($key,$value)=split(/=/,$items[$j],2);
      my @choice=split(/,/,$radiosurveyChoices{$key});
      if($key =~ "Address")
      { #print "\n$key: $value";
	$address=$value;
      }
      if($key =~ "Strength")
      { my $index=&MemberQ(@choice,$value);
	$color=$color[$index+1];
	#print "\n$key: $value: $index:".$color,"\n";
      }
    }
    if($address and $color) 
    { my ($markerOffsetX,$markerOffsetY,$MapDimX,$MapDimY)
        =&MapAddressPxLocation($address,"Lists/ParcelMapInfo.txt","MapStreetAddressLL");
      next if($markerOffsetX !~ /\d/);
      &MapSymbol( $markerOffsetX, $markerOffsetY,"general:color=$color");
    }
  }
}

#&RadioSurveyPlot;
