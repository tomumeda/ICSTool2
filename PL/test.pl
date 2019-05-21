#!/usr/bin/perl

use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser); # Remove this in production

my $q = new CGI;

print $q->header();

    # Output stylesheet, heading etc
output_top($q);

    if ($q->param()) {
        # Parameters are defined, therefore the form has been submitted
        display_results($q);
    } else {
        # We're here for the first time, display the form
        output_form($q);
    }

    # Output footer and end html
    output_end($q);

    exit 0;

    #-------------------------------------------------------------

    # Outputs the start html tag, stylesheet and heading
    sub output_top {
        my ($q) = @_;
        print $q->start_html(
            -title => 'A Questionaire',
            -bgcolor => 'white',
            -style => {
	        -code => '
                    /* Stylesheet code */
                    body {
                        font-family: verdana, sans-serif;
                    }
                    h2 {
                        color: darkblue;
                        border-bottom: 1pt solid;
                        width: 100%;
                    }
                    div {
                        text-align: right;
                        color: steelblue;
                        border-top: darkblue 1pt solid;
                        margin-top: 4pt;
                    }
                    th {
                        text-align: right;
                        padding: 2pt;
                        vertical-align: top;
                    }
                    td {
                        padding: 2pt;
                        vertical-align: top;
                    }
                    /* End Stylesheet code */
                ',
	    },
        );
        print $q->h2("A Questionaire");
    }

    # Outputs a footer line and end html tags
    sub output_end {
        my ($q) = @_;
        print $q->div("My Web Form");
        print $q->end_html;
    }

    # Displays the results of the form
    sub display_results {
        my ($q) = @_;

        my $username = $q->param('user_name');
        my $userage = $q->param('age');
        my $usergender = $q->param('gender');
        my @favourite_languages = sort $q->param('language');
        my %sex = ('F' => 'girl', 'M' => 'boy');

        print $q->h4("Hi $username");
        print $q->p("You are a $sex{$usergender}, and you are $userage years old.");
        print $q->p("Your favourite languages are:");

        print $q->table(
            {-border => 1, -cellpadding => 3},
            $q->Tr($q->td(\@favourite_languages)),
        );
    }

    # Outputs a web form
    sub output_form {
        my ($q) = @_;
        print $q->start_form(
            -name => 'main',
            -method => 'POST',
        );

        print $q->start_table;
        print $q->Tr(
          $q->td('Name:'),
          $q->td(
            $q->textfield(-name => "user_name", -size => 50)
          )
        );
        print $q->Tr(
          $q->td('Age:'),
          $q->td(
            $q->radio_group(
              -name => 'age',
              -values => [
                  '0-12', '13-18', '18-30', '30-40', '40-50', '50-60', '60-70', '70+'
              ],
              -rows => 4,
            )
          )
        );
        my %genders = ('F' => 'Female', 'M' => 'Male');
        print $q->Tr(
          $q->td('Gender:More text and more text'),
          $q->td(
            $q->popup_menu(
              -name => 'gender',
              -values => [keys %genders],
              -labels => \%genders,
            )
          )
        );
        print $q->Tr(
          $q->td('Favourite Languages:'),
          $q->td(
            $q->checkbox_group(
              -name => 'language',
              -values => ['Perl', 'C', 'C++', 'C#', 'Java', 'VB', 'Python', 'Delphi'],
              -defaults => ['Perl'],
              -columns => 2,
            )
          )
        );
        print $q->Tr(
          $q->td($q->submit(-value => 'Submit')),
          $q->td('&nbsp;')
        );
        print $q->end_table;
        print $q->end_form;
    }

