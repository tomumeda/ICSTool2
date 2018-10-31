#!/usr/bin/perl
use CGI qw/:standard :html3/;
do "subCommon.pl";
&initialization;
&HTMLHeader;
print Dump($q);
print $q->start_html(-title=>'ICSToo Reset', -style=>{ -src=>'ICSTool.css' });
print $q->password_field('ICSpassword','starting value',20,20);
print $q->end_html;
