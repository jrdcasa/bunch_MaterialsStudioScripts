#!perl

# This script is used to get all final strucutres after a scan calculation
# usung the script ScanScript.pl 

use strict;
use Getopt::Long;
#To access the functionality of the MaterialsScript package
use MaterialsScript qw(:all);
use File::Copy;

my $nsteps=21;

my $dir_origin = "C:/Users/Jramos/Documents/Materials Studio Projects/GerardoIrene_Files/Documents/01-Front/Try02-Scan/ScanScript_Script/";
my $dir_dest = "C:/Users/Jramos/Documents/Materials Studio Projects/GerardoIrene_Files/Documents/01-Front/Try02-Scan/";

for (my $i=0 ; $i < $nsteps; ++$i) {

    
    my $i_padding = sprintf("%03d", $i);
    my $source = $dir_origin."scan".$i_padding."/myFilename".$i_padding.".xsd";
    my $dest = $dir_dest."/myFilename".$i_padding.".xsd";
    print($dest);
    copy($source, $dest);
    
}

#for (my $i=0 ; $i < $nsteps; ++$i) {
#
#    my $i_padding = sprintf("%03d", $i);
#    my $methaneDoc = $Documents{"myFilename".$i_padding.".xsd"};
#
#}









