#!/usr/bin/perl
do "subCommon.pl";
do "subICSWEBTool.pl";
do "subMemberDB.pl";
do "subMessageSystem.pl";
do "subDamageReport.pl";
do "subManageResponseTeam.pl";
do "subMaps.pl";

&initialization;
&MapParmList();
foreach $key (keys %MapTitle){print " >>$key\n :: $MapTitle{$key}\n";};
print "\n : MapFixedSymbols >>\n : ",join("\n :",keys %MapFixedSymbols),"<<";
print "\n========================\n";
$UserAction="Map:AddressLocation:Cedar St=2649=";
$mapParmsfile="Lists/MapAddressLocation.Rooftop.NOMENU.txt";

&xShowMap($mapParmsfile);
############################################
sub xShowMap
{ my($mapParmsfile)=@_;
  undef $MapFile;
  undef $MapParameters;
  # print "<br>:DB--->>UserAction $UserAction>>\n";
  # print "<br>:DB--->>mapParmsfile $mapParmsfile>>\n";
  &ParmValueArray( &arrayTXTfile($mapParmsfile) );

  # initial call to set MapDimX MapDimY
  ($markerOffsetX,$markerOffsetY,$MapDimX,$MapDimY)=&Address2Pixel($address,$MapParameters);
  #################################
  my $svgOut="";
  #################################
  undef @addresses; my @addresses;
  undef %damages; my %damages;

  my @colors=();
  my @categories=();
  if($DisplayType =~ m/DamageStatus/)
  { @addresses=&DamageReportAddresses();
    %damages=&DamagesForGraphicsPopUp;
    @colors=@BoxColor;
    @categories=@BoxName;
  }
  elsif($DisplayType =~ m/SpecialNeeds/)
  { &TIE(DBSpecialNeeds);
    %damages=%DBSpecialNeeds;
    @addresses=keys %damages;
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

  die &showTargetAddress;

  foreach my $address (sort @addresses)
  { my $addressParcel=&ParcelvAddress($address);
      my ($markerX,$markerY,$MapDimX,$MapDimY) 
        =&Address2Pixel($addressParcel,$MapParameters);

    next if($markerX !~ /\d/); # NO pix data
    if( $markerX<0 or $markerY<0 or $markerX>$MapDimX or $markerY>$MapDimY) 
    { push @notOnMap,$address;
      next;
    }

    ######################################
    # get damage report at address
    my @report=split(/\n/,$damages{$address});
    ######################################
    my $listrec=&FindMatchQ("LIST",@report) ;
    my $list=$report[$listrec];
    #print "LIST: $list";
    @report=join("\n",&deleteArrayIndex($listrec,@report));
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
    for(my $i=0;$i<4;$i++)
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
  { print &COLOR("Red","Locations ON map:");
    foreach my $address ( sort @maplocations )
    { print "\n<br>",$q->submit("ShowReportFor",$address); 
    }
    print hr();
  }
  if($#notOnMap>-1)
  { print &COLOR("Red","Locations OFF map with reports:"),"<br>";
    foreach my $address ( sort @notOnMap )
    { print $q->submit("ShowReportFor",$address); 
      my @list=split(/\n/, $damages{$address}); 
      my $idelete=&FindMatchQ("LIST",@list) ;
      @list=&deleteArrayIndex($idelete,@list);
      print "<br>\n",join("<br>\n",@list);
      print hr();
    }
  }
}

#############


