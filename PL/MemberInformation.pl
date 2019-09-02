#!/usr/bin/perl
#
#	use warnings;
use CGI;
$ICSdir="/Users/Tom/Sites/EMPREP/ICSTool/PL";
no lib $ICSdir; # needs to be preset ?? do we need this ??
use lib "/Users/Tom/Sites/EMPREP/ICSTool/PL"; # this seems to be needed explicitly on OSX
do "subMemberInformation.pl";
&initialization;
#print Dump($q);
#print $ENV{QUERY_STRING};
#######################################################
$CSVroot="$ICSdir/DB/MasterDB.csv";
#######################################################
#######################################################
#	Assign variables from $q->param
&undefDBvar;	 # print "LLL @DBmasterColumnLabels LLL";
&undefList("NameChoice,FindMyName,action");
@params=$q->param;
# print "PPP:@params"; # BirthYear has a ","
for(my $i=0; $i<=$#params; $i++)
{ my $p=$params[$i];
  if( my @val=$q->param( $p ) )
  { # print "<br>VVV:$p==@val ";
    my @var=$q->param( $p );  # Why Does it not fufill followin assignments
    if($#var>0) { @{ $p } = @var; }
    else { ${ $p } = $var[0]; }
    # print "<br>>variable: $p >", $q->param($p),">>",${ $p },">>",@{ $p };
  }
}
$q->delete_all();
#	input adjustments
$FindMyName=~s/[\W\d]//g if($FindMyName); #print "FindMyName ==$FindMyName== <br>";
#######################################################
#print "YYY @DBname HHH";
&TIE( @DBname );
@DBkeys=keys %{"DBmaster"};
#######################################################
&Eval_QUERY_STRING;
#######################################################
print &HTMLMemberInfoHeader();
#######################################################
print $q->h2("Member Information");
#######################################################
# print "<br>(000 action== $action == $LastForm == $NameChoice == $FindMyName)";
if( ($action eq "Cancel" 
    or $action eq "Finished" )
    and $mode ne "SingleUser" ) 
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

elsif( $action eq "NewName" ) 
{ # print "AAA $action";
  &undefList("LastName,FirstName");
  goto MEMBERINFOFORM;
}

elsif( $action eq "FindMyName" and $FindMyName ) 
{ goto CHOOSENAME;
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
#if( ( $action eq "NewName" )) 
#{ 
NEWNAME:
  #  print "<br>YYY NewName $FirstName,$LastName,$action  YYY\n<br>";
  &loadNameData;
  &output_form($q);	# memberForm
  #$q->param("LastForm","NewName");
  #&hiddenParam($q,'LastForm');
  goto EXIT;
  #}

#elsif( ($action eq "FindMyName") and $FindMyName ) 
  #{ 
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
  #}

#elsif( $action eq "Cancel" or !$FirstName or !$LastName )
#{ 
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

  #print hr();
  #  print $q->h2("Available Downloads");
  print $q->submit('action','Downloads');

  print $q->end_form;
  goto EXIT;

  #{ 
SUBMITINFO:
  #print "<br>YYY $action YYY";
  if( &checkData eq "ok")
  { #	correct for ( other ) StreetName
    # print "<br>AAA StreetName $StreetName: @StreetName===";
    @StreetName=&deleteElements("( Other )\t( Choose )",@StreetName);
    if(!$StreetName){ $StreetName=$StreetName[0]; }
    # print "<br>AAA1 StreetName ===$StreetName===@StreetName===";
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
    if( $mode eq "SingleUser")
    {
      goto MEMBERINFOFORM;
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
  { print &COMMENT("<br> Check required fields: "), $ok ;
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
  my $cmd="
  <table>
  <tr>
    <td>
      <a href=DB/Downloads/$filename download> 
	Member database: $filename (comma-separated-variable spread sheet)
      </a>
    </td> 
    </tr>
  <tb>

    ";
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
EXIT:
&output_end($q);
&UNTIE( @DBname );
exit 0;

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

