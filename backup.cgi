#!/usr/bin/perl

print "Tarring files\n";
$tar = `/bin/tar -cvf REA.tar *`;

print "Moving archive to /tmp\n";
$move = `/bin/cp REA.tar /tmp/REA.tar`;
$move = `/bin/cp REA.tar /home/matthewh/Backups/REA.tar`;

print "Backup Complete\n";

exit;
