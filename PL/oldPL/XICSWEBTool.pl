#!/usr/bin/perl
use URI::Escape;
use CGI::Carp qw/fatalsToBrowser/;
use CGI qw/:standard/;

 no lib "/Users/Tom/Sites/EMPREP/ICSTool/PL";
 use lib "/Users/Tom/Sites/EMPREP/ICSTool/PL";

do "subCommon.pl";
do "subICSWEBTool.pl";
do "subMemberDB.pl";
do "subDamageReport.pl";
do "subManageResponseTeam.pl";
do "subMessageSystem.pl";
#########################
$ENV{ICSdir}="/Users/Tom/Sites/EMPREP/ICSTool/PL";
$ICSdir="/Users/Tom/Sites/EMPREP/ICSTool/PL";
##########################
&initialization;
&initializePersonnel;
########################
&xHTMLHeader;
########################
# global variables
@params=$q->param;

# DEBUG
for(my $i=0; $i<=$#params; $i++)
{ if( $q->param( $params[$i] ) )
  { ${ $params[$i] } = $q->param($params[$i]); 	# Why Does in not fufill followin assignments
    print "<br>>variable assignment: $params[$i] >", $q->param($params[$i]);
  }
}
# DEBUG
print Dump($q); #DEBUG
if($ToolVersion =~/RadioSurvey/ )
{ do "subRadioSurvey.pl";
}
if( &goodName($lastname,$firstname) )
{ $LastFirstName="$lastname.$firstname";
}

if( $UserName )
{ @assignmentOptions=&AssignmentOptions($UserName);
}

######################
print $q->start_multipart_form;

if($ToolVersion eq "RadioSurvey")
{ print $q->h2("Berkeley CERT - Emergency Radio Reception Assessment 10/18/2014");
}
else
{ if( $#params < 0 ) 
  { print $q->h2($q->submit(-name=>'ShowInfo',-value=>'ICS Tool'));
  }
  else
  { print $q->h2("EmPrep ICS Tool");
  }
}
print hr();
######################
&DEBUG("NAME LOGIC: $UserName: $LoginName: $action: $LastAction: $FindByName: $LastFirstName");

if(1 eq 2)
{ if( !$UserName and $LastAction eq "UserInfoForm" and !$FindByName ) 
  { &DEBUG("User Sign In Form"); }
  if( !$UserName and $action eq "Register New User" and !$FindByName ) 
  { &DEBUG("UserInfoForm Enter Information"); }
  if( !$UserName and $LastAction eq "ChangeUserName" and $FindByName ) 
  { &DEBUG("UserInfoForm Names Found Choice/No Names->requery."); 
  }
  if( $UserName and $UserAction eq "Register Volunteers" and !$FindByName ) 
  { &DEBUG("PersonnelInfoForm New"); 
  }
  if( $UserName and $UserAction eq "Register Volunteers" and $FindByName ) 
  { &DEBUG("PersonnelInfoForm Select"); 
  }
  if( $UserName 
      and $UserAction eq "Register Volunteers" 
      and $action eq "Register New User"  ) 
  { &DEBUG("PersonnelInfoForm New search"); 
  }
  if( $UserName 
      and $UserAction eq "Team Status" 
      and $LastAction eq "ManageResponseTeams" ) 
  { &DEBUG("ManageResponseTeams "); 
  }
  if( $UserName 
      and $UserAction eq "PersonnelInfoForm" 
      and $PersonnelName ) 
  { &DEBUG(" &savePersonnelInfo "); 
  }

  if(  (  $LoginName and $UserName ne $LoginName) # UserName changed
    or ( ! $UserName and $action ne "Register New User" )
    or ( ! $UserName and $LastAction eq "UserInfoForm" ) # OK
    or ( ! $UserName and $LastFirstName )
    or ( $FindByName and $action eq "Login" )
)
{ &DEBUG("NAME LOGIC: $UserName: $LoginName: $action: $LastAction: $FindByName: $LastFirstName");
}
}

########################
if( ( my $ishow = &FindMatchQ("ShowInfo:",@params)) >-1 )
{ my ($dum,$info)=split(/:/,$params[$ishow]);
  $q->delete($params[$ishow]);
  &ShowInfoExit($info);
}

if( my $info=$q->param("ShowInfo") )
{ 
  &ShowInfoExit($info);
}

if( $UserAction eq "Register Volunteers" ) # restore UserName
{ $UserName=$LastUserName; # incase UserNamem is used in forms
}

# Update Team info
if( $action eq "Send Team" 
    and $SelectTeam 
    and (($SelectStreet and $SelectAddress) or $vAddress)
)
{ &newCGIfile("ResponseTeams/$SelectTeam", "vAddress", "$vAddress" 
  );
}

if( $action eq "Cancel" or $action eq "Home" ) # restore UserName and DELETE param's to fall to default
{ if($LastUserName)
  { $UserName=$LastUserName; $q->param('UserName',$UserName);
  }
  undef $LastAction; $q->delete("LastAction");
  undef $UserAction; $q->delete('UserAction');
  undef $PersonnelName; $q->delete('PersonnelName');
  undef $FindByName; $q->delete('FindByName');
  &UserAction($q); ####
  exit;
}

################################################################
if( ( ($LoginName and $UserName ne $LoginName) # UserName changed
    or ( ! $UserName and $action ne "Register New User" ) )  # initial Sign In 
    or ( $FindByName and $action eq "Login" )
# selection not processed in ChangeUserName 
  #and $LastAction ne "ChangeUserName" 
    and $LastAction ne "UserInfoForm" 
    and ! $FindByName
  )
  {   &DEBUG("query UserNameChange:",$UserName,"/",$LoginName);
  # SignIn New User
  &ChangeUserName($q);  # check for UserName change
  undef $UserAction;
}

########################
if( $action eq "Register New User" 
    and $UserAction eq "Register Volunteers" )
{ undef $FindByName;	# PersonnelInfoForm called below
}
elsif( #$UserName eq "Register New User" or 
  $action eq "Register New User"
)
{ $q->delete("UserName"); 
  &UserInfoForm($q);
}

elsif ( $LastAction eq "UserInfoForm" # update UserInfo
    or $LastAction eq "Register New User"
) # ADD/CHANGE name
{ my $lastname=$q->param("lastname");
  my $firstname=$q->param("firstname");
  if( &goodName($lastname,$firstname ) # New name OK
  ) # dereference lastname and firstname 
  { $q->delete("UserName"); # init UserName
    $UserName="$lastname.$firstname";
    $q->param("UserName",$UserName);
    &DEBUG("NEW UserName:$UserName");
  }
  else
  { print(&COMMENT("BAD name: Re-enter!"));
    $q->delete("UserName");
    &UserInfoForm($q);
  }
  if( $UserName=$q->param("UserName") ) # just update User info
  { &savePersonnelInfo($q); 
    if( $LastAction eq "Register New User" )
    { $UserName=$LastUserName;
      $q->param("UserName",$UserName);
    }
  }
}

########################
if( $q->param("LastAction") eq "UserInfoForm" )
{ $q->delete("FindByName"); undef $FindByName;
}
##################################
#  
if( $q->param("NewPersonnel") eq "Yes" 
    and &goodName($lastname,$firstname) 
)
{ &savePersonnelInfo($q);
  undef $UserAction; $q->delete("UserAction");
}

my $pname=$q->param("PersonnelName") ;
if( $pname 
    and $pname ne "Register New User"
    and $LastAction eq "PersonnelInfoForm"
) 
{ my $q_person=&update_PersonnelFile($q,$pname);
  &savePersonnelInfo($q_person);
  undef $UserAction; $q->delete("UserAction");
  &DEBUG("Is PersonnelName ever set to New User?");
  # &UserAction($q); do as default in next section
}

##################################
# update User Info 
if( $UserName 
    and ! &file_UserInfo($q) 
    and ! $FindByName )
{ 
  &SetMemberParameters($q); # then get from DB
  &savePersonnelInfo($q);
}

# service FormTeam
if($q->param("LastAction") eq "FormTeam"
    and $q->param("SelectNames")
)
{ &AssignTeamMembers($q);
}
# service Role Assignments
if($q->param("LastAction") eq "AssignRole"
    and $q->param("SelectNames")
)
{ &RoleAssignment($q);
}
##################################
if( &MemberQ(@params,"Ack")<0)
{ &addNewMessages($q);
}

#################################
# UserAction Routines
#################################
if( $UserName )
{ my $type;
  if( $action eq "Main Menu")
  { &UserAction($q);  # should it JUMP
  }
  ################# RadioSurvey
  elsif( $UserAction eq "Report 1610AM Radio Assessment" )
  { if($q->param("LastAction") eq "RadioSurveyForm") 
    { &save_RadioSurvey($q); 
      $q->delete("UserAction");
      print $q->h5("1610AM Radio Assessment for: [$vAddress] received--Thank you"),hr();
      &UserAction($q);  #should it JUMP
    }
    else
    { &RadioSurvey($q); #Main menu
    }
  }
  elsif( 
    $UserAction eq "Review Radio Assessment Data" 
      or
    $LastAction eq "Review Radio Assessment Data" 
  )
  { &RadioSurveyReview($q);
  }
  ################# RadioSurvey
  elsif( $UserAction eq "ReportDamage" )
  { if($q->param("LastAction") eq "DamageAssessmentForm") 
    { &save_DamageAssessment($q); 
      $q->delete("UserAction");
      print $q->h5("Damage Report for: [$vAddress] received--Thank you"),hr();
      if( $action eq "Send Team" )
      { &FormTeam($q);
      }
      else
      { &UserAction($q);  #should it JUMP
      }
    }
    else
    { print ">>UserAction ", $q->param("UserAction" );
      &DamageReportForm($q);
    }
  }
############################
  elsif( $q->param("UserAction") eq "ReviewDamages" )
  { 
    if( $q->param("LastAction") eq "DisplayDamages" and
      $q->param("Address") )
    { $q->param("vAddress", $q->param("Address"));#VADD
      &vAddressStringToParam($q, $q->param("vAddress"));#VADD
      &DamageReportForm($q);
    } 
    elsif( $q->param("LastAction") eq "SelectDamageDisplayForm")
    { my $parm=&SelectDamageAssessment($q);
      &DisplayDamages($parm);
    }
    else
    { 
      if($q->param("LastAction") eq "DamageAssessmentForm") 
      { &save_DamageAssessment($q); 
      }
      if( $action eq "Send Team" )
      { &FormTeam($q);
      }
      elsif($q->param("ResponseTeamAtLocation") and $type="ResponseTeamAtLocation") 
      { &ManageResponseTeams($q,$type);
      }
      else
      { &SelectDamageDisplayForm($q);
      }
    }
  }
  elsif( $q->param("UserAction") eq "Form Response Team" )
  { &FormTeam($q);
  }
  elsif( $q->param("UserAction") eq "ICC Staffing" )
  { &PersonnelStatus($q,"ICC Staffing");
  }
  #############
  elsif( # order matters
    ($type=$q->param("LastAction")) eq "ManageResponseTeams" 
      or 
    ($type=$q->param("UserAction")) eq "Team Status" 
  ) 
  { &ManageResponseTeams($q,$type); 
  }
  #############
  elsif( $q->param("AssignRole") and $q->param("LastAction") eq "PersonnelStatus")
  { &AssignRole($q);
  }
  elsif( $q->param("AssignRole") and $q->param("LastAction") eq "ManageResponseTeams")
  { &AssignRole($q); ##################
  }
  elsif( $q->param("UserAction") eq "EditUserInfo" )
  { &UserInfoForm($q);
  }
  elsif( $UserAction eq "Register Volunteers" )
  { &PersonnelInfoForm($q);
  }
  elsif( $UserAction eq "Message Tool" )
  { &MessageTool($q);
  }
  elsif( my $MessageAction=$q->param("MessageAction") )
  { &MessageAction($q,$MessageAction);
  }
  elsif( $UserAction eq "Set Up Command Center" )
  { &ShowInfoExit('SettingUpICC');
  }
  elsif( $UserAction eq "View Maps" )
  { &ViewMapsForm($q);
  }
  elsif( $UserAction =~ /^Map:/ ) 
  { &ViewMap($q);
  }
  elsif( $UserAction =~ /^Reset ICSTool/ ) 
  { &ResetICSTool($q);
  }
  else
  { &UserAction($q);
  }
}
print	$q->end_html;
