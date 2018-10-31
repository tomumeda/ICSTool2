sub ViewMap
{ my ($q)=@_;
###################################################
  if( $UserAction eq "Map:Detailed EmPrep Neighborhood" )
  { print $q->h3("Detailed Map of EmPrep Neighborhood"),hr();
    print "<img  src='../../Maps/11x17map.jan2017.jpg' alt='DetailedMap'>";
  }
###################################################
  elsif( $UserAction =~ "Map:Reported Locations:" 
      or $UserAction =~ "Map:Location:" 
  )
  { my ($dum,$dum1,$address)=split(/:/,$UserAction,3);
    if(!$address){ $address="Le Roy Ave=1643" } #DUMMY to make code work
    my ($markerOffsetX,$markerOffsetY,$MapDimX,$MapDimY) 
      = &MapAddressPxLocation($address,"Lists/ParcelMapInfo.txt","MapStreetAddressLL");
#
    my @noLatLon=();
    print $q->h3("Locations of Reported Damage"),hr();
### General set up.  These four statement are necessary here instead of the end for latlon info to be pasted to server
#	or $UserAction =~ "Map:Location:" )
    {
      { my ($dum,$dum1,$address)=split(/:/,$UserAction,3);
	$address=&ParcelvAddress($address);
	if(!$address){ $address="Le Roy Ave=1643=" } #DUMMY to set the following parameters
	my ($markerOffsetX,$markerOffsetY,$MapDimX,$MapDimY)
	  = &MapAddressPxLocation($address,"Lists/ParcelMapInfo.txt","MapStreetAddressLL");
      }
      my $Yoffset=60;
      my $svgYSize=$MapDimY+$Yoffset;
      my $imageYRef=$Yoffset;
#
###SVG
      print <<___EOR;
      <form>
      <input hidden id="myLongitude" type="text" name="myLongitude">
      <input hidden id="myLatitude" type="text" name="myLatitude">
      </form>
      <script>

      function buttonClick(evt) { alert(evt.target.id); }
      </script>
      <script>
      function getLocation()
      { var output = document.getElementById("out");
	if ( ! navigator.geolocation )
	{ output.innerHTML = "<p>Geolocation is not supported by your browser</p>";
	 return;
	}
	navigator.geolocation.getCurrentPosition(showPosition); 
      function showPosition(position) 
      { var myLongitude = position.coords.longtitude ;
	var myLatitude = position.coords.lattitude ;
	var x = document.getElementById("myLongitude");
	x.value = myLongitude ;
	var x = document.getElementById("myLatitude");
	x.value = myLatitude ;
	var pxY  = $Yoffset + $MapLowerLeftPxYRef + ( $MapUpperRightPxYRef - $MapLowerLeftPxYRef) * ( position.coords.latitude - $MapLowerLeftCoordYRef )/( $MapUpperRightCoordYRef - $MapLowerLeftCoordYRef); 
	var pxX  = $MapLowerLeftPxXRef + ( $MapUpperRightPxXRef - $MapLowerLeftPxXRef) * (position.coords.longitude - $MapLowerLeftCoordXRef) / ( $MapUpperRightCoordXRef - $MapLowerLeftCoordXRef); 
	var yourLocation = document.getElementById("YourLocation");
	yourLocation.setAttribute("cx",pxX);
	yourLocation.setAttribute("cy",pxY);
      }
      }
      </script>
      <style>
      g.button:hover {opacity:0.5;}
      </style>
      <svg height="$svgYSize" width="$MapDimX">
      <rect x="0" y="0" height="$MapDimY" width="$MapDimX" style="fill: #999999"/>
      <image id="mapimage" x="0" y="$imageYRef" height="$MapDimY" width="$MapDimX" xlink:href="$MapFile" />
      <g class="legend" />
      <circle cx="20" cy="010" r="10" stroke="black" stroke-width="1" fill="blue" opacity=".6"/>
      <text x="30" y="15" font-size="20"> Your Location </text>
      <circle cx="20" cy="30" r="8" stroke="black" stroke-width="1" fill="orange" />
      <text x="30" y="35" font-size="20"> Target location </text>
      <circle cx="220" cy="010" r="5" stroke="black" stroke-width="1" fill="red" />
      <text x="230" y="15" font-size="20"> Reported Location </text>
___EOR

#
# Your GPS position
       my ($markerOffsetX,$markerOffsetY,$MapDimX,$MapDimY) =
	&MapLatLongPxLocation(
	  $q->param("myLatitude"),$q->param("myLongitude"),"Lists/ParcelMapInfo.txt");
	if($markerOffsetX =~ /\d/)
	{
	my $markerY=$markerOffsetY+$Yoffset;
        print <<___EOR; 
      var  pxY  = $Yoffset + $MapLowerLeftPxYRef + ( $MapUpperRightPxYRef - $MapLowerLeftPxYRef) * ( position.coords.latitude - $MapLowerLeftCoordYRef )/( $MapUpperRightCoordYRef - $MapLowerLeftCoordYRef); 
      var  pxX  = $MapLowerLeftPxXRef + ( $MapUpperRightPxXRef - $MapLowerLeftPxXRef) * (position.coords.longitude - $MapLowerLeftCoordXRef) / ( $MapUpperRightCoordXRef - $MapLowerLeftCoordXRef); 
      <g class="button" cursor="pointer" onmouseup="buttonClick(evt)" >
      <circle id="YourLocation" cx=pxX cy=pxY
      r="10" stroke="black" stroke-width="1" fill="blue" opacity=".6" />
___EOR
        }
#
# add target Map:Location
      my ($dum,$dum1,$address)=split(/:/,$UserAction,3);
      if($address)
      { $address=&ParcelvAddress($address);
        my ($markerOffsetX,$markerOffsetY,$MapDimX,$MapDimY)
	=&MapAddressPxLocation($address,"Lists/ParcelMapInfo.txt","MapStreetAddressLL");
	next if($markerOffsetX !~ /\d/);
	my $markerY=$markerOffsetY+$Yoffset;
	 print <<___EOR;
      <g class="button" cursor="pointer" onmouseup="buttonClick(evt)" >
      <circle id="$address" cx="$markerOffsetX" cy="$markerY" 
      r="10" stroke="black" stroke-width="1" fill="orange" opacity=".6"/>
      </g>
___EOR
      }
#####
##### add DamageAddresses
      my @addresses=&DamageReportAddresses;
      @addresses= map { &ParcelvAddress($_) } @addresses;
      @addresses= &uniq( @addresses );
      for(my $i=0; $i<=$#addresses; $i++) 
      { my ($markerOffsetX,$markerOffsetY,$MapDimX,$MapDimY) =
	&MapAddressPxLocation($addresses[$i],"Lists/ParcelMapInfo.txt","MapStreetAddressLL");
	if($markerOffsetX eq 0 )
	{ push(@noLatLon,($addresses[$i]));
	}
	next if($markerOffsetX le 0 );
	my $markerY=$markerOffsetY+$Yoffset;
	print <<___EOR;
	  <g class="button" cursor="pointer" onmouseup="buttonClick(evt)" >
	  <circle id="$addresses[$i]" cx="$markerOffsetX" cy="$markerY" 
	  r="5" stroke="black" stroke-width="1" fill="red" />
	  </g>
___EOR
      }
      print <<___EOR;
      </svg>
      <script>
      getLocation();
      </script>
      <div id="out"></div>
___EOR
    }
    if($#noLatLon>-1)
    { print &COLOR("Red","Addresses not on map:<br>"),join("<br>", @noLatLon);
    }
  }

################################
  print $q->start_multipart_form;
################################
  if( $LastForm =~ "DamageAssessmentForm" ) # in case Back selected
  { 
    $q->param("UserAction","ReviewDamages");
    $q->param("LastAction","ReviewDamages");
  }
  else
  {
    $q->param("LastAction","View Maps");
  }
  &hiddenParamAll($q); # Does not work here ?
  print hr(),$q->submit('action','Back'); 
  print hr(),$q->submit('action','Cancel');
  print $q->end_form;
}

sub MapAddressPxLocation
{ my ($address,$mapInfoFile,$MapStreetAddressLL)=@_;
  if( ! $MapFile )
  { &ParmValueArray( &arrayTXTfile($mapInfoFile) );
  }
  if( ! %MapStreetAddressLL )
  { &TIE("$MapStreetAddressLL");
  }
  $address=&ParcelvAddress($address);
  #$address=~s/(.*$vAddressDelim.*)$vAddressDelim.*/$1/; # NO SubAddress in Parcel Data 
  #&DEBUG("MapAddressPxLocation: $address");
  if( my $data=$MapStreetAddressLL{   $address  } )
  { my ( $LLx, $LLy ) =split(/\t/,$data);
    my $dxpix=
      int($MapLowerLeftPxXRef+
	($MapUpperRightPxXRef-$MapLowerLeftPxXRef)*($LLx-$MapLowerLeftCoordXRef) 
	/ ( $MapUpperRightCoordXRef - $MapLowerLeftCoordXRef));
    my $dypix=
      int($MapLowerLeftPxYRef+
	( $MapUpperRightPxYRef - $MapLowerLeftPxYRef)*($LLy-$MapLowerLeftCoordYRef) 
	/ ( $MapUpperRightCoordYRef - $MapLowerLeftCoordYRef));
    # &DEBUG("MapAddressPxLocation: ($dxpix,$dypix,$MapXdim,$MapYdim)");
    return ($dxpix,$dypix,$MapXdim,$MapYdim);
  }
  else
  { return (0,0,$MapXdim,$MapYdim);
  }
}

sub MapLatLongPxLocation
{ my ($lat,$long,$mapInfoFile)=@_;
  if( ! $MapFile ) {&ParmValueArray( &arrayTXTfile($mapInfoFile) ); }
  { my $LLx=$long; $LLy=$lat; #longitude,latitude data
    my $dxpix=
      int($MapLowerLeftPxXRef+
	($MapUpperRightPxXRef-$MapLowerLeftPxXRef)*($LLx-$MapLowerLeftCoordXRef) 
	/ ( $MapUpperRightCoordXRef - $MapLowerLeftCoordXRef));
    my $dypix=
      int($MapLowerLeftPxYRef+
	( $MapUpperRightPxYRef - $MapLowerLeftPxYRef)*($LLy-$MapLowerLeftCoordYRef) 
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

