#!/usr/bin/perl

sub ShowMap
{ my($mapParmsfile)=@_;
  undef $MapFile;
  undef $MapParameters;

  #print "<br>:DB--->>mapParmsfile $mapParmsfile>>\n";
  #print "<br>:DB--->>MapFixedSymbols ",join(" ",keys %MapFixedSymbols),">>\n";
  &ParmValueArray( &arrayTXTfile($mapParmsfile) );
  # initial call to set MapDimX MapDimY
  ($markerOffsetX,$markerOffsetY,$MapDimX,$MapDimY)=&Address2Pixel($address,$MapParameters);
  #################################
  undef $svgOut;
  my $svgOut="";
  #################################
  undef @addresses; my @addresses;
  undef %display; my %display;

  my @colors=();
  my @categories=();
  if($DisplayType =~ m/DamageStatus/)
  { @addresses=&DamageReportAddresses();
    %display=&DamagesForGraphicsPopUp;
    @colors=@BoxColor;
    @categories=@BoxName;
  }
  elsif($DisplayType =~ m/SpecialNeeds/)
  { &TIE("DBSpecialNeeds");
    %display=%DBSpecialNeeds;
    @addresses=keys %display;
    @colors=@BoxColor;
    @categories=@BoxName;
  }

  elsif($DisplayType =~ m/MyNeighbors/)
  { &TIE("Neighbors");
    my $vAddress="$StreetName=$StreetAddress=$subAddress";
    my $neighbors=$Neighbors{$vAddress};
    # print "NNN>>$neighbors";
    my @addressesLL=split(/;/,$neighbors);
    @addresses=map {my @a=split(/\t/,$_);$a[0]} @addressesLL;
    my @LL=map { my @a=split(/\t/,$_);"$a[1]\t$a[2]" } @addressesLL;
    my @LLref=split(/\t/,$LL[0]);
    for(my $i=0;$i<=$#addressesLL;$i++)
    { my @names=&WhoIsAtAddress($addresses[$i]); 
      my @LLadd=split(/\t/,$LL[$i]);
      my $dd= sqrt( ($LLadd[0]- $LLref[0])**2+
       	(($LLadd[1]- $LLref[1])/cos(37/180*3.14159))**2 );
      print "<br>>>@LLadd >> $dd >>@names";
      
      if($dd lt .0006)
      { print "<br>>>$addresses[$i]";
	if($i==0)
	{ $display{$addresses[$i]}= "Home:".join(", ",@names);
	}
	elsif($#names ge 0)
	{ $display{$addresses[$i]}= "MyNeighbor:".join(", ",@names);
	}
	else
	{ $display{$addresses[$i]}= "NoData:ReachOut";
	}
	$display{$addresses[$i]}=~s/\t/; /g;
	print "<br>>> $display{$addresses[$i]}";
      }
    }
    @colors=@BoxColor;
    @categories=@BoxName;
  }
  #################################
  print $q->h3($MapTitle),hr();
  $svgOut.=&MapInitSVG;
  $svgOut.=$MapFixedSymbols{$mapParmsfile};

  #################################
  my @notOnMap=();
  my @maplocations; $#maplocations=-1;
  $svgOut.=&showTargetAddress;
  foreach my $address (sort @addresses)
  { print "<br>$address";
    my $addressParcel=&ParcelvAddress($address);
      my ($markerX,$markerY,$MapDimX,$MapDimY) 
        =&Address2Pixel($addressParcel,$MapParameters);
	# 	print "<br>DB:>> addressParcel $addressParcel : $markerX, $markerY" ; 
	# print "<br>DB:>> MapParameters $MapParameters  " ; 
    next if($markerX !~ /\d/); # NO pix data
    if( $markerX<0 or $markerY<0 or $markerX>$MapDimX or $markerY>$MapDimY) 
    { push @notOnMap,$address;
      next;
    }
    ######################################
    # get report at address
    my @report=split(/\n/,$display{$address});
    #print ">>report @report";
    ######################################
    my $listrec=&FindMatchQ("LIST",@report) ;
    my $list=$report[$listrec];
    #print "LIST: $list";
    @report=join("\n",&deleteArrayIndex($listrec,@report));
    print "<br>>report>> @report";

    my $class="class=\"svg-blink\"";
    my $output="no";
    ##################################################
    # 00 01 marker position label 
    # 10 11
    my @markerBd=($markerX-$subMarkerSize-2,$markerY-$subMarkerSize-2);
    my @markerXs=(
      $markerX-$subMarkerSize,
      $markerX-$subMarkerSize,
      $markerX,
      $markerX);
    my @markerYs=(
      $markerY-$subMarkerSize,
      $markerY,
      $markerY-$subMarkerSize,
      $markerY);
    ##################################################
    # ALL CLEAR
    if($list=~m/allclear/) 
    { $svgOut.=<<___EOR;
      <circle id="$address" cx="$markerX" cy="$markerY" 
    r="10" stroke="black" stroke-width="1" fill="cyan" opacity="1."/>
___EOR
    }
    ###################################################
    ###################################################
    for(my $i=0;$i<=$#categories;$i++)
    { if($list=~m/$categories[$i]/)
      { $output="yes";
	$svgOut.=<<___EOR;
  <rect $class x="$markerXs[$i]" y="$markerYs[$i]" 
	width="$subMarkerSize" height="$subMarkerSize" stroke="black" stroke-width="1" fill="$colors[$i]" />
___EOR
      }
    }
    if($output eq "yes") # output boarder and id=
    { push(@maplocations,$address);
      $svgOut.=<<___EOR;
<rect $class id="$address\n@report" x="$markerBd[0]" y="$markerBd[1]" 
      width="$MarkerBoarderSize" height="$MarkerBoarderSize" stroke="red" stroke-width="2" fill-opacity="0.0" />
___EOR
    }
  }
  print <<___EOR;
$svgOut
<\g>
<\svg>
___EOR

#############
  if($#maplocations>-1)
  { print "<br>",&COLOR("Red","Locations ON map:");
    foreach my $address ( sort @maplocations )
    { print "\n<br>",$q->submit("ShowReportFor",$address); 
      # print "\n<br>",$q->submit("action","MapShowReportFor=$address"); 
    }
    print hr();
  }
  if($#notOnMap>-1)
  { print "<br>",&COLOR("Red","Locations OFF map with reports:");
    foreach my $address ( sort @notOnMap )
    { print $q->submit("ShowReportFor",$address); 
      my @list=split(/\n/, $display{$address}); 
      my $idelete=&FindMatchQ("LIST",@list) ;
      @list=&deleteArrayIndex($idelete,@list);
      print "<br>\n",join("<br>\n",@list);
      print hr();
    }
  }
}

############################################
sub Address2Pixel
{ my ($address,$LLpixelInfoFile)=@_;
  if( ! $MapFile )
  { &ParmValueArray( &arrayTXTfile($LLpixelInfoFile) );
  }
  if( ! %{$MapAddressLonLat})
  { &TIE("$MapAddressLonLat");
  }
  if( $MapExtraAddressLonLat and ! %{$MapExtraAddressLonLat} )
  { &TIE("$MapExtraAddressLonLat");
  }
  $address=&ParcelvAddress($address); # CHK address format
  # print "<br>DB:: MapAddressLonLat $MapAddressLonLat";
  # print "<br>DB:: MapExtraAddressLonLat $MapExtraAddressLonLat";
  my $data;
  if( $data=${$MapAddressLonLat}{   $address  } )
  { my ($lon,$lat) =split(/\t/,$data);
    #print "==MapAddressLonLat: $address $data ==";
    my ($dxpix,$dypix,$MapXdim,$MapYdim)=&MapLatLongPxLocation($lat,$lon,$LLpixelInfoFile);
    return ($dxpix,$dypix,$MapXdim,$MapYdim);
  }
  elsif( $data=${$MapExtraAddressLonLat}{   $address  } )
  { my ($lon,$lat) =split(/\t/,$data);
    #print "==MapExtraAddressLonLat: $address $data ==";
    my ($dxpix,$dypix,$MapXdim,$MapYdim)=&MapLatLongPxLocation($lat,$lon,$LLpixelInfoFile);
    return ($dxpix,$dypix,$MapXdim,$MapYdim);
  }
  else
  { return (-1,-1,$MapXdim,$MapYdim); # address not found return
  }
}

#############
sub AddressPxLocation
{ my ($address,$LLpixelInfoFile,$MapStreetAddressLL)=@_;
  if( ! $MapFile )
  { &ParmValueArray( &arrayTXTfile($LLpixelInfoFile) );
  }
  if( ! %MapStreetAddressLL )
  { &TIE("$MapStreetAddressLL");
  }
  $address=&ParcelvAddress($address);
  if( my $data=${$MapStreetAddressLL}{   $address  } )
  { my ( $LLx,$LLy,$dxpix,$dypix ) =split(/\t/,$data);
    #print "==($dxpix,$dypix,$MapXdim,$MapYdim)==";
    return ($dxpix,$dypix,$MapXdim,$MapYdim);
  }
  else
  { return (-1,-1,$MapXdim,$MapYdim); # address not found return
  }
}

# Returns an array for damaage info for graphic display
sub DamagesForGraphicsPopUp
{ 
  undef %damage;
  my %damage;
  my $vAddress;
  my $data=&LoadDamageData;
  my @blocks=split(/$BlockSeparator\n/,$data);
  my $reporttypes;
  # edit blocks 
  for(my $ib=0;$ib<=$#blocks;$ib++)
  { my @lines=split(/\n/,$blocks[$ib]);
    my @outline; $#outline=-1;
    my $iout=0;
    for(my $j=0;$j<=$#lines;$j++)
    { my $line=$lines[$j];
      next if($line=~
	/^action|^UserName|^Select|^.cgifields|=None$|=none$|^UserName|^Select|Accessible/);
      $line =~  s/Assessment//;
      if( $line =~ m/vAddress=(.*)/ )
      { $vAddress=$1;
      }
      else
      { if( $line =~ m/UXtime=(\d*)/ )
	{ $timestr= POSIX::strftime("%a %b %e %H:%M %Y", localtime($1));
	  $line="Time=$timestr";
	}
	$outline[$iout++]=$line;
      }
    }
    $reporttypes="";
    if(&FindMatchQ("People",@outline)>=0){ $reporttypes.="people,"; }
    if(&FindMatchQ("Hazards",@outline)>=0) { $reporttypes.="hazard," ;}
    if(&FindMatchQ("Fire",@outline)>=0) { $reporttypes.="fire," ;}
    if(&FindMatchQ("Structural",@outline)>=0) { $reporttypes.="structure," ;}
    if(&FindMatchQ("AllClear",@outline)>=0) { $reporttypes.="allclear," ;}
    if(&FindMatchQ("Roads",@outline)>=0) { $reporttypes.="roads," ;}
    if(&FindMatchQ("Urgency",@outline)>=0) { $reporttypes.="urgency,";}
    ############ DB address

    $outline[$iout++]="LIST:$reporttypes";
    $damage{$vAddress}=join("\n",@outline);
    $blocks[$ib]=join("\n",@outline);
  }
  return %damage;
}

#############################MAP
sub MapParmList
{ #undef @mapParmList; #uncomment reload TEST
  my ($mapsAvailable)=@_;
  ## print ">>$mapsAvailable";
  if($#mapParmList<0)
  { undef %MapFixedSymbols;
    @mapParmList=&arrayTXTfile("Lists/$mapsAvailable.txt");
    foreach my $parmfile (@mapParmList)
    { 
      #print "<br>:DB parmfile---> $parmfile";
      my @mapParm=&arrayTXTfile($parmfile);
      my $title=&FindFirstElement("MapTitle=",@mapParm);
      if( $title eq "" ) { print "\nMAP MapTitle NOT FOUND in >>$parmfile>>";}
      $title=~s/^MapTitle=//;
      $title=~s/<br>/ /g;
      $MapTitle{$parmfile}=$title;
      $MapTitle2ParmFile{$title}=$parmfile;
      my $fixedsymbols=&FindFirstElement("MapFixedSymbols=",@mapParm);
      if( $fixedsymbols ne "" ) 
      { $fixedsymbols=~s/^MapFixedSymbols=//;
	######### ? ADD variable replacement code
	$MapFixedSymbols{$parmfile}=join("\n",&arrayTXTfile($fixedsymbols));
      }
    }
  }
}

sub ViewMapsForm
{ my ($q)=@_;
  print $q->h3("View Maps Form"),hr();
  &MapParmList("MapsAvailable");
  print ">> @mapParmList << \n";
  if( $#mapParmList>-1 )
  { print &COMMENT("Select Map<br>");
    my $cmd="";
    foreach my $parm (@mapParmList)
    { #print ">>$parm : $MapTitle{$parm}\n";
      next if( $parm=~m/NOMENU/);	#NOMENU not on menu options 
      $cmd.="<input type=submit name='UserAction' value='Map:$MapTitle{$parm}' ><br>";
    }
    print $cmd;
  }
  else
  { print &COMMENT("NO Maps Available<br>");
  }
  print hr();
  $q->param("LastAction","$UserAction");
  $q->param("UserName","$UserName");
  &hiddenParam($q,'UserName,UserAction,LastAction');
  &SubmitActionList('Cancel>Home');
  print hr(),$q->submit(-name=>'ShowInfo:ViewMapsForm', -value=>'Help', -id=>'helpButton');
  print $q->end_form;
}

#####
sub ViewMembershipMapsForm
{ my ($q)=@_;
  print $q->h3("Maps"),hr();
  &MapParmList("MapsAvailableMemberInformation");
  ## print ">> @mapParmList << \n";
  print $q->start_form( -name => 'main', -method => 'POST',);
  if( $#mapParmList>-1 )
  { print &COMMENT("Select Map<br>");
    my $cmd="";
    foreach my $parm (@mapParmList)
    { #print ">>$parm : $MapTitle{$parm}\n";
      next if( $parm=~m/NOMENU/);	#NOMENU not on menu options 
      $cmd.="<input type=submit name='action' value='Map:$MapTitle{$parm}' ><br>";
    }
    print $cmd;
  }
  else
  { print &COMMENT("NO Maps Available<br>");
  }
  print hr();
}

sub ViewMap
{ my ($q)=@_;
  &MapParmList("MapsAvailableMember");	#load MapParmList (only one time)???
  my $mapTitle=$UserAction; # UserAction has Map: prepended. Remove!
  $mapTitle=~s/^Map://;
  #print "<br>DB:->>$mapTitle\n";
  # PUT $mapTitle changing code here
  if($mapTitle =~ m/AddressLocation:/) # if not from menu directly
  { my @titles=keys %MapTitle2ParmFile;
    my $title=&FindFirstElement("AddressLocation:", @titles);
    if($title)
    { # $mapTitle=~s/AddressLocation://;
      $mapTitle=$title;
    }
    else
    { print ">>NO MapTitle for $mapTitle\n";
    }
  }
  #print "<br>:DB mapTitle--->>$mapTitle\n";
  my $parmFile=$MapTitle2ParmFile{$mapTitle};
  #print "<br>:DB MapTitle2ParmFile ",join("<br>",keys %MapTitle2ParmFile);
  #print "<br>:DB parmFile--->>$parmFile\n";

  print $q->start_multipart_form; # DEBUG do we need this here????
################################
  &ShowMap($parmFile);
################################
  if( $LastForm =~ "DamageAssessmentForm" ) # in case Back selected
  { $q->param("UserAction","ReviewDamages");
    $q->param("LastAction","ReviewDamages");
  }
  else
  { $q->param("LastAction","View Maps");
  }
  &hiddenParamAll($q); # Does not work here ?
  print hr(),$q->submit('action','Back'); 
  print hr(),$q->submit('action','Cancel>Home');
  print $q->end_form;
}

sub MapLatLongPxLocation
{ my ($lat,$long,$LLpixelInfoFile)=@_;
  if( ! $MapFile ) { &ParmValueArray( &arrayTXTfile($LLpixelInfoFile) ); }
  { my $LLx=$long;
    my $LLy=$lat; #longitude,latitude data
    my $dxpix=
      int($MapLowerLeftPxXRef+
	($MapUpperRightPxXRef-$MapLowerLeftPxXRef)
	*($LLx-$MapLowerLeftCoordXRef) 
	/ ( $MapUpperRightCoordXRef - $MapLowerLeftCoordXRef));
    my $dypix=
      int($MapLowerLeftPxYRef+
	( $MapUpperRightPxYRef-$MapLowerLeftPxYRef)
	*($LLy-$MapLowerLeftCoordYRef) 
	/ ( $MapUpperRightCoordYRef - $MapLowerLeftCoordYRef));
    return ($dxpix,$dypix,$MapXdim,$MapYdim);
  }
}

sub MapSymbol
{ my ($markerOffsetX,$markerOffsetY,$type)=@_;
  my $color,$width,$diameter;
  if($type =~ /^focus/ )
  { $color="red"; $width=3; $diameter=7;
  }
  elsif($type =~ /^general(.*)/ )
  { $color="blue"; $width=3; $diameter=4;
    my @parms=split(/:/,$1); shift @parms;
    my $icolor=&FindPattern(@parms,"color=");
    if($icolor>=0)
    { my ($dum,$newcolor)=split(/=/,$parms[$icolor]);
      $color=$newcolor;
    }
  }
  elsif($type =~ /^mylocation/ )
  { $color="orange"; $width=4; $diameter=5;
  }
    print <<___EOR;
var ctx = c.getContext("2d");
ctx.strokeStyle = '$color';  
ctx.lineWidth = $width;  
ctx.beginPath();
ctx.arc( $markerOffsetX, $markerOffsetY, $diameter, 0, 2*Math.PI );
ctx.stroke();
___EOR
}
#########################################MAP
sub MapInitSVG
{ my $out;
  $out=<<___EOR;
  <script>
  function buttonClick(evt) { alert(evt.target.id); }
  </script>
  <style>
  g.button:hover {opacity:0.5;}
  </style>
  <svg height="$MapDimY" width="$MapDimX">
  <rect x="0" y="0" height="$MapDimY" width="$MapDimX" style="fill: #999999"/>
  <image id="map-image" x="0" y="$MapYOffset" height="$MapDimY" width="$MapDimX" xlink:href="$MapFile" />
  <g class="button" cursor="pointer" onmouseup="buttonClick(evt)" >
  <g class="map-legend" > 
___EOR
  $out
}

# add target Map:Location
sub showTargetAddress
{ undef $targetaddress;
  my ($dum,$dum1,$targetaddress)=split(/:/,$UserAction,3);
  if($targetaddress)
  { my $address=&ParcelvAddress($targetaddress);
    my ($markerX,$markerY,$MapDimX,$MapDimY) =
     &Address2Pixel($address,$MapParameters);
    next if($markerX !~ /\d/);
    my $mess="";
    if( $markerX<0 or $markerY<0 or $markerX>$MapDimX or $markerY>$MapDimY)
    { $mess="(OUTSIDE MAP)";
    }; 
    my $markerY=$MapYOffset+$markerY;
    my $out=<<___EOR;
<circle cx="540" cy="60" r="$LegendMarkerSize" stroke="black" stroke-width="1" fill="orange" opacity="1."/>
<text x="560" y="70" font-size="$LegendTextSize"> $targetaddress$mess</text>
<circle id="$targetaddress" cx="$markerX" cy="$markerY" 
r="$MapSymbolMarkerSize" stroke="black" stroke-width="1" fill="orange" opacity="1."/>
___EOR
     $out
   }
}

1;
