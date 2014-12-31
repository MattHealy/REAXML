#--------------------------------------------------------------
# REAXML::Database Module
# Contains methods for connecting the REAXML database
#--------------------------------------------------------------

package REAXML::Database;
require Exporter;

use strict;

our @ISA     = qw(Exporter);
our @EXPORT  = qw(ReadConnect WriteConnect MySQLterminate);   # symbols to be exported by default (space-separated)
our $VERSION = 1.00;                  # version number

my $dbhread;
my $readserver="localhost";
my $readts="reaxml";
my $readuser="root";
my $readpass="";
my $readport="3306";

my $dbhwrite;
my $writeserver="localhost";
my $writets="reaxml";
my $writeuser="root";
my $writepass="";
my $writeport="3306";

#----------------
# ReadConnect
# Connect to the READ server (select queries only)
#----------------

sub ReadConnect() {
   eval {
   $dbhread=DBI->connect("dbi:mysql:$readts;host=$readserver:$readport",
                        "$readuser","$readpass",{AutoCommit=>0, RaiseError=>1});
   $dbhread->{LongReadLen} = 5005;
   $dbhread->{LongTruncOk} = 1;
   };
   if ($@) { 
       print "$@\n";
   }

   return($dbhread);
}

#----------------
# WriteConnect
# Connect to the WRITE server (update/delete queries only)
#----------------

sub WriteConnect() {
   eval {
   $dbhwrite=DBI->connect("dbi:mysql:$writets;host=$writeserver:$writeport",
                        "$writeuser","$writepass",{AutoCommit=>0, RaiseError=>1});
   $dbhwrite->{LongReadLen} = 5005;
   $dbhwrite->{LongTruncOk} = 1;
   };
   if ($@) { 
       print "$@\n";
   }

   return($dbhwrite);
}

#----------------
# MySQLterminate
# Called when an SQL error occurs
#----------------

sub MySQLterminate() {

  my($error,$message)=@_;

  print "Error: $error\nMessage: $message\n";
  $dbhread->disconnect();
  $dbhwrite->disconnect();
  exit;

}

1;
