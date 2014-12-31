#!/usr/bin/perl
use strict;

use XML::DOM;
use DBI;
use File::Copy;

# My modules below
use REAXML::Importer;
use REAXML::Database;
# My modules above

#----------------------------------------------------------------------

  my $spooldir = "/home/matthewh/REA Project/spool";
  my $logdir = "/home/matthewh/REA Project/logfiles";

  # Connect to the database

  my $dbhread = &ReadConnect();
  my $dbhwrite = &WriteConnect();
  #$dbhwrite->trace($dbhwrite->parse_trace_flags('SQL|4|test'));
  
#----------------------------------------------------------------------
 
  # Sort files by timestamp descending
  opendir(DIR,"$spooldir");
  my @files = readdir(DIR);
  closedir(DIR);

  my %timestamps = ();
  foreach my $tempfile (@files) {
       next if ($tempfile eq "." || $tempfile eq "..");
       $timestamps{$tempfile} = (stat("$spooldir/$tempfile"))[9];
  }

  @files = ();
  foreach my $tempfile (sort timeDescending (keys(%timestamps))) {
     next if ($tempfile eq "." || $tempfile eq "..");
     push (@files,$tempfile);
  }

#----------------------------------------------------------------------

  my $parser = new XML::DOM::Parser;

  # Set up hash arrays for quick lookup
  my %authorityhash = &SetupHashArray($dbhread,"authority");
  my %commercialauthorityhash = &SetupHashArray($dbhread,"commercialauthority");
  my %commercialcategoryhash = &SetupHashArray($dbhread,"commercialcategory");
  my %holidaycategoryhash = &SetupHashArray($dbhread,"holidaycategory");
  my %landareatypehash = &SetupHashArray($dbhread,"landareatype");
  my %propertystatushash = &SetupHashArray($dbhread,"propertystatus");
  my %residentialcategoryhash = &SetupHashArray($dbhread,"residentialcategory");
  my %ruralcategoryhash = &SetupHashArray($dbhread,"ruralcategory");
  my %statehash = &SetupHashArray($dbhread,"state");

#----------------------------------------------------------------------

  print "No files to process\n" if @files==0;

  foreach my $file (@files) {

     my $document = $parser->parsefile("$spooldir/$file");

     print "--------------------------------------------\n"; 
     print "Processing file $file\n";
     print "--------------------------------------------\n"; 

     # Get the single <propertyList> element
     my $propertyList = $document->getElementsByTagName('propertyList')->item(0);

     # Reset property hash
     my %p = ();

     # Process all residential properties in file
     &ProcessResidential($dbhread,$dbhwrite,$propertyList,\%p,\%authorityhash,\%commercialauthorityhash,\%commercialcategoryhash,\%holidaycategoryhash,\%landareatypehash,\%propertystatushash,\%residentialcategoryhash,\%ruralcategoryhash,\%statehash);

#     &move("$spooldir/$file","$logdir/$file");

  }

#-----------------------------------------------------------------

$dbhwrite->commit();

$dbhread->disconnect();
$dbhwrite->disconnect();

exit;

sub timeDescending () {
  $timestamps{$b} <=> $timestamps{$a};
}
