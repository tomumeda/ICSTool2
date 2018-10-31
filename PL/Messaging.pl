#!/usr/bin/perl
do "subCommon.pl";
do 'subPersonnel.pl';
do 'subMessages.pl';
&initialization;
&initializeMessage;
#
if ($action  eq 'ICS Tools')
{ &JumpToLabel("sec:ICCDevelopment");
}
elsif ($action  eq 'Home')
{ &JumpToLabel("sec:Home");
}
elsif ($action  eq 'SEND')
{ &save_message($q);
  $q->delete('Messages');
}
# original defaults
elsif ($action  eq 'View Messages') {} 
elsif ($action  eq 'Display') {}
elsif ($action  eq 'Refresh') { }
elsif ($action  eq 'Send Message')
{ #$q=&restore_message_parameters($q); 
}
else #set action from ParmString
{ &EvalParmString;
# set address 
  my $location=$q->param("Re:Location");
  if( $location ) { $Address=$location; }
  $q->param(-name=>'Address',-value=>"$Address") ;
}

&HTMLHeader;
#####################
# DEBUG
#my @parm=$q->param;
#print "DEBUG:$action : $Address : @parm :: @Recipients ::"; 
#print " Recipients=",join(",",$q->param('Recipients')),"=R $#Recipients==";
#$tmp= $q->param('Re:Location');
#print "Location: $tmp";
# DEBUG
#####################
print $q->h1("Messages <small>($timestr)</small>");
#if (@Recipients and ($action  eq 'Display' or $action eq "Refresh") )
if ($action  eq 'Display' or $action eq "Refresh") 
{ &DisplayMessage($q);
}
elsif($action eq "Send Message" )
{ &SendMessageForm;
}
else { &SelectMessageForm; }
print $q->end_html;

