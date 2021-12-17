#!perl

use strict;
use Getopt::Long;
use MaterialsScript qw(:all);

sub AC_build {

	# Example: AC_build("PE150.xsd", 5, 450, 0.6, 10)

	my $doc = shift;
	my $chains = shift;
	my $temp = shift;
	my $dens = shift;
	my $conf = shift;

	my $acConstruction = Modules->AmorphousCell->Construction;
	my $component1 = $Documents{$doc};
	$acConstruction->AddComponent($component1);
	$acConstruction->Loading($component1) = $chains;
	my $results = $acConstruction->Run(Settings(
		Temperature => $temp, 
		Configurations => $conf, 
		TargetDensity => $dens, 
		CheckCloseContacts => 'No', 
		CheckEnergies => 'Yes', 
		CheckBackboneOnly => 'Yes',
		CurrentForcefield => 'COMPASSIII',  
		ChargeAssignment => 'Forcefield assigned'));
	my $outTrajectory = $results->Trajectory;
}



sub AC_build_multi {

	# Setup AC builder with multicomponents
	# Example: AC_build_multi(\@listcomp, \@listchains, $temp, $dens, $nframes);

	my $listdoc = $_[0];
	my $listchains = $_[1];
	my $temp = $_[2];
	my $dens = $_[3];
	my $conf = $_[4];
	

	my $acConstruction = Modules->AmorphousCell->Construction;
	my $i = 0;
	for (@$listdoc) {	
		print("Add: ".$i." ".$listdoc->[$i]." ".$listchains->[$i]."\n");
		my $c = $Documents{$listdoc->[$i]};
		$acConstruction->AddComponent($c);
		$acConstruction->Loading($c) = $listchains->[$i];
		$i += 1;
	}



	my $results = $acConstruction->Run(Settings(
		Temperature => $temp, 
		Configurations => $conf, 
		TargetDensity => $dens, 
		CheckCloseContacts => 'No', 
		CheckEnergies => 'Yes', 
		CheckBackboneOnly => 'Yes',
		CurrentForcefield => 'COMPASSIII',  
		ChargeAssignment => 'Forcefield assigned'));
	my $outTrajectory = $results->Trajectory;

}



# Main program ================================================================
# LIst of components and number of molecules to insert in the amorphous cell
my @listcomp = ("EVA_150_08br_01.xsd", "EVA_150_08br_02.xsd", "EVA_150_08br_03.xsd", "EVA_150_08br_04.xsd", "EVA_150_08br_05.xsd");
my @listchains = ( 1, 1, 1, 1, 1);
my $temp = 450;    # K
my $density = 0.6; # g/cm3
my $nframes = 10;

# Length of both list must be equal
my $l1 = scalar @listcomp;
my $l2 = scalar @listchains;
if ($l1 != $l2) {
	print("ERROR: Length of list components must be equal to the length of loading components\n");
	print("listcomp = (@listcomp)\n");
	print("listchains = (@listchains)\n");
	exit;
}

# Call amorphous builder 
AC_build_multi(\@listcomp, \@listchains, $temp, $density, $nframes);


