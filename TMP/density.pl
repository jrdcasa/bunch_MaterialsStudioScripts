#!perl

use strict;
use Getopt::Long;
use MaterialsScript qw(:all);
use Cwd;


my $temp_initial = 400;
my $delta_temp = -10;
my $steps = 32;
my $pat1 = "_NPT_Step_";

for (my $istep=0; $istep<$steps; ++$istep) {

	my $temp = sprintf("%04d",$temp_initial+$delta_temp*$istep);
	my $index = sprintf("%03d", $istep);
	my $xtdname = sprintf($index.$pat1.$temp."K.xtd");
	
	printf("Step %d, %d: %s\n", $index, $temp, $xtdname);
	
	my $xtddoc = $Documents{$xtdname};
	
	Modules->Forcite->Analysis->Density($xtddoc, Settings(
				ComputeRunningAverages=>"No"));
				
	my $seedname = sprintf($index.$pat1.$temp."K ");
	my $xcddoc = $Documents{$seedname."Forcite Density.xcd"};
	my $stddoc = $Documents{$seedname."Forcite Density.std"};
	
	$xcddoc->close();
	$stddoc->close();
	$xtddoc->close();


}









