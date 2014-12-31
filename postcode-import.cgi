#!/usr/bin/perl
use strict;

use DBI;
use Text::CSV_XS;
use Data::Dumper;
use REAXML::Database;

my $dbhwrite = &WriteConnect();

my %statelist=();
$statelist{"ACT"}=1;
$statelist{"NSW"}=2;
$statelist{"NT"}=3;
$statelist{"SA"}=4;
$statelist{"QLD"}=5;
$statelist{"TAS"}=6;
$statelist{"VIC"}=7;
$statelist{"WA"}=8;

#----------------------------------------------------------------------

my $file = "pc-full_20100127.csv";
my $csv = new Text::CSV_XS;

open(*FILE,"<$file");

my $header = $csv->getline(*FILE);

while (my $row = $csv->getline(*FILE)) {

    my @fields = @$row;
    my $postcode = @fields[0];
    my $suburb = @fields[1];
    my $state = @fields[2];
    my $pobox = @fields[9];

    $state = $statelist{$state};

    if ($pobox =~ /^Post Office Boxes/) {
        $pobox = 1;
    } else {
        $pobox = "NULL";
    }

    $suburb = $dbhwrite->quote($suburb);
    $postcode = $dbhwrite->quote($postcode);
 
    my $sql = "insert into SUBURB (suburb,postcode,pobox,stateid) values ($suburb,$postcode,$pobox,$state)";
    print "$sql\n";
    my $sth = $dbhwrite->prepare($sql);
    $sth->execute();
    $sth->finish();

}
$csv->eof();
close(*FILE);

$dbhwrite->commit();
$dbhwrite->disconnect();

exit;
