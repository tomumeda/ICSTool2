#!/usr/bin/perl

#temporary routine 
sub InitActionList 
{ local($action,@tmp,@actions,)
  $actions=
  "
  MemberSignIn ; Sign-In (Member)
  NonMemberSignIn ; Sign In (Non-Member)
  PersonnelInfo ; Individual Information (Display/Edit)
  PersonnelList ; List All Personnel
  Skills ; List All Personnel by Skills
  Assignments ; All Personnel Team Assignments
  ";
  $actions=~s/\s*;\s*/;/g;
  @actions=split "\n",$actions;
  for($i=0;$i<$#actions;$i++)
  { $action=$actions[$i];
    $action=~s/\s*$//g;
    $action=~s/^\s*//g;
    if(length($action)>0)
    { @tmp=split ";",$action;
      ($actioncomment{$tmp[0]})=$tmp[1];
      push @action,$tmp[0];
      #print ">>$action[-1] ($actioncomment{$tmp[0]}) \n";
    }
  }
}
&SubmitActionListWithComments(@action)
