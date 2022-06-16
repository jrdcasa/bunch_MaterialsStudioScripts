#!perl

# This script can be used to perform a NPT simulation followed by NVT simulation to 
# equilibrate at different temperatures
# How to use it:
#   1.- Put the initial configuration in the same folder that this script
#   2.- Setup the following parameters in the script (lines 79-84)
#	my $steps = 7;             # Number of temperatures
# 	my $temp_initial = 598;    # Initial temperature (K)
# 	my $delta_temp = 50;       # Decrease the temperature (K)
#	my $initialxsd = "Initial.xtd"; # Initial structure
#   3.- Run the script on the server (CTRL+F5)

use strict;
use Getopt::Long;
#To access the functionality of the MaterialsScript package
use MaterialsScript qw(:all);
use Cwd qw(cwd);

sub NPTMD_Sim {

    my $doc = shift;     # Molecular document
    my $temp = shift;    # Temperature
    
    my $results = Modules->Forcite->Dynamics->Run($doc, Settings(
      	         '3DPeriodicvdWAtomCubicSplineCutOff' => 8.5, 
	         CurrentForcefield => 'COMPASS', 
	         TrajectoryRestart => 'Yes', 
	         Ensemble3D => 'NPT', 
	         Pressure => 0.0001, 
	         NumberOfSteps => 500000, 
           	 Thermostat => 'Andersen', 
	         TrajectoryFrequency => 1000, 
	         StressXX => -0.0001, 
	         StressYY => -0.0001, 
	         StressZZ => -0.0001,
                 Temperature => $temp));

    my $outTrajectory = $results->Trajectory   

}

sub NPTMD_SimNoRestart {

    my $doc = shift;     # Molecular document
    my $temp = shift;    # Temperature
    
    my $results = Modules->Forcite->Dynamics->Run($doc, Settings(
      	         '3DPeriodicvdWAtomCubicSplineCutOff' => 8.5, 
	         CurrentForcefield => 'COMPASS', 
	         TrajectoryRestart => 'No', 
	         Ensemble3D => 'NPT', 
	         Pressure => 0.0001, 
	         NumberOfSteps => 500000, 
           	 Thermostat => 'Andersen', 
	         TrajectoryFrequency => 1000, 
	         StressXX => -0.0001, 
	         StressYY => -0.0001, 
	         StressZZ => -0.0001,
                 Temperature => $temp));

    my $outTrajectory = $results->Trajectory   

}

sub NVTMD_Sim {

    my $doc = shift;     # Molecular document
    my $temp = shift;    # Temperature
    
    my $results = Modules->Forcite->Dynamics->Run($doc, Settings(
      	         '3DPeriodicvdWAtomCubicSplineCutOff' => 8.5, 
	         CurrentForcefield => 'COMPASS', 
	         TrajectoryRestart => 'Yes', 
	         Ensemble3D => 'NVT', 
           	 Thermostat => 'Andersen', 
	         NumberOfSteps => 100000, 
	         TrajectoryFrequency => 1000, 
                 Temperature => $temp));

    my $outTrajectory = $results->Trajectory   

}

# ================================================================================

my $steps = 7;
my $temp_initial = 598;
my $delta_temp = 50;
my $initialxsd = "Initial.xtd";

for (my $istep=0; $istep<$steps; ++$istep) {

	my $temp_prev =  sprintf("%04d",$temp_initial - $delta_temp * ($istep-1));
	my $temp_curr =  sprintf("%04d",$temp_initial - $delta_temp * $istep);
	my $istep_c_padding = sprintf("%03d", $istep);
	my $istep_p_padding = sprintf("%03d", ($istep-1));

	
	my $strcurr = $istep_c_padding."_NPT_Step_".$temp_curr."K.xtd";
	my $newDoc = Documents->New($strcurr);

	# For the first step we copy the input structure. For the rest of steps
	# the final structure is chosen an the fragments are move by delta angstroms.
	if ($istep == 0) {
	
	    $newDoc->InsertFrom($Documents{$initialxsd});
	    
        }
         else {
       
            my $strprevious = $istep_p_padding."_NVT_Step_".$temp_prev."K.xtd";            
            $newDoc->CopyFrom($Documents{$strprevious});
          
        }
        
        if ($istep == 0) {
        	NPTMD_SimNoRestart($newDoc, $temp_curr);
        } else {
        	NPTMD_Sim($newDoc, $temp_curr);
	}
        
        my $traj_last_NPT = $Documents{$strcurr}->EndFrame;

        my $str_NVT = $istep_c_padding."_NVT_Step_".$temp_curr."K.xtd";
        my $str_NVT = Documents->New($str_NVT);
	$str_NVT->CopyFrom($Documents{$strcurr});

	NVTMD_Sim($str_NVT, $temp_curr);

 

}
	
       



