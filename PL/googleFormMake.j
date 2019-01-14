#!/usr/bin/perl
#
#o
$in=`cat googleForm.data0`;
@form=split(/\&/,$in);
$form=join("\n\&",@form);
open L,">googleForm.data1";
print L $form;

print "!!! Edit googleForm.data1 to googleForm.data2 to reflect ICSTool variable names !!!\n\n";


