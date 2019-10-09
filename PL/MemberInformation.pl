#!/usr/bin/perl
#
sub MemberInformation
{ my $q=$_[0];
  do "subMemberInformation.pl";
  # print Dump($q);
#######################################################
  $CSVroot="$ICSdir/DB/MasterDB.csv";
  &Set_timestr;
  @requiredInputs=();
  my @list=&readTXTfile("Descriptor");	# Load $CSVroot.Descriptor
  for($i=0;$i<=$#list;$i++)
  { my ($label,$text)=split(/\t/,$list[$i]);
    my $red= &COMMENT("(required)");
    $text=~s/\(required\)/$red/;
    $descriptor{$label}=$text;
    # print "<br>>>>>descriptor $text";
    if($descriptor{$label}=~m/\(required\)/)
    { push(@requiredInputs,$label);
    }
  }
  #  print ">>>>>@requiredInputs";
#######################################################
#	Assign variables from $q->param
  &undefList("NameChoice,FindMyName,action");
  &param2var($q);
  #DD	$StreetName=shift(@StreetName); # if array due to ( other ) 
  if($StreetName =~m/"(Other)"/)
  { $StreetName = ${"(Other)StreetName"};
  }
  #	print "<br>StreetName=$StreetName<<<<";
  &var2param($q,'LastName','FirstName','StreetName','StreetAddress','subAddress');
#	input adjustments
  $FindMyName=~s/[\W\d]//g if($FindMyName); #print "FindMyName ==$FindMyName== <br>";
#######################################################
#print "YYY @DBname HHH";
  &TIE( @DBname );
  &TIE("MapStreetAddressesEmPrep");

  @DBkeys=keys %{"DBmaster"};
  # undef %Images;
  &TIE("Images");
  &TIE("Images/Selfie");
  &TIE("Images/Pets");
  &TIE("Images/Building");

#######################################################
  print &HTMLMemberInfoHeader();
#######################################################
  print $q->h2("Member Information");
#######################################################
  # print "<br>(000 action:$action=$usertype=$FirstName=$LastName=$NameChoice";
  if( ($action eq "Cancel" 
      or $action eq "Finished" )
      and $usertype ne "SingleUser" ) 
  { goto STARTMENU;
  }

  elsif( $action eq "Downloads")
  { goto DOWNLOAD;
  }

  elsif( $action eq "Submit Info") 
  { goto SUBMITINFO;
  }

  elsif( $LastForm eq "ChooseNameForm" and $FindMyName ) 
  { goto CHOOSENAME;
  }

  elsif( $action eq "Modify Images" ) 
  { goto IMAGES_MODIFY;
  }

  elsif( $action eq "Upload Image" ) 
  { goto IMAGES_UPLOAD;
  }

  elsif( $action eq "NewName" ) 
  { # print "AAA $action";
    &undefList("LastName,FirstName");
    goto MEMBERINFOFORM;
  }

  elsif( $action eq "FindMyName" and $FindMyName ) 
  { goto CHOOSENAME;
  }

  elsif( $usertype eq "SingleUser" and $LastName and $FirstName ) 
  { goto MEMBERINFOFORM;
  }

  elsif( $NameChoice ) 
  { ($LastName,$FirstName)=split(/[\t,]/,$NameChoice);
    goto MEMBERINFOFORM;
  }

  elsif( $action eq "FindMyName" and !$FindMyName ) 
  { goto STARTMENU;
  }

  elsif( $LastForm eq "ChooseNameForm" and $FindMyName ) 
  { goto CHOOSENAME;
  }

  else
  { print &COMMENT("<br>=== MENU ERROR ===<br>");
    goto STARTMENU;
  }
#######################
  NEWNAME:
    #  print "<br>YYY NewName $FirstName,$LastName,$action  YYY\n<br>";
    &loadNameData;
    &output_form($q);	# memberForm
    #$q->param("LastForm","NewName");
    #&hiddenParam($q,'LastForm');
    goto EXIT;

  CHOOSENAME:
    # print "<br>YYY CHOOSENAME $FindMyName== YYY";
    undef $LastName,$FirstName,$NameChoice;
    undef %possiblenames;
    my %possiblenames;
    %possiblenames=&FindMyName($FindMyName);
    my @possiblenames=keys %possiblenames;
    # print "<br>XX possiblename >>$FindMyName XXX===",keys %possiblenames,"===";
    #
    my $message=&COLOR("orange","Select your name");
    if($#possiblenames<0)
    { $message=&COMMENT("No names in database matches: $FindMyName");
    }
    my $cmd="<table border=1 width=940 cellspacing=0 cellpadding=5>";
    $cmd.=$message;
    for(my $i=0;$i<=$#possiblenames;$i++)
    { my $i1=$i+1;
      $cmd.="<tr>
      <td><input type=submit name=NameChoice value='$possiblenames[$i]' >
      </td></tr>";
    }
    $cmd.="<tr>
    <td><input type=textfield name=FindMyName placeholder='( Retry )'> 
    <input type=submit name=action value='FindMyName'> 
    </tb> </tr>
    <tr> <td><input type=submit name=action value='Cancel'> </td> </tr>";
    $cmd.="</table></fieldset>";
    print $q->start_form( -name => 'main', -method => 'POST',);
    print $cmd;
    $q->param("LastForm","ChooseNameForm");
    &hiddenParam($q,'LastForm');
    print $q->end_form;
    goto EXIT;

#elsif( $action eq "Cancel" or !$FirstName or !$LastName )
  STARTMENU:
# print "YYY StartMenu YYY";
    print $q->start_form( -name => 'main', -method => 'POST',);

    print &COMMENT("Find your name: ");
    print $q->textfield(-name=>'FindMyName',-size=>20, -placeholder=>'partial name OK') ;
    print $q->submit('action','FindMyName');
    print &COMMENT("<br>If you are not registered, click here: "),
	  $q->submit('action','NewName');
    print "<br>";
    print hr();

    print $q->submit('action','Downloads');

    print $q->end_form;
    goto EXIT;

  SUBMITINFO:
    #print "<br>YYY $action YYY";
    if($StreetName =~ m/\(Other\)/)
    { $StreetName=${"(Other)StreetName"}
    }
    if( ($check=&checkData) eq "ok")
    { #	correct for (Other)StreetName
      #	print "<br>AAA StreetName=$StreetName=",${"(Other)StreetName"};
      #	print "<br>AAA2 StreetName=$StreetName=",join("=",@StreetName);

      $DBrecNumber=${"DBrecName"}{"$LastName\t$FirstName"};
      if($DBrecNumber ge 1)
      { print &COMMENT("<br> $FirstName $LastName -- Updated $DBrecNumber<br>");
      }
      else
      { $DBrecNumber=$#DBkeys+1;
	print &COMMENT("<br> $FirstName $LastName -- Added $DBrecNumber <br>");
      }
      # print "CCC Skills:: $SkillsForEmergency;;@SkillsForEmergency";
      &UpdateDBvariables($DBrecNumber);
      print &COMMENT("!! THANK YOU !!<br>");
      #	
      if( $usertype eq "SingleUser")
      { goto MEMBERINFOFORM;
      }
      #	
      my $cmd="<table border=1 width=940 cellspacing=0 cellpadding=5>";
      $cmd.="<tr>
      <td><input type=textfield name=FindMyName placeholder='( New Name )'> 
      <input type=submit name=action value='FindMyName'> 
      </td> </tr>
      <tr> <td><input type=submit name=action value='Cancel'> 
      </td> </tr>";
      $cmd.="</table></fieldset>";

      print $q->start_form( -name => 'main', -method => 'POST',);
      print $cmd;
      print $q->end_form;
      undef $action;
    }
    else
    { print &COMMENT("<br> Check required fields: "), $check ;
      &output_form($q);	# memberForm
    }
    goto EXIT;

  NEWNAME:
  MEMBERINFOFORM:
    # print "<br>YYY NewName $FirstName,$LastName,$action  YYY\n<br>";
    &loadNameData;
    &output_form($q);	# memberForm
    goto EXIT;

  DOWNLOAD:
    &makeCSV;
    ##################
    my $filename="MasterDB.$yyyymmddhhmmss.csv";
    my $cmd=
    "<table>
    <tr>
      <td>
	<a href=DB/Downloads/$filename download> 
	  Member database: $filename (comma-separated-variable spread sheet)
	</a>
      </td> 
      </tr>
    <tb>";
      $cmd.="</table></fieldset>";

    print $q->h3("Available Downloads");
    print hr();
    print $q->start_form( -name => 'main', -method => 'POST',);
    print $cmd;
    print hr();
    print $q->submit('action','Finished');
    print $q->end_form;
    goto EXIT;
#########################################33
  IMAGES_MODIFY:  
    &loadNameData;
    my $name="$LastName\t$FirstName";
    my $address=&vAddressFromArray($StreetName,$StreetAddress,$subAddress);
    #	print "<br>IMAGES_MODIFY PARM>>>","$name","$address";
    &ImageUpload($q,"$name","$address");
    goto EXIT;
#########################################33
  IMAGES_UPLOAD:  
    &loadNameData;
    #	print ">>>>>>IMAGES_UPLOAD:PARAM:",$q->param;
    $q->delete('action');
    $q->param('action',"Modify Images");
    my $address=&vAddressFromArray($StreetName,$StreetAddress,$subAddress);
    my $name="$LastName\t$FirstName";

    #	print "<br>IMAGES_UPLOAD>>$ImageCategory=$name=$address";
    &save_image_file($ImageCategory,$name,$address);

    goto EXIT;
#########################################33

  EXIT:
  &output_end($q);
  &UNTIE( @DBname );
}

#############################
sub makeCSV
{
  # $downloadfile="$ICSdir/Download/MasterDB.$yyyymmddhhmmss.csv";
  &TIE( @DBname );
  open L1,"$ICSdir/DB/MasterDB.csv" || die;
  open L3,">$ICSdir/DB/Downloads/MasterDB.$yyyymmddhhmmss.csv";
# copy first 2 lines 
#
  for($i=0;$i<2;$i++)
  { $_=<L1>;
    print L3 $_;
  }
#&PrintCol( @DBmasterColumnLabels ); # NOW included in .db as first record
  #
  @recn=sort {$a <=> $b} keys %DBmaster ;
  for($i=0;$i<=$#recn;$i++)
  { $rec=$DBmaster{$recn[$i]};
    $rec=~s/\n//g;
    @col=split(/\t/, $rec);
    $#col=$#DBmasterColumnLabels;
    # print ">>$i:$rec ($#col) \n";
    &PrintCol(@col);
  }
}
1;

