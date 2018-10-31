#!/usr/bin/perl
do "subCommon.pl";

sub pixelMapLoc
{ my ($address)=@_;
  my $mapInfo="../../Maps/parcelMap1.info.txt";
  my @mapInfo=&arrayTXTfile($mapInfo);
  my ( $LLutmx, $LLutmy, $LLxpix, $LLypix );
  my ( $URutmx, $URutmy, $URxpix, $URypix );
  foreach my $l (@mapInfo)
  { my ($var,$value)=split(/=/,$l,2);
    $value=~s/[{}\s]//g; 
    for( $var )
    { if( /^Xpixs/ ) { ${$var}=$value; }
      elsif( /^Ypixs/ ) { ${$var}=$value; }
      elsif( /^LowerLeftRef/ ) 
      { ( $LLutmx, $LLutmy, $LLxpix, $LLypix )=split(/,/,$value);
      }
      elsif( /^UpperRightRef/ ) { }
      { ( $URutmx, $URutmy, $URxpix, $URypix )=split(/,/,$value);
      }
    }
  }
# GET pixel location from Address
  &TIE("parcelsByAddress");
  $address=uc($address);
  if( my $data=$parcelsByAddress{$address} )
  { my @data=split(/\t/,$data);
    my $utmx=$data[11]; $utmy=$data[12];
    my $dxpix= int( ($URxpix-$LLxpix)*($utmx-$LLutmx) / ($URutmx-$LLutmx))."px";
    my $dypix= int( ($LLypix-$URypix)*($utmy-$URutmy) / ($LLutmy-$URutmy))."px";
    return ($dxpix,$dypix);
  }
  else
  { print "No Location Data";
  }
}

sub MapAddressPxLocation
{ my ($address,$mapInfoFile,$AddressUtmDB)=@_;
  &ParmValueArray( &arrayTXTfile($mapInfoFile) );
  &TIE("$AddressUtmDB");
  $address=uc($address);
  if( my $data=$parcelsByAddress{$address} )
  { my @data=split(/\t/,$data);
    my $utmx=$data[11]; $utmy=$data[12];
    my $dxpix= int(($MapUpperRightPxXRef-$MapLowerLeftPxXRef)*($utmx-$MapLowerLeftUtmXRef) / ($MapUpperRightUtmXRef-$MapLowerLeftUtmXRef))."px";
    my $dypix= int(($MapLowerLeftPxYRef-$MapUpperRightPxYRef)*($utmy-$MapUpperRightUtmYRef) / ($MapLowerLeftUtmYRef-$MapUpperRightUtmYRef))."px";
    return ($dxpix,$dypix,$MapXdim,$MapYdim);
  }
  else
  { print "No Location Data";
  }
}


if(1==0)

  { my ($dum,$dum1,$address)=split(/:/,$UserAction,3);
    my ($pixelX,$pixelY)=&MapAddressPxLocation($address,"Lists/ParcelMapInfo.txt","parcelsByAddress");
    my $markerOffsetX=$pixelX; 
    $markerOffsetX=~s/px//; $markerOffsetX-=10; $markerOffsetX="$markerOffsetX"."px";
    my $markerOffsetY=$pixelY; 
    $markerOffsetY=~s/px//; $markerOffsetY-=10; $markerOffsetY="$markerOffsetY"."px";
    print "$pixelX,$pixelY,$markerOffsetX,$markerOffsetY\n";
    print <<___EOR;
<div class="map" id="parcelmap"> 
  <img class="mapclass" src='$MapFile' alt="Parcel Map"> </img>
  <canvas class="map_marker" id="markercanvas" width="20" height="20" style="border:1px solid #FF0000;">
</canvas>
</div>
<script>
var map =  document.getElementById("parcelmap");
map.position="relative";

var c = document.getElementById("markercanvas");
c.style.top="$markerOffsetY";
c.style.left="$markerOffsetX";
var ctx = c.getContext("2d");
ctx.beginPath();
ctx.arc(10,10,4,0,2*Math.PI);
ctx.strokeStyle="blue";
ctx.stroke();
</script>
___EOR
    ################################
  }

@v=&MapAddressPxLocation("1643 Le Roy Ave","Lists/ParcelMapInfo.txt","parcelsByAddress");
print "@v\n";
