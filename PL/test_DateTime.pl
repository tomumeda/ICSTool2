#!/usr/bin/perl
use DateTime;
use Time::Local;
use POSIX qw(strftime);

$dt = DateTime->now( );
$dt->set_time_zone( 'America/Los_Angeles' );

print join(" ",
$dt->time_zone_long_name(),
$yr=$dt->year(),
$mth=$dt->month(),
$day=$dt->day(),
$hr=$dt->hour(),
$min=$dt->minute(),
$sec=$dt->second()
) ;

{ 
  $day+=1;
  $time=timelocal($sec,$min,$hr,$day-1,$mth-1,$yr);
  $time=$dt->epoch();
  $timestr= strftime "%a %b %e %H:%M %Y", localtime($time);
  print "\n DD:$day $time \n$timestr XXX\n" ;

  $time=timelocal($sec,$min,$hr+2,$day+2,$mth-1,$yr);
  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);
  print "($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) <<\n";
  $timestr= strftime "%a %b %e %H:%M %Y", localtime($time);
  print " DD:$day $time \n$timestr YYY\n" ;

}

