#!/usr/bin/perl 
$host= `hostname` ;
# Is postfix running ?
if( $host =~ /pro1/ ) #
{ $test= `ps -alxw | grep postfix | grep master` ;
  #  if($test !~ /libexec/){ die "NEED TO RUN 'postfix start'" ; }
}
######################
require "subMemberDB.pl";
#######################
##############################
&initialization;
$dottedline="-"x33;

&TIE( @DBrecLabels );
open(LLOG,">>Welcome.log");
open(LEMAIL,">Welcome.email.d");
open(LNAMES,">Welcome.names.d");
########################################33
$list=<<___EOR;	# TAB separated
Dunsky	Sara	sara.dunsky\@gmail.com
___EOR
@list=split(/\n/,$list);
#####################33
foreach $key (@list)
{ ($LastName,$FirstName,$EmailAddress)=split(/\t/,$key);
  #  next if( $FirstName!~m/Takato/ ); ## UNCOMMENT FOR only me TEST
  print " Processing: $LastName $FirstName\n"; 
  ########################
  $problem="northside.emprep\@gmail.com";
  $replyto="northside.emprep\@gmail.com";
  $replyto="northside.emprep\@gmail.com,emprep-owner\@northside-emprep.org";
  $from="northside.emprep\@gmail.com";

  @to=split(/,/,$EmailAddress);
  $to=$to[0];
  next if ( !$to );
  print "\t\tMailing to: $to\n";
  
  # next;  # COMMENT to actually send 
  #  $to="takato\@pacbell.net"; ## UNCOMMENT for all email to one recipient TEST

  print LEMAIL "$to = $LastName, $FirstName\n";
  print LNAMES "$LastName, $FirstName = $to\n";
  print LLOG "$UXtime($timestr): $LastName, $FirstName = $to\n";

  open(LMAIL,">STDOUT");
  open(LMAIL,"|/usr/sbin/sendmail -t -f $problem > sendmail.log"); # COMMENT for emailing TEST

  print LMAIL<<___EOR;
Content-type: text/plain
Reply-to: $replyto
From: $from
To: $to
Subject: [EmPrep] Welcome to the Northside EmPrep Neighborhood Group

Hello $FirstName $LastName, 

Welcome to the Northside EmPrep Neighborhood Group.  
I hope you will find this group valuable for your household safety,
as well as a means of meeting your neighbors.

To get started you must register as a member of the group where you need to supply basic information about yourself: name, address, and email address.
Other information relevant to Northside EmPrep emergency operations may be supplied.

We are developing a new Member Information Form 
which updates the Member Database directly.
Please try it out at:
http://icstool.tupl.us:8081?mode=MemberInformation
and click on 'NewName'.
You may need:  UserName / Password = emprep / user101
to access this website.  Any feedback would be appreciated.

Alternatively you can use the older Google version of this form at:
https://docs.google.com/forms/d/e/1FAIpQLSeB2Rb0b8B_itvKfdwsY-TydxA8qo9_J4wjK7K6Y_BqoS5IIg/viewform

Or if you would like, you can reply to this email with your infomation.
Any one of the three methods will get you registered with our group.
----
I am looking forward to meeting you. 
Thank you,
Tom Umeda
$from
___EOR
  close(LMAIL);

}

