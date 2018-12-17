Neighborhood Member Database System
======
This file describes the Member Database System which is used by ICSTool.  The system includes methods for collecting updates for the neighborhood group members, processing the collected data into a Member Database .db file for the ICSTool.
## Data and Datafiles
1. MemberInfo.csv -- member information in .csv format currently imported from Google Forms [.csv Header](PL/DB.EmPrep/MasterDB.csv.Header)  [.csv Descriptor](PL/DB.EmPrep/MasterDB.csv.Descriptor) 

2. ./PL/DB/MemberInfo.db -- .db version of the MemberInfo.csv  

## Data Processing Tools
1. [Google form for entering member information](https://docs.google.com/forms/d/1nZ4xfWe81QIT9kDw5DLGg3BiZ4mKg07HBhBBUbU2FEg/edit) where the data is stored on a Google spreadsheet.  This spreadsheet can be exported as a .csv file for processing on the ICSTool computer. 
1. ./PL/csvFix.j checks the downloaded ./PL/DB/MemberInfo.csv file for problems.
2. ./PL/MasterDB.csv2db.pl converts the ./PL/DB.EmPrep/MemberInfo.csv file to a ./PL/DB.EmPrep/MemberInfo.db file

## Tools for Managing Member Database
1. ./PL/csvFix.j checks the ./PL/DB/MemberInfo.csv file for problems.
2. ./PL/MasterDB.db2csv.pl converts ./PL/DB.EmPrep/MemberInfo.db to a ./PL/DB.EmPrep/MemberInfo.csv file for export to spreadsheet program.
3. ./PL/getDBinfo.j lists contents of ./PL/DB.Emprep/MemberInfo.db
4. ./PL/UpdateRequest.j emails requests to members listed in ./PL/DB.EmPrep/MemberInfo.db to update their information.
    * This program relies on the UNIX command postfix for sending email.
    * Google forms pre-fill responses template is encoded in ./PL/googleForm.pl subroutines
   
## Tips for Managing Google Forms and Spreadsheets
1. You can construct a Google form to use with your CERT neighborhood group like the one [here][https://docs.google.com/forms/d/1V5tZcsDt3XsNtEq2Fl_dOVrJW6RYaEJj9LJvm_OfbOc/edit] 
by copying it to your Google Drive and editting it to suit your purposes.
2. Once you have a form you like send it to yourself by using the 'Get pre-filled link' option.
3. Pre-fill all the fields in the form with something you will recognize.
4. 'GET LINK' will copy the pre-filled form into your clipboard which you should save to a text file.  
You will get something like the following in your clipboard 

>
XHTTPS://docs.google.com/forms/d/e/------LSdAlovo9DMmXe8o_0ly7JeMsCegIdQ1rWRp09RfSN6YgSKbWQ/viewform?usp=pp_url&entry.1752260636=lastname&entry.359761687=firstname&entry.1973771313=Buena+Vista+Way&entry.1645123309=9999&entry.1786188533=subaddress&entry.792241242=A1&entry.1511866050=555-555-5555&entry.569410759=555-555-5555&entry.2695614=your@email.com&entry.758588162=othercontactinfo&entry.1177561975=Fire+Suppression&entry.1177561975=First+Aid&entry.1177561975=Search+and+Rescue&entry.1177561975=Communications&entry.1177561975=__other_option__&entry.1177561975.other_option_response=other&entry.1053611898=certclasses&entry.383791721=9999&entry.1003188876=emergencycontactinfo&entry.1113678854=specialneeds&entry.1119698127=visitor&entry.788091415=pets&entry.1693846876=emergerncyequipment&entry.656293127=No&entry.205920954=gasshutoffvalveinfo&entry.1772334084=comments&entry.1435760554=No

XHTTPS is replacing https to inactivate the link.
Note the values you entered in the text above. 
You can use an editted version of this text to insert into ./PL/googleForm.pl where it can be modified with information from the 
Member Database to construct pre-filled forms 
for individual neighborhood members.
The following is a PERL program statement showing an example of 
how the above text is modified for the ./PL/googleForm.pl PERL script.

> $form=<<___EOR;
XHTTPS://docs.google.com/forms/d/e/----QLScpas-7EhJVfWUVG5HgScWJEkgtB6Cxjyk0cMOiPjZtfOLbiQ/viewform?usp=pp_url
&entry.1752260636=$LastName
&entry.359761687=$FirstName
&entry.1973771313=$StreetName
&entry.1645123309=$StreetAddress
&entry.1786188533=$subAddress
&entry.792241242=$DivisionBlock
&entry.1511866050=$HomePhone
&entry.569410759=$CellPhone
&entry.2695614=$EmailAddress
&entry.758588162=$OtherContactInfo
&entry.1177561975=$skill[0]
&entry.1177561975=$skill[1]
&entry.1177561975=$skill[2]
&entry.1177561975=$skill[3]
&entry.1177561975=__other_option__
&entry.1177561975.other_option_response=$skill[4]
&entry.1053611898=$CertClasses
&entry.383791721=$BirthYear
&entry.1003188876=$EmergencyContatInfo
&entry.1113678854=$SpecialNeeds
&entry.1119698127=$Visitors
&entry.788091415=$Pets
&entry.1693846876=$EmergencyEquipment
&entry.205920954=$GasShutOffValveInfo
&entry.1772334084=$Comments
&entry.1435760554=$InactiveMember
___EOR

The PERL variables start with a $-sign 
and are replaced by their assigned values.

5. By submitting information on the form and opening the form 
on your Google Drive you can create a spreadsheet of the reponses by 
selecting RESPONSES and Create Spreadsheet options.

6. From the spreadsheet you can download a .csv version of the response
 to your computer for updating the (ICSTool) Member database.

7. Subsequent responses to the Google Form will be appended 
to the Google spreadsheet. 
The spreadsheet may be editted for correctness of information and format,
and elimination of outdated information
before downloading to the ICSTool for processing. 

