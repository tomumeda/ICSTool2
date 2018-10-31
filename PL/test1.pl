#!/usr/bin/perl
do "subCommon.pl";
use CGI qw/:push -nph/;
$| = 1;
#&initialization;
$q = new CGI;
print $q->multipart_init(-boundary=>'----here we go!');
for (0 .. 4) {
  print $q->multipart_start(-type=>'text/plain'), "The current time is ",scalar(localtime),"\n";
  if ($_ < 4) 
  { print $q->multipart_end; 
  } 
  else 
  { print $q->multipart_final;
  }
  sleep 1;
}
#print   $q->end_html; ### end
