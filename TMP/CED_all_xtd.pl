#!perl

use strict;
use Getopt::Long;
use MaterialsScript qw(:all);
use lib ".";


sub calcCED {

    my $doc = shift;     # Molecular document
    my $temp = shift;    # Temperature

    my $results = Modules->Forcite->CohesiveEnergyDensity->Run($doc, Settings(
	'3DPeriodicElectrostaticSummationMethod' => 'Ewald', 
	'3DPeriodicElectrostaticEwaldSumAccuracy' => 0.01, 
	'3DPeriodicvdWAtomCubicSplineCutOff' => 9.5, 
	Use3DPeriodicvdWAtomLongRangeCorrection => 'No', 
	CurrentForcefield => 'COMPASS'));

}

# ================================================================================
# Copy all trajectories in the same folder that this script

my $sp_number = 2;
my $vol_number = 3;
my $start_cell = 40;
my $end_cell = 81; 
my $steps = 20;
my $temp_initial = 500;
my $delta_temp = -20;


for (my $istep=0; $istep<$steps; ++$istep) {

    my $temp_curr = sprintf("%04d",$temp_initial + $delta_temp * $istep);
    my $istep_c_padding = sprintf("%03d", $istep);
    my $strcurr = $istep_c_padding."_NPT_Step_".$temp_curr."K.xtd";
    my $newDoc = $Documents{$strcurr};
    
    calcCED ($newDoc);
    
    # Statistics on table
    my $std_table = $istep_c_padding."_NPT_Step_".$temp_curr."K.std";
    my $sheet = $Documents{$std_table}->Sheets(0);
   
    my $value = 0;
    my $Nsamples = 0;
    my $vol = 0;
    #printf "1. %f %f\n", $value, $Nsamples;
    
    for (my $icell = $start_cell; $icell < $end_cell; ++$icell){

    #for (my $icell = 0; $icell < 41; ++$icell){
       $value += $sheet->Cell($icell, $sp_number);
       $vol += $sheet->Cell($icell, $vol_number);
       $Nsamples += 1;
  
   }

   #printf "2. %f %f\n", $value, $value/$Nsamples;    
   #printf "====\n";
   printf "%f %f\n", $value/$Nsamples, $vol/$Nsamples;    
}

   printf "2. Time taken: %d seconds\n", time()-$^T;


