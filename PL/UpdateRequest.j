#!/usr/bin/perl 
$host= `hostname` ;
# Is postfix running ?
if( $host =~ /pro1/ ) #
{ $test= `ps -alxw | grep postfix | grep master` ;
  if($test !~ /libexec/){ die "NEED TO RUN 'postfix start'" ; }
}
# hostname must be Pro1 for sendmail to work
#die "$host <hostname needs to be Pro1 " if ( $host ne "pro1\n" and $host ne "Pro1\n" );
# $sendGreylist=1;  #1-> sends to greylist only <<UNCOMMENT tp semd tp greylist only
# CHECK tail /var/log/mail.log
# 
# Mail location: Pro1:/Users/Tom/Library/Mail/V2/IMAP-northside.emprep@imap.gmail.com/[Gmail].mbox/Spam.mbox/F0755B93-6E2D-44DB-9FE0-23FF8693A02E/Data/1/4/Messages
#
######################
require "subMemberDB.pl";
require "googleForm.pl";
#######################
##############################
&initialization;
&Set_timestr; 
$dottedline="-"x33;

&TIE( @DBrecLabels );
open(LLOG,">>UpdateRequest.log");
open(LEMAIL,">xemail.d");
open(LNAMES,">xnames.d");
open(LADDRESS,">xaddress.d");
$greys=`cat greylist.d`;
@greys=split(/\n/,$greys);
foreach my $item (@greys)
{ if($item !~ /^#/) { push @greylist,$item; }
}

foreach $key (sort keys %DBmaster)
{ # print "<<$key>>\n"; 
  &SetDBrecVars($key);
  print "DB memberName: $LastName $FirstName\n";

  if($InactiveMember =~/yes/i )
  { print " Inactive:$LastName $FirstName\n"; 
    next;
  }
  #########
  #next if( $LastName!~m/Trippe/ );
  #next if( $LastName!~m/Thompson/ && $LastName!~m/Trippe/ && $FirstName!~m/Takato/ );
   next if( $FirstName!~m/Takato/ ); ## UNCOMMENT FOR only me TEST

  print " Processing: $LastName $FirstName\n"; 
  #########
  $problem="northside.emprep\@gmail.com";

  $replyto="northside.emprep\@gmail.com";
  $replyto="northside.emprep\@gmail.com,emprep-owner\@northside-emprep.org";

  $from="northside.emprep\@gmail.com";

  @to=split(/,/,$EmailAddress);
  $to=$to[0];
  next if ( !$to );

  if($sendGreylist==1)
  { next if(&MemberQ(@greylist,$to) == -1);
  }

  print "\t\tMailing to: $to\n";
  
  # next;  # COMMENT to actually send 
   $to="takato\@pacbell.net"; ## UNCOMMENT for all email to one recipient TEST

  print LEMAIL "$to = $LastName, $FirstName\n";
  print LNAMES "$LastName, $FirstName = $to\n";
  print LADDRESS "$StreetName $StreetAddress, $LastName, $FirstName = $to\n";
  print LLOG "$UXtime($timestr): $LastName, $FirstName = $to\n";

  my $htmlform=&googleForm;
  $htmlform=uri_escape($htmlform);
  $htmlform=~s/%(26|2B|2C|2F|3A|3D|3F|40)/chr(hex($1))/eg;
  $htmlform=~s/%20/+/g; # space to +

  #die $htmlform; # UNCOMMENT to TEST $htmlform

  $textform=&dataListHTML;
  if( $LastName eq "Umeda" )
  { 
    # die "textfrom>> $textform\n";
  }

  open(LMAIL,">STDOUT");
  open(LMAIL,"|/usr/sbin/sendmail -t -f $problem > sendmail.log"); # COMMENT for emailing TEST

$specialrequest=
"=============NOTICE============
================================
";

  print LMAIL<<___EOR;
Content-type: text/plain
Reply-to: $replyto
From: $from
To: $to
Subject: [EmPrep] Member Information Update 

Hello $FirstName $LastName, 

We periodically review member information in our database for accuracy.  Please review your current information below.  
$dottedline
$textform
NOTE: The information should reflect the individual named.  Information applying to the address, e.g. EmergencyEquipment, should be listed once per address.  An example of the preferred format and possible content are shown at the bottom of this email.
$dottedline

If you need update your information, please use the form at:
($htmlform).

You also can reply to this email with your updates to ($replyto) along with any questions or comments you may have.

Thank you,
Tom Umeda
takato\@pacbell.net
$dottedline

Example of information content and format:

LastName: Smith
FirstName: John
StreetName: Le Roy Ave
StreetAddress: 1643
subAddress: Apt B
HomePhone: 510-548-1111
CellPhone: 510-761-1111
EmailAddress: john@yahoo.net
SpecialNeeds:  Child(Bob:1 yrs)
SkillsForEmergency: Search and Rescue, Fire Suppression
Visitors: HouseKeeper(Bertha on Tuesdays)
Pets: Cat(Lion=Max)
EmergencyEquipment: Ladder(12 ft), Shelter(4 person), Tools(pry bar, hammer, saws)

___EOR
  close(LMAIL);

  if( $LastName eq "Umeda" )
  { #print ">>>> $textform\n";
    #die;
  }
}

&UNTIE( @DBrecLabels );
