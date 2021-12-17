#!perl

use strict;
use Getopt::Long;
use MaterialsScript qw(:all);
use Cwd;


sub Min01 {

	# Minimize a structure	
	my $doc = shift;	# Molecular document
	my $iter = shift;	# Maximum number of iterations
	
	
	my $results = Modules->Forcite->GeometryOptimization->Run($doc, Settings(
	CurrentForcefield => 'COMPASSIII', 
	MaxIterations => $iter, 
	MaxForce => 0.005, 
	MaxStress => 0.005, 
	MaxDisplacement => 5e-005, 
	MaxEnergy => 0.0001, 
	UseMaxStress => 'Yes', 
	UseMaxDisplacement => 'Yes',
	UseGPU => 'No'));

}

sub NVTMD01 {

	my $doc = shift;     # Molecular document
	my $temp = shift;    # Temperature
	my $nsteps = shift;  # Number of steps
	my $nfreq = shift;   # Frequency to save the trajectory

    my $results = Modules->Forcite->Dynamics->Run($doc, Settings(
	    '3DPeriodicElectrostaticSummationMethod' => 'PPPM', 
	    '3DPeriodicvdWAtomCubicSplineCutOff' => 10.5,
	    CurrentForcefield => 'COMPASSIII', 
	    Ensemble3D => 'NVT', 
    	Temperature => $temp, 
    	NumberOfSteps => $nsteps, 
    	TrajectoryFrequency => $nfreq, 
	    Thermostat => 'Andersen',
	    UseGPU	=> 'Yes'));
    my $outTrajectory = $results->Trajectory;

}

sub NPTMD02 {

	my $doc = shift;     # Molecular document
	my $temp = shift;    # Temperature
	my $nsteps = shift;  # Number of steps
	my $nfreq = shift;   # Frequency to save the trajectory

    my $results = Modules->Forcite->Dynamics->Run($doc, Settings(
	    '3DPeriodicElectrostaticSummationMethod' => 'PPPM', 
    	'3DPeriodicvdWAtomCubicSplineCutOff' => 10.5, 
    	CurrentForcefield => 'COMPASSIII', 
    	Ensemble3D => 'NPT', 
    	Temperature => $temp, 
    	Pressure => 0.000101325, 
    	NumberOfSteps => $nsteps, 
    	TrajectoryFrequency => $nfreq, 
    	Thermostat => 'Andersen', 
    	StressXX => -0.000101325, 
    	StressYY => -0.000101325, 
    	StressZZ => -0.000101325,
        UseGPU	=> 'Yes'));

    my $outTrajectory = $results->Trajectory;
}


# =================================== MAIN PROGRAM ==============================
#Open the multiframe trajectory created by AC
my $trjname = "ETH_EVA_18wt.xtd";
my $minsteps = 3000;

my $doctrj = $Documents{$trjname};
my $trj = $doctrj->Trajectory;

# Minimization for each frame
if ($trj->NumFrames>0) {

    # ================== MINIMIZATION ==========================
	# Loop for all equilibration simulations
    for ( my $frame=1; $frame<=$trj->NumFrames; ++$frame){
        # Setup variables
        my $frameprint = sprintf("%03d",$frame);
        my $name = "01-Min_Frame_".$frameprint.".xsd";
        my $now_string = localtime;
        print "Min: ".$frame." of ".$trj->NumFrames." frames."."(".$now_string.")\n";
        # Move the trajectory to frame
        $trj->CurrentFrame = $frame;
        # Doc and mol MS for the current frame
        my $allDoc = Documents->New($name);
        my $mol = $allDoc->CopyFrom($doctrj); 
        # Run minimization
        Min01($mol, $minsteps);
    }
	

	my $now_string = localtime;
	print ("Job Done!!!.(".$now_string.")\n");
	
	
}		

