#!perl

# This script is used to get all final strucutres after a scan calculation
# usung the script ScanScript.pl 

use strict;
use Getopt::Long;
#To access the functionality of the MaterialsScript package
use MaterialsScript qw(:all);
use File::Copy;

my $nsteps=21;

my $trj = Documents->New("scan_trj.xtd");
my $totrj = $trj->Trajectory;

for (my $i=0 ; $i < $nsteps; ++$i) {

    my $i_padding = sprintf("%03d", $i);
    my $doc = $Documents{"myFilename".$i_padding.".xsd"};
    
    $totrj->CurrentFrame = $i;
    $totrj->AppendFramesFrom($doc, Frames(Start => $i, End => $i));    
    
}









