#!/usr/bin/perl

#delete all data files
@pat=split(/,/,"ResponseTeamLogs/*,ResponseTeams/*,Damages/*,DamageLogs/*,Personnel/*,PersonnelLog/*");
foreach $pat (@pat)
{ @f = split(/\n/,`ls $pat`); 
  foreach $f (@f)
  { unlink $f;
  }
}
system "echo 0 > ResponseTeams/lastNumber";
chmod 0666,"ResponseTeams/lastNumber"; 


