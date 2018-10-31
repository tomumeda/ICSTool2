#!/usr/bin/perl
#################################
sub initializePersonnel
{ my @tmp;
  @skillsDesc=&arrayTXTfile("../Lists/Skills.txt");
  @skills= map {  @tmp=split(/\t/,$_); $tmp[0]  } @skillsDesc;
  @rolesNN=&arrayTXTfile("../Lists/Roles.txt");
  @roles= map {  @tmp=split(/\t/,$_); $tmp[0]  } @rolesNN;
  close L;
  ($skills_ref,$NamesByRole_ref,$RoleByName_ref)=&PersonnelInfo;
}

# returns CGI param INFO from Personnel/$nameLastFirst
sub loadPersonnelFile 
{ my ($nameLastFirst) = @_; 
  #print ":* $nameLastFirst ";
  my ($lastname,$firstname)=split(/[\.\s]/,$nameLastFirst);
  my $filename="Personnel/$nameLastFirst";
  my $q=0;
  if(-e $filename) #only if there is a restore file
  { if (open(FILE,$filename))
    { $q = new CGI(FILE); # read info from FILE
      close FILE;
      return $q;
    } 
  }
  return $q;
}

# writes Personnel Info to FILE
sub savePersonnelInfo
{ my ($q) = @_;
  my $firstname=$q->param("firstname"); # NEED because $q is variable
  my $lastname=$q->param("lastname");
  &DEBUG("savePersonnelInfo:$UserName,$firstname,$lastname");
  if( !$firstname and !$lastname  
      and $firstname eq "First Name" or $lastname eq "Last Name") #BAD name
  { return();
  }
  # do not use UserName, may be for someone else.
  my $name="$lastname.$firstname";
  my $file="Personnel/$name";
  &saveParmsCGIfile($q,$file,
   'firstname,lastname,assignment,@skills,ContactInformation');
  #
  $file="PersonnelLog/$name";
  $q->param("UXtime",$UXtime);
  $q->param("time",$timestr);
  &logParmsCGIfile($q,$file,
   'firstname,lastname,assignment,@skills,ContactInformation,UXtime,time');
  if($q->param("NewPersonnel") eq "Yes")
  {
  }
}

# returns matching names in Personnel/* from $search
sub SelectPersonnelNames
{ local(%foundnames);
  my $search=@_[0];
  my @search=split(/[\s,;\n]+/,$search);
  my @name=&PersonnelNames;
  for(my $i=0;$i<=$#name;$i++)
  { my $tname=$name[$i];
    if( &AllMatchQ( $tname,@search ) )
    { $foundnames{$tname}=$DBrecName{$tname} ;
    }
  }
  return(%foundnames);
}

# Lists file names in Personnel directory. lastname.firstname formst
sub PersonnelNames 
{ my $f,$d,@list;
  foreach $f (<Personnel/*>)
  { ($d,$f)=split("/",$f);
    push @list, $f;
  }
  return @list;
}

###
sub FormTeam
{ my ($q) = @_;
  my $delim=";";
  my ($files,$f,$d,@list,@names,$names,$name,@tmp);
  my $file="ResponseTeams/lastNumber";
  open L,$file;
  my $lastNumber=<L>;
  ++$lastNumber;
  open L,">$file";
  print L $lastNumber,"\n";
  close L;
  my $responseteam="Response Team $lastNumber";
  &AddTeamMember($q,$responseteam);
}

sub AddTeamMember
{ my ($q,$responseteam) = @_;
  my $delim=";";
  my ($files,$f,$d,@list,@names,$names,$name,@tmp);
  #
  print $q->start_multipart_form;
  print &BOLD(&COMMENT("Compose: ")), &BOLD("$responseteam");
  $q->param( 'SelectTeam', $responseteam ) ;
  print "<br>",&COMMENT("Select Personnel from Skill Groupings."),"<br>";
  $cmd="<fieldset> <table border=1 width=940 cellspacing=0 cellpadding=5> ";
  $cmd.="<tr><td>".&COMMENT("Name")
  .  " </td> <td>".&COMMENT("Current Assignment")." </td> </tr>";
  $cmd.=" </table> </fieldset>";
  print $cmd;
  foreach my $skill (sort keys %$skills_ref) 
  { my %labels;
    $names=$skills_ref->{$skill};
    @names=split ";",$names;
    foreach $name (@names)
    { $in=$RoleByName_ref->{$name};
      $in=~s/$delim$//;
      if(length($in)>0 && $in !~ /Unassign/)
      { $labels{$name}="$name ----------> ($in) "; }
      else
      { $labels{$name}="$name"; }
    }
    $cmd="<fieldset>
    <legend><strong>$skill</strong></legend>
    <table border=1 width=940 cellspacing=0 cellpadding=5> ";
    for(my $i=0;$i<=$#names;$i++)
    { my $name=$names[$i];
      my $in=$RoleByName_ref->{$name};
      $cmd.="<tr><td> <label>
      <input type=checkbox name='SelectNames' value=$name > $name
      </label> </td> <td> $in </td> </tr>";
    }
    $cmd.=" </table> </fieldset>";
    print $cmd;
  }
  $q->param("LastAction","FormTeam");
  #print "## ##",$q->param("SelectStreet");
  push (@actions,'Submit'); 
  &SubmitActionList(@actions);
  &hiddenParam($q,'UserName,LastAction,SelectTeam,SelectStreet,SelectAddress');
  print $q->endform;
}

sub AssignTeamMembers
{ my $q=$_[0];
  my $mess;
  my @names=&uniq($q->param("SelectNames"));
  my $assignment=$q->param("SelectTeam");
  $q->param("assignment",$assignment);
  # update Personnel/files
  foreach my $name (@names)
  { my $file="Personnel/$name";
    &addParmsCGIfile($q,$file,'assignment');
    # Build Message
    &addMessage("$name: assigned to $assignment.", $UserName, $name, $name);
  }
  if( $#names>=0 )
  { &addMessage("(@names) assigned to $assignment.",$UserName,$UserName,$UserName);
  }

  # update ResponseTeams/files
  my $file="ResponseTeams/$assignment";
  if( $q->param("SelectStreet") and $q->param("SelectAddress"))
  { &saveParmsCGIfile($q,$file,"SelectStreet,SelectAddress");
  }
  else
  { &newCGIfile($file)
  }
  # Team log update
  $file="ResponseTeamLogs/$assignment";
  $q->param('time',$timestr);
  &logParmsCGIfile($q,$file,'time,SelectStreet,SelectAddress,SelectNames');
  ############################
}

# 
sub update_PersonnelFile
{ my ($q,$name)=@_;
  my $qp=&load_PersonnelFile($name);
  my @list=$q->param ;
  &DEBUG("update_PersonnelFile: $name");
  #print "##::$list ::",$qp->param("skills");
  foreach my $parm (@list)
  { next if($parm =~ /UserName/);
    $qp->param($parm,$q->param($parm));
  }
  return $qp;
}

# 
sub load_PersonnelFile
{ my $name=@_[0];
  my ($lastname,$firstname) = split(/\./,$name,2);
  my $file="Personnel/$name";
  open(FILE,$file);
  my $qp=new CGI(FILE);
  close(FILE);
  $qp->param("firstname",$firstname);
  $qp->param("lastname",$lastname);
  return $qp;
}

# Note: SetMemberParameters from DB
sub SetMemberParameters
{ my $q = @_[0];
  my $name=$q->param("UserName");
  my ($lastname,$firstname) = split(/\./,$name,2);
  # Load from DB
  &TIE( @DBrecLabels );
  my $recno = $DBrecName{"$lastname\t$firstname"};
  my $rec=$DBmaster{ $recno }; 
  my @col=split(/\t/, $rec);
  my $memberskills=$col[$DBcol{SkillsForEmergency}];
  my @memberskills;
  foreach my $skill (@skills)
  { my @search=split(/[^a-z]/,lc($skill));
    if( &AllMatchQ( $memberskills, @search ) == 1)
    { push(@memberskills,$skill);
    }
  }
  $q->param("skills",@memberskills);
  $q->param("firstname",$firstname);
  $q->param("lastname",$lastname);
  $q->param("assignment","Unassigned");
  &UNTIE( @DBrecLabels );
  return $q;
}

# test if UserName needs chnaging and does FindByName dialog 
sub ChangeUserName 
{ my $q=@_[0];
  my $partialNameOK="string: 'tom'";
  &DEBUG("ChangeUserName:$UserName:$LoginName:$FindByName");
  my $LastFindByName=$q->param("LastFindByName");
  if($LastFindByName ne $FindByName)
  { $q->delete("UserName");
  }
  if( $FindByName eq $partialNameOK) # ?
  { $q->delete("FindByName"); # ?
    undef $FindByName; # ?
  } # ?
  #
  #######################
  if( $UserName eq "Register New User" ) # ?
  { $q->delete("UserName"); # ?
    undef $UserName; undef @UserName; # ?
  } # ?
  ###
  print $q->start_multipart_form;
  if( $UserName ne $LoginName ) # UserName changed in form 
  { if( ! $FindByName ) # set FindByName
    { $q->param("FindByName","$LoginName"); 
      $FindByName=$LoginName;
    }
    $q->delete("UserName");
  }
  if( $FindByName ) #FindByName AND not first call
  { &printFindByNameTable($q,"UserName");
    $q->delete("UserName"); undef $UserName;
  }
  elsif( ! $UserName and (! $FindByName and ! $LastFirstName )  )  # initial Sign In
  { 
    print $q->h3("Sign In",
      $q->submit(-name=>'ShowInfo:SignIn' , -value=>'help' )); 
    print &COMMENT("Find database name from $partialNameOK.");

    print $q->textfield(-name=>'FindByName',-size=>20) ;
    print $q->submit('action','Search');
    print &COMMENT("<br>or "),$q->submit('action','Register New User');
  }
  #########################
  $q->param("LastAction","ChangeUserName");
  &hiddenParam($q,'UserAction,LastUserName,LastAction,UserName,LastFindByName');
  print $q->endform;
}

sub subUserAction
{ my ($q,$role)=@_;
  sub datarec
  { my $val=$_[0];
    my $str ="<tr>".
      "<td> <input type=submit name='UserAction' value='$val'></td>".
      "<td> <input type=submit name='ShowInfo:$val' value='help'></td>".
      "</tr> ";
  } 
  &headerMessages("$UserName");
  print $q->h3("What do you want to do?");
  my $cmd="<fieldset><table border=1 width=940 cellspacing=0 cellpadding=5> ";
  $cmd.="<tr>";
  $cmd.=&datarec("ReportDamage");
  $cmd.=&datarec("ReviewDamages");
  $cmd.=&datarec("ICC Staffing");
  $cmd.=&datarec("Form Response Team");
  $cmd.=&datarec("Team Status");
  $cmd.=&datarec("Register Volunteers");
  #  $cmd.=&datarec("Message Management");
  $cmd.=&datarec("Set Up Command Center");
  $cmd.=&datarec("View Maps");
  $cmd.=&datarec("EditUserInfo");
  $cmd.="</table></fieldset>";
  print $cmd;
  #print &COMMENT("* Not implemented.<br>");
  #print $q->submit("UserAction","*Send/Receive Messages"),"<br>";
  #print $q->submit("UserAction","*Injured/Lost People Status"),"<br>";
  #print $q->submit("UserAction","*Manage Inventory"),"<br>";
  #print $q->submit("UserAction","*Set Up Command Center"),"<br>";
  #print $q->submit("UserAction","*Learn About My Duties"),"<br>";
}

sub UserAction
{ my ($q)=@_;
  my $value,@results,$i,@actions,$rec,@uniqname;
  #$UserName=$q->param('UserName');
  $q->param("LastUserName",$UserName);
  my $LastUserName=$q->param("LastUserName");
  #
  print $q->start_multipart_form;
  #
  print &BOLD("ICS User: ");  # UserName may change
  $LoginName=$UserName;
  print $q->textfield(-name=>'LoginName',-value=>$LoginName,-size=>20);
  print $q->submit('action','ChangeUser');
  ##################
  my $assignment=$RoleByName_ref->{$UserName};
  if($assignment)
  { print &COMMENT("<br>Assignment: "),
    $q->submit("ShowInfo",$assignment,$assignment);
  }
  ###################
  &subUserAction($q,$UserRole);
  $q->delete("FindByName");
  $q->param("LastAction","UserAction"); 
  $q->param("UserName","$UserName"); 
  &hiddenParam($q,'UserName,LastAction,LastUserName');
  print $q->endform;
}

# Create User Information form
sub UserInfoForm
{ my ($q)=@_;
  &DEBUG("##:UserInfoForm","$UserName,$LastUserName,");
  if( $UserName=$q->param('UserName') )
  { ($lastname,$firstname) = split(/\./,$UserName,2);
    print &BOLD(&COMMENT("Edit Information for: ").$UserName);
  }
  else
  { print $q->h3("Enter Information:");
  }
  my @myskills=$q->param('skills');
  my $assign=$q->param('assignment');
  $assign=&clean_name($assign);
  ##
  print $q->start_multipart_form;
  if($UserName)
  { $q->param(-name=>"lastname",-value=>"$lastname"); 
    $q->param(-name=>"firstname",-value=>"$firstname"); 
    print $q->hidden(-name=>"lastname",-value=>"$lastname"); 
    print $q->hidden(-name=>"firstname",-value=>"$firstname"); 
  }
  else
  { print 
    $q->textfield(-name=>'firstname',-value=>"First Name",-size=>20),
    $q->textfield(-name=>'lastname',-value=>"Last Name",-size=>20);
    print "<br>";
  }
  #
  &printSkillsTable(\@myskills,\@skills,$assign);
  ############################
  $q->param("LastAction","UserInfoForm"); #???seem to need
  &hiddenParam($q,"UserName,LastUserName,LastUserAction,LastAction");
  push (@actions,'Submit',"Cancel"); 
  &SubmitActionList(@actions);
  print $q->endform;
}

# Create Personnel Information form
sub PersonnelInfoForm
{ my ($q)=@_;
  &DEBUG( "##: PersonnelInfoForm: $UserName " . $q->param("UserName") );
  print $q->start_multipart_form;
  if( $FindByName ) #FindByName second time through->choice menu
  { &printFindByNameTable($q,"PersonnelName");
  }
  else
  { if( $PersonnelName=$q->param('PersonnelName') )
    { my ($lastname,$firstname) = split(/\./,$PersonnelName,2);
      $q->param("lastname","$lastname"); 
      $q->param("firstname","$firstname"); 
      print $q->hidden("lastname","$lastname"); 
      print $q->hidden("firstname","$firstname"); 
      print &BOLD(&COMMENT("Information for: ").$PersonnelName);
    }
    else
    { print $q->h3("New Personnel Information:");
      $q->delete("skills"); 
      $q->param("assignment","Unassigned"); 
      &printNewNameForm($q);
      $q->param("NewPersonnel","Yes");
    }
    my @myskills=$q->param('skills');
    my $assign=$q->param('assignment');
    &printSkillsTable(\@myskills,\@skills,$assign);
    push (@actions,'Submit'); 
  }
  ############################
  $q->param("LastAction","PersonnelInfoForm"); #???seem to need 
  &hiddenParam($q,"UserName,PersonnelName,UserAction,NewPersonnel,LastUserAction,LastAction,LastUserName");
  push (@actions,'Cancel'); 
  &SubmitActionList(@actions);
  print $q->endform;
}

# updates UserInfo from Personnel/FILE 
sub file_UserInfo 
{ my $q=$_[0];
  my $parms="UserName,firstname,lastname,skills,assignment,ContactInformation";
  my $updated=0;
  my $UserName=$q->param("UserName");
  &DEBUG("file_UserInfo",$UserName);

  my $filename="Personnel/$UserName";
  if( -f $filename ) #only if there is a restore file
  { if( open(FILE,$filename) )
    { my $qx = new CGI(FILE); # read info from FILE
      close FILE;
      if( $qx )
      { my @parm=split(/,/,$parms);
	foreach $p (@parm)
	{ if( $qx->param($p) )
	  { $q->param($p,$qx->param($p));
	  }
	}
	$updated=1;
      }
    } 
  }
  return $updated;
}

# find members and Personnel by name
sub findPeopleByName 
{ my $q=@_[0];
  my $FindByName= $q->param("FindByName");
  &TIE( @DBrecLabels );
  my %MemberNameRec=&FindName($FindByName);
  my @membernames= keys %MemberNameRec ;
  #name format: lastname.firstname
  for(my $i=0;$i<=$#membernames;$i++) { $membernames[$i]=~s/[\t]/./; }
  my %PersonnelNames=&SelectPersonnelNames($FindByName);
  my @personnelnames=keys %PersonnelNames;
  push( @personnelnames , @membernames ) ;
  @uniqname = &uniq (@personnelnames) ;
  return @uniqname ;
}

sub changeNL2character
{ my @a=@_;
  for(my $i=0; $i<=$#a; $i++)
  { $a[$i]=~s/\n/; /g;
  }
  return @a;
}

# returns 3 HASH reference: $skills_ref $NamesByRole_ref $RoleByName_ref
sub PersonnelInfo
{ my $delim=";";
  undef $skills_ref; 
  undef $NamesByRole_ref;
  foreach my $file (<Personnel/*>)
  { my ($d,$name)=split(/\//,$file);
    open(FILE,$file);
    my $q = new CGI(FILE);
    my @skill=$q->param("skills");
    if($#skill>=0)
    { foreach my $skill (@skill)
      { $skills_ref->{$skill}.="$name$delim";
      }
    }
    else
    { $skills_ref->{"Unspecified"}.="$name$delim"; #TEST
    }
    my $assignment=$q->param("assignment");
    $NamesByRole_ref->{$assignment}.="$name$delim";
    $RoleByName_ref->{$name}="$assignment";
  }
  return ($skills_ref,$NamesByRole_ref,$RoleByName_ref);
}
#############
sub example
{ ($skills_ref,$NamesByRole_ref,$RoleByName_ref) = &PersonnelInfo;
  print "== skills\n";
  map { print "$_ --> $skills_ref->{$_}\n"; } keys %$skills_ref ;
  print "== NamesByRole\n";
  map { print "$_ --> $NamesByRole_ref->{$_}\n"; } keys %$NamesByRole_ref ;
  print "== RoleByName\n";
  map { print "$_ --> $RoleByName_ref->{$_}\n"; } keys %$RoleByName_ref ;
}
#############

sub PersonnelStatus
{ my ($q,$level)=@_;
  #########################
  print $q->start_multipart_form;
  sub xPrint
  { my $role=$_[0];
    my ($role,$level)=split(/\t/,$_[0]);
    $level=~s/LEVEL.//;
    my $ndots=">" x ($level-1);
    my $cmd="<table border=1 width=940 cellspacing=0 cellpadding=5> ";
    #print "$role";##DEBUG
    if( $NamesByRole_ref->{$role} )
    { my $out= " $NamesByRole_ref->{$role}"; 
      $out=~s/;/, /g;
      $cmd.="<tr><td> 
      <label for 'role'>$ndots</label>
      <input type=submit name='AssignRole' value='$role' >
      </td> <td> $out </td> </tr>";
    }
    else
    { $cmd.="<tr> <td> 
      <label for 'role'>$ndots</label>
      <input type=submit name='AssignRole' id='role' value='$role' >
      </td> </tr>";
    }
    $cmd.="</table> </fieldset>";
    print $cmd;
  }
  ###################
  #print $q->start_multipart_form;
  my @tmp;
  if($level eq "ICC Staffing")
  { print $q->h4(&COMMENT("ICC Personnel Assignment"));
    $cmd="<fieldset> <table border=1 width=940 cellspacing=0 cellpadding=5> ";
    $cmd.="<tr><td>".&COMMENT("Role")
    .  " </td> <td>".&COMMENT("Current Personnel")." </td> </tr>";
    $cmd.=" </table> </fieldset>";
    print $cmd;
    my @rolesICC0 = &deleteNullItems
    ( map { @tmp=split(/\t/,$_); ($tmp[2]!~/MultiPerson/i)?"$tmp[0]\t$tmp[1]":"" ; } @rolesNN);
    foreach my $role (@rolesICC0)
    { &xPrint($role);
    }
    $q->param("LastAction","PersonnelStatus");
  }
  print $q->submit('action','Home');
  #$q->param("LastAction","PersonnelStatus");
  &hiddenParam($q,'LastAction,UserName');
  print $q->endform;
}

sub AssignRole
{ my ($q) = @_;
  my $delim=";";
  my ($files,$f,$d,@list,@names,$names,$name);
  @teams = map { @tmp=split(/\t/,$_); ($tmp[2] !~ /ResponseTeam/) ? $tmp[0]:""; } @rolesNN;
  @teams=&deleteNullItems(@teams);
  my $assignrole=$q->param("AssignRole");
  #print $q->start_multipart_form;
  print &COMMENT(&BOLD("Assign Role: ")).&BOLD("$assignrole");
  print "<br>",&COMMENT("Select Personnel from Skill Groupings."),"<br>";
  $cmd="<fieldset> <table border=1 width=940 cellspacing=0 cellpadding=5> ";
  $cmd.="<tr><td>".&COMMENT("Name")
  .  " </td> <td>".&COMMENT("Current Assignment")." </td> </tr>";
  $cmd.=" </table> </fieldset>";
  print $cmd;
  foreach my $skill (sort keys %$skills_ref) 
  { my %labels;
    $names=$skills_ref->{$skill};
    @names=split ";",$names;
    foreach $name (@names)
    { $in=$RoleByName_ref->{$name};
      $in=~s/$delim$//;
      if(length($in)>0 && $in !~ /Unassign/)
      { $labels{$name}="$name ----------> ($in) "; }
      else
      { $labels{$name}="$name"; }
    }
    $cmd="<fieldset>
    <legend><strong>$skill</strong></legend>
    <table border=1 width=940 cellspacing=0 cellpadding=5> ";
    for(my $i=0;$i<=$#names;$i++)
    { my $name=$names[$i];
      my $in=$RoleByName_ref->{$name};
      $cmd.="<tr><td> <label>
      <input type=radio name='SelectNames' value=$name > $name
      </label> </td> <td> $in </td> </tr>";
    }
    $cmd.=" </table> </fieldset>";
    print $cmd;

  }
  $q->param("LastAction","AssignRole");
  push (@actions,'Submit'); 
  &SubmitActionList(@actions);
  &hiddenParam($q,'UserName,LastAction,AssignRole');
  print $q->endform;
}

sub RoleAssignment
{ my $q=$_[0];
  my $assignment=$q->param("AssignRole");
  my $mess;
  # unassign people from solo roles
  # print "$assignment --> $NamesByRole_ref->{$assignment}";
  { my @unassign=split(/;/,$NamesByRole_ref->{$assignment});
    foreach my $name (@unassign)
    { my $file="Personnel/$name";
      open(FILE,$file);
      my $q = CGI->new(FILE);
      $q->delete("assignment");
      open(FILE,'>',$file);
      $q->save(FILE);
      # Build Message
      &addMessage("$name: unassigned from $assignment.",$UserName,$name,$name);
    }
    if( $#unassign >=0 )
    { &addMessage("(@unassign) unassigned from $assignment.",$UserName,$UserName,$UserName);
    }
  }
  #add new assignment
  my @names=&uniq($q->param("SelectNames"));
  foreach my $name (@names)
  { my $file="Personnel/$name";
    open(FILE,$file);
    my $q = CGI->new(FILE);
    # Unassign others from this role if not MultiPerson
    $q->param("assignment",$assignment);
    open(FILE,'>',$file);
    $q->save(FILE);
    # Build Message
    &addMessage("$name: assigned to $assignment.",$UserName,$name,$name);
  }
  close FILE;
  if($#names>=0)
  { &addMessage("(@names) assigned to $assignment.",$UserName,$UserName,$UserName);
  }
  $q->delete("SelectNames");
}

sub StreetAddressForm
{ my ($q,$street,$address,$retain)=@_;
  #print $q->start_multipart_form;
  print $q->h3("Specify Location by");
  print &SelectDamageAddress;
  if(! $street )
  { print $q->h3("Select Street Name");
    for(my $i=0;$i<=$#street;$i++)
    { print $q->submit("SelectStreet","$street[$i]"),"<br>";
    }
    print &COMMENT("or add: "),$q->textfield("NewStreetName","New Street Name",25,50);
  }
  elsif(! $address)
  { print &COMMENT(&BOLD("Select address on:"))," $street<br>";
    my @addresses=&StreetAddresses($street);
    for(my $i=0;$i<=$#addresses;$i++)
    { my $address=$addresses[$i];
      $labels{"$address"}= "$address $street";
    }
    for(my $i=0;$i<=$#addresses;$i++)
    { print $q->submit("SelectAddress","$addresses[$i]"),"<br>";
    }
    print &COMMENT("or add: "),$q->textfield("NewAddress","New Address",25,50);
  }
  &hiddenParam($q,$retain);
  print $q->endform;
}

# prints Skill and assignment table
sub printSkillsTable
{ my ($myskills,$skills,$assign)=@_;
  my @skills=@{$skills};
  my @myskills=@{$myskills};
  my $cmd="<fieldset> <legend><strong>Skills:</strong></legend>
  <table border=1 width=700 cellspacing=0 cellpadding=5>
  <tr>";
  for(my $i=0;$i<=$#skills;$i++)
  { $checked="";
    if(&MemberQ(@myskills,$skills[$i])>=0){$checked="checked"; }
    $cmd.="<tr><td> 
    <label>
      <input type=checkbox name=skills
      value='$skills[$i]' $checked >$skills[$i]
    </label> ";
    $cmd.="</td></tr>";
  }
  $cmd.="</table> </fieldset>";
  print $cmd;
  # assignments
  my @localroles=@roles;
  if( ($assign ne "Unassigned") ) 
  { @localroles=($assign,@roles);
    $q->param("assignment",$assign);
  }
  print "<STRONG>Assignment:$assign </STRONG>",
    $q->popup_menu('assignment',[ @localroles ],$assign) ;
  print "<br><STRONG>Contact info:</STRONG>";
  print "<BR>",
    $q->textarea(-name=>'ContactInformation',
    -rows=>2,
    -columns=>30), "<P>";
}

sub printFindByNameTable
{ my ($q,$var)=@_; 
  my @uniqname = &findPeopleByName($q); 
  if($#uniqname>=0)
  { my $tmp=$#uniqname+1; 
    print $q->h3("Names($tmp) found for:");
    print $q->textfield(-name=>'FindByName' ,-size=>20) ,
    "<input type=submit name=action value='Redo Search'>" ;
    ###############################
    my $cmd="";
    $cmd.="<fieldset> <legend>".&COMMENT("<strong>Select Name</strong>")
    ."</legend>
     <table border=1 width=940 cellspacing=0 cellpadding=5>";
    for(my $i=0;$i<=$#uniqname;$i++)
    { my $i1=$i+1;
      $cmd.=
      "<tr><td>$i1</td>
      <td><input type=submit name=$var value='$uniqname[$i]'>
      </td></tr>";
    }
    $cmd.="</table></fieldset>";
    $cmd.= &COMMENT("or");
    $cmd.="<input type=submit name=action value='Register New User'>" ;
    print $cmd;
    ###############################
    $q->param("LastFindByName",$FindByName);
  }
  else # no names found
  { print $q->h3("No names found for:");
    print $q->textfield(-name=>'FindByName',-value=>"$partialNameOK",-size=>20);
    #$q->param("LastFindByName",$q->param("FindByName"));
    print $q->submit('action','Search');
    print "<br>".&COMMENT("or"),
    $q->submit('action',"Register New User");
    $q->delete("NewPersonnel");
  } 
  $printFindByNameTable=1;
}

sub printNewNameForm
{ my ($q)=@_;
  $q->delete("lastname"); 
  $q->delete("firstname"); 
  my $partialNameOK="string: 'tom'";
  my $FindByName=$q->param("FindByName");
  #####################################
  print &COMMENT("Find database name from $partialNameOK.<br>");
  print $q->textfield(-name=>'FindByName',-size=>20) ;
  print $q->submit('action','Search');
  print &COMMENT("<br>or Enter New Info<br>");
  #####################################
  print 
  $q->textfield('firstname',"First Name",-size=>20),
  $q->textfield('lastname',"Last Name",-size=>20),"<br>";
}

sub goodName
{ my @name=@_;
  my $good=1;
  foreach my $name ( @name )
  { if ( ! $name or $name =~ /First Name/ or $name =~ /Last Name/ ) 
    { $good=0;
    }
  }
  return $good;
}

sub SelectDamageAddress
{ my @issueAddress=&DamageReportAddresses;
  if($#issueAddress<0) { return ""; };

  my $cmd="<select name=DamageAddress>";
  $cmd.="<option value=''>Damage Report Addresses</option>";
  foreach my $address  (@issueAddress)
  { my ($s,$a)=split(/\t/,$address);
    my $AddressStreet="$a $s";
    $cmd.="<option value='$address'>$AddressStreet</option>";
  }
  $cmd.="</select>";
  $cmd.="<input type=submit name='action' value='SelectDamageAddress' >";
  $cmd.="<br>".&COMMENT("or ");
  $cmd
}

sub ShowInfo
{ my $info=$_[0];
  $info=~s/\s+//g;
  my $file="../Info/$info.info"; 
  if( ! -e $file ) { print &COMMENT("No Info file<br>"); return; }
  open L,"$file";
  my @type,@line,@list;
  while(<L>)
  { next if(/^\s*$/); # NO blank lines
    chop;
    if( $_ =~ /^:(.*):$/ ) 
    { push @type,$1; 
      if( $type[$#type] eq "CONTENT" )
      { print "\n<p>";
      }
      if( $type[$#type] eq "ENDLIST" )
      { pop @type; pop @type;
	print "\n</ul>\n</ul>";
      }
      if( $type[$#type] eq "LIST" )
      { print "\n<ul>";
      }
      next;
    }
    push @line,$_;
    if( $type[$#type] eq "TITLE" )
    { print "\n<h4>",pop @line,"\n</h4>";
      pop @type;
    }
    if( $type[$#type] eq "CONTENT" )
    { print "\n",pop @line;
    }
    elsif( $type[$#type] eq "LIST" )
    { print "\n<li>",pop @line,"</li>";
    }
  }
  if( $type[$#type] eq "CONTENT" ) { print "\n</p>\n"; }
}

sub ShowInfoExit
{ my $info=$_[0];
  &ShowInfo($info);
  &hiddenParam($q,'UserName'); 
  print $q->submit('action','Back'); 
  print $q->end_html; 
  exit;
}

sub ViewMapsForm
{ my ($q)=@_;
  print &COMMENT("Select Map.<br>");
  my $cmd="<select name=UserAction>";
  $cmd.="<option value='Map:DetailedEmPrep'>Detailed EmPrep Neighborhood</option>"; 
  $cmd.="<option value='Map:ParcelMap:1643 Le Roy Ave'>Parcel Map EmPrep Neighborhood</option>"; 
  $cmd.="<option value='Map:YourLocation'>Find Me On Map</option>"; 
  $cmd.="<option value='Map:Address'>Map Address</option>"; 
  $cmd.="</select>";
  $cmd.="<input type=submit name='action' value='Go' >";
  $cmd.="<br>";
  print $cmd,hr;
  $q->param("LastAction","ViewMapsForm");
  $q->param("UserName","$UserName");
  &hiddenParam($q,'UserName,LastAction');
  print $q->submit('action','Cancel');
  print $q->endform;
}

sub ViewMap
{ my ($q)=@_;
  if( $UserAction eq "Map:DetailedEmPrep" )
  { print "<img  src='../../Maps/11x17map.sep2009.jpg' alt='DetailedMap'>";
  }

  if( $UserAction =~ "Map:ParcelMap:" )
  { my ($dum,$dum1,$address)=split(/:/,$UserAction,3);
    # print "$UserAction ";
    my @addresses=&DamageReportAddresses();

    my ($markerOffsetX,$markerOffsetY,$MapDimX,$MapDimY)
      = &MapAddressPxLocation($address,"../Lists/ParcelMapInfo.txt","parcelsByAddress");
    $markerOffsetX=~s/px//; $markerOffsetX-=20; $markerOffsetX="$markerOffsetX"."px";
    $markerOffsetY=~s/px//; $markerOffsetY-=20; $markerOffsetY="$markerOffsetY"."px";
    print "$markerOffsetX,$markerOffsetY\n";

# General set up 
    print <<___EOR;
<div class="map" id="parcelmap"> 
  <img class="mapclass" src='$MapFile' alt="Parcel Map"> </img>
  <canvas class="map_marker" id="markercanvas" width="20" height="20" style="border:1px solid #FF0000;">
</canvas>
</div>
___EOR

    print <<___EOR;
<script>
var map = document.getElementById("parcelmap");
map.position="relative";
var c = document.getElementById("markercanvas");
var ctx = c.getContext("2d");
ctx.strokeStyle="blue";

ctx.beginPath();
   ctx.arc(75,75,50,0,Math.PI*2,true);
ctx.arc($markerOffsetX, $markerOffsetY, 4, 0, 2*Math.PI );
ctx.stroke();
___EOR

    if(2==1)
    {
    for(my $i=0; $i<=$#addresses; $i++)
    { my ($street,$address)=split(/\t/,$addresses[$i]);
      $address="$address $street";
      # print "**$address**";
      # marker Info 
      my ($markerOffsetX,$markerOffsetY,$MapDimX,$MapDimY)
	= &MapAddressPxLocation($address,"../Lists/ParcelMapInfo.txt","parcelsByAddress");
      $markerOffsetX=~s/px//; $markerOffsetX-=20; $markerOffsetX="$markerOffsetX"."px";
      $markerOffsetY=~s/px//; $markerOffsetY-=20; $markerOffsetY="$markerOffsetY"."px";
      # print "$markerOffsetX,$markerOffsetY\n";
    print <<___EOR;
ctx.beginPath();
ctx.arc($markerOffsetY,$markerOffsetX,4,0,2*Math.PI);
ctx.stroke();
___EOR
    }
  }
    print <<___EOR;
</script>
___EOR
    #=========


    ################################
  }
  elsif( $UserAction eq "Map:YourLocation" )
  { print <<___EOR;
    <p id='demo'>Your map:</p>
    <div id='mapholder'></div>
    <script>
    var x=document.getElementById('demo');

    function getLocation()
    { if (navigator.geolocation)
      { navigator.geolocation.getCurrentPosition(showPosition);
      }
      else 
      { x.innerHTML='Geolocation is not supported by this browser.';
      }
    }

    function showPosition(position)
    { var latlon=position.coords.latitude+","+position.coords.longitude; 
      var img_url="http://maps.googleapis.com/maps/api/staticmap?center="
        +latlon+"&zoom=19&size=800x600&sensor=true";
      document.getElementById("mapholder").innerHTML="<img src='"+img_url+"'>";
    }

    function showPosition1(position)
    { x.innerHTML='Latitude: ' + position.coords.latitude + '<br>Longitude: ' + position.coords.longitude;	
    }
    getLocation();

    </script>
    <br>
___EOR
  }

  elsif( $UserAction eq "Map:Address" )
  { 
    print <<___EOR;
<meta name="viewport" content="initial-scale=1.0, user-scalable=yes">
<meta charset="utf-8">
<title>Google Maps JavaScript API v3 Example: Geocoding Simple</title>
<link href="https://developers.google.com/maps/documentation/javascript/examples/default.css" rel="stylesheet">

<script 
src="https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false&key=AIzaSyBPd1ngVR_I1h5O0VlIFGgKedAjhOlF0U4">
</script>    

<script>
//var geocoder;
var map;
//var mapOptions = { zoom: 17, mapTypeId: google.maps.MapTypeId.ROADMAP }
var marker;
 
function initialize() {
geocoder = new google.maps.Geocoder();
map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);

var latlng = new google.maps.LatLng( 38.8951, -77.0367 );       
var mapOptions = { zoom: 12, center: latlng  }; 
map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
codeAddress();
}
 
function codeAddress() {
  var geocoder = new google.maps.Geocoder(); 
  var address = document.getElementById('address').value;
      alert('call codeAddress '+ address); /////
  geocoder.geocode( { 'address': address}, 
    function(results, status) 
    { alert("Status " + results[0] + status);
      if (status == google.maps.GeocoderStatus.OK) 
      { map.setCenter(results[0].geometry.location);
	if(marker) { marker.setMap(null); }
	marker = new google.maps.Marker(
	  { map: map, position: results[0].geometry.location, draggable: true });

	google.maps.event.addListener(marker, "dragend", function() {
	  document.getElementById('lat').value = marker.getPosition().lat();
	  document.getElementById('lng').value = marker.getPosition().lng(); });

	document.getElementById('lat').value = marker.getPosition().lat();

	document.getElementById('lng').value = marker.getPosition().lng();
      }

    else if (status == google.maps.GeocoderStatus.OK) 
    { alert('OK result');
    }
    else if (status == google.maps.GeocoderStatus.REQUEST_DENIED) 
    { alert('request denied');
    }
    else if (status == google.maps.GeocoderStatus.INVALID_REQUEST) 
    { alert('invalid request');
    }
      else 
      { alert('Geocode was not successful for the following reason: ' + status);
      }

    });
}

function myFunction() { 
  document.write(Date()); 
  codeAddress();
  document.write(Date()); 
  }
google.maps.event.addDomListener(window, 'load', initialize);
</script>

<p id='demo'>Your map:</p>
<div id="map-canvas" style="width: 320px; height: 380px;"></div>
<div>
<input id="address" type="textbox" style="width:60%" value="1643 le roy ave, berkeley, ca">
<input type="text" id="lat" value="-122"/>
<input type="text" id="lng" value="37"/>
<input type='button' value='Geocode' onclick="codeAddress()">
<button onclick="myFunction()">Try it</button>
<button onclick="codeAddress()">GeoCode</button>
</div>
<br>
___EOR
  }

  $q->delete("MapSelection");
  $q->param("LastAction","ViewMap");
  $q->param("UserName","$UserName");
  &hiddenParam($q,'UserName,LastAction');
  print $q->submit('action','Home');
  print $q->endform;
}

sub MapAddressPxLocation
{ my ($address,$mapInfoFile,$AddressUtmDB)=@_;
  &ParmValueArray( &arrayTXTfile($mapInfoFile) );
  &TIE("$AddressUtmDB");
  $address=uc($address);
  if( my $data=$parcelsByAddress{$address} )
  { my @data=split(/\t/,$data);
    my $utmx=$data[11]; $utmy=$data[12];
    my $dxpix=
      int($MapLowerLeftPxXRef+
	($MapUpperRightPxXRef-$MapLowerLeftPxXRef)*($utmx-$MapLowerLeftUtmXRef) 
	/ ($MapUpperRightUtmXRef-$MapLowerLeftUtmXRef))."px";
    my $dypix=
      int($MapUpperRightPxYRef+
	($MapLowerLeftPxYRef-$MapUpperRightPxYRef)*($utmy-$MapUpperRightUtmYRef) 
	/ ($MapLowerLeftUtmYRef-$MapUpperRightUtmYRef))."px";
    return ($dxpix,$dypix,$MapXdim,$MapYdim);
  }
  else
  { print "No Location Data";
  }
}

