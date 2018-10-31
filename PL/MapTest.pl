#!/usr/bin/perl
require "subCommon.pl";
require "subICSWEBTool.pl";
require "subDamageReport.pl";
require "subMaps.pl";


no lib "$ICSdir"; # needs to be preset
#use lib "$ICSdir"; # does not work in OSX
use lib "/Users/Tom/Sites/EMPREP/ICSTool/PL"; # this seems to be needed explicitly on OSX

undef @mapParmList;
undef %MapTitle;
&MapParmList();
die "\n ",join("\n>>>>",keys %MapTitle2ParmFile);

print ">>",$MapFixedSymbols{"Lists/MapParm11x17.txt"};
 die; 	####

## require => cached routines unchanged until apache restart
&initialization;
#here's a stylesheet incorporated directly into the page

print $q->header();
print $q->start_html(-title=>'SVG test', -style=>{ -src=>'ICSTool.css' ,-code=>$newStyle });
$UserAction="Map:ParcelMap with SpecialNeedsLocations";  
###########################################################################
#&ShowMap("../Lists.EmPrep/MapParmParcel.txt");
#&ShowMap("Lists/MapParm11x17.txt");
&xShowMap("Lists/MapParmParcelSpecialNeeds.txt");
###########################################################################
print $q->end_html;
#############
#############


# Returns an array for damaage info for graphic display
sub SpecialNeedsForGraphicsPopUp
{ 
  undef %specialneeds;
  my %specialneeds;
  my $vAddress;
  my $data=&LoadSpecialNeeds;
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

    $outline[$iout++]="LIST:$reporttypes";
    $damage{$vAddress}=join("\n",@outline);
    $blocks[$ib]=join("\n",@outline);
  }
  return %damage;
}

sub xShowMap
{ my($mapParmsfile)=@_;
  undef $MapFile;
  undef $MapParameters;
  undef $MapAddressData;
  undef @Legend;
  my @var;
  #print "---->>UserAction $UserAction>>\n";
  #print "---->>mapParmsfile $mapParmsfile>>\n";
  $MapTitle=$MapTitle{$mapParmsfile};

  &ParmValueArray( @var=&arrayTXTfile($mapParmsfile) );
  ($markerOffsetX,$markerOffsetY,$MapDimX,$MapDimY)=
    &AddressPxLocation($address,$MapParameters,$MapAddressData);

  my @maplocations; $#maplocations=-1;
  my %damages=&DamagesForGraphicsPopUp;
###SVG
  print $q->h3($MapTitle),hr();
  &MapAndLegend($mapParmsfile);

# add TARGET Map:Location
  undef $targetaddress;
  my ($dum,$dum1,$targetaddress)=split(/:/,$UserAction,3);
  if($targetaddress)
  { my $address=&ParcelvAddress($targetaddress);
    my ($markerOffsetX,$markerOffsetY,$MapDimX,$MapDimY) =
      &AddressPxLocation($address,$MapParameters,$MapAddressData);
    my $markerY;
    if($markerOffsetX =~ /\d/)
    { $markerY=$markerOffsetY+$Yoffset;
      #print "\n>>>$markerY ";
    }
    print <<___EOR;
<circle cx="570" cy="65" r="10" stroke="black" stroke-width="1" fill="orange" opacity="1."/>
  <text x="600" y="75" font-size="$LegendMarkerSize"> $targetaddress </text>
<circle id="$targetaddress" cx="$markerOffsetX" cy="$markerY" 
    r="$subMarkerSize" stroke="black" stroke-width="1" fill="orange" opacity="1."/>
___EOR
  }

  # display DamageReportAddresses
  my @addresses=&DamageReportAddresses();
  my @notOnMap=();
  foreach my $address (sort @addresses)
  { my $addressParcel=&ParcelvAddress($address);
    my ($markerOffsetX,$markerOffsetY,$MapDimX,$MapDimY) =
      &AddressPxLocation($addressParcel,$MapParameters,$MapAddressData);

      #print "\n>>>($address,$MapParameters,$MapAddressData)\n>>> ($markerOffsetX,$markerOffsetY,$MapDimX,$MapDimY) ";

    next if($markerOffsetX !~ /\d/);
    my $markerY=$markerOffsetY;
    if( $markerOffsetX<0 or $markerOffsetY<0 or $markerOffsetX>$MapDimX or $markerOffsetY>$MapDimY) 
    { push @notOnMap,$address;
      next;
    }

    my $markerXfire=$markerOffsetX-$subMarkerSize;
    my $markerYfire=$markerY-$subMarkerSize;
    my $markerXbox=$markerOffsetX-$subMarkerSize-2;
    my $markerYbox=$markerY-$subMarkerSize-2;
    my $markerXpeople=$markerOffsetX;
    my $markerYpeople=$markerY-$subMarkerSize;
    my $markerXhazard=$markerOffsetX-$subMarkerSize;
    my $markerYhazard=$markerY;
    my $markerXstructure=$markerOffsetX;
    my $markerYstructure=$markerY;
    my @report=split(/\n/,$damages{$address});
    my $listrec=&FindMatchQ("LIST",@report) ;
    my $list=$report[$listrec];
    @report=join("\n",&deleteArrayIndex($listrec,@report));
    my $class="class=\"svg-blink\"";
    my $output="no";
    ###
    # ALL CLEAR
    if($list=~m/allclear/) 
    { print <<___EOR;
<circle id="$address" cx="$markerOffsetX" cy="$markerY" 
    r="10" stroke="black" stroke-width="1" fill="cyan" opacity="1."/>
___EOR
    }
    if($list=~m/fire/)
    { $output="yes";
      print <<___EOR;
<rect $class x="$markerXfire" y="$markerYfire" 
      width="$subMarkerSize" height="$subMarkerSize" stroke="black" stroke-width="1" fill="magenta" />
___EOR
    }
    if($list=~m/people/) 
    { $output="yes";
      print <<___EOR;
<rect $class x="$markerXpeople" y="$markerYpeople" 
      width="$subMarkerSize" height="$subMarkerSize" stroke="black" stroke-width="1" fill="red" />
___EOR
    }
    if($list=~m/structure/) 
    { $output="yes";
       print <<___EOR;
<rect $class x="$markerXstructure" y="$markerYstructure" 
      width="$subMarkerSize" height="$subMarkerSize" stroke="black" stroke-width="1" fill="green" />
___EOR
    }
    if($list=~m/hazard/) 
    { $output="yes";
      print <<___EOR;
<rect $class x="$markerXhazard" y="$markerYhazard" 
      width="$subMarkerSize" height="$subMarkerSize" stroke="black" stroke-width="1" fill="blue" />
___EOR
    }
    if($output eq "yes")
    { push(@maplocations,$address);
      print <<___EOR;
<rect $class id="$address\n@report" x="$markerXbox" y="$markerYbox" 
      width="$MarkerBoarderSize" height="$MarkerBoarderSize" stroke="red" stroke-width="2" fill-opacity="0.0" />
___EOR
    }
  }

  print <<___EOR;
</g>
</svg>
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

