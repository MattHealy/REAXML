#!/usr/bin/perl

use DBI;
use REAXML::Database;

#----------------------------------------------------------------------

$dbhread = &ReadConnect();

#----------------------------------------------------------------------


$sql = "describe PROPERTY";
$sth=$dbhread->prepare($sql);
$sth->execute();
while (@row = $sth->fetchrow_array) {
 #print "$row[0] ";
 print "\$p\{$row[0]\},";
}
$sth->finish();

$dbhread->disconnect();

exit;
