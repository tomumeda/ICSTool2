#!/usr/bin/perl

unlink "*.dvi";
unlink "x.ps";
@forms=('SignIn');
@forms=('Messages');
@forms=('ResponseTeam');
@forms=('DamageAssessmentForm');
foreach $form (@forms)
{ system "latex $form.tex";
  system "dvips -o $form.ps  $form.dvi";
}
