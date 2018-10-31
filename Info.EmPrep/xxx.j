#!/usr/bin/perl
#do "subCommon.pl";
#do "subICSWEBTool.pl";

#use CGI::Carp qw/fatalsToBrowser/;
#use CGI qw/:standard/;

sub ShowInfo
{ my $info=$_[0];
  $info=~s/\s+//g;
  my $file="../Info/$info.info"; 
  open L,"$file";
  my @type,@line,@list;
  while(<L>)
  { next if(/^\s*$/); # NO blank lines
    chop;
    if( $_ =~ /^:(.*):$/ ) 
    { push @type,$1; 
      if( $type[$#type] eq "CONTENT" )
      { print "\n<p>";
      }
      if( $type[$#type] eq "ENDLIST" )
      { pop @type; pop @type;
	print "\n</ul>";
      }
      if( $type[$#type] eq "LIST" )
      { print "\n<ul>";
      }
      next;
    }
    push @line,$_;
    if( $type[$#type] eq "TITLE" )
    { print "\n<h2>",pop @line,"\n</h2>";
      pop @type;
    }
    if( $type[$#type] eq "CONTENT" )
    { print "\n",pop @line;
    }
    elsif( $type[$#type] eq "LIST" )
    { print "\n<li>",pop @line,"</li>";
    }
  }
  if( $type[$#type] eq "CONTENT" ) { print "\n</p>\n"; }

  }
