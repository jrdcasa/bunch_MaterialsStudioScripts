#!perl

# This script can be used to perform a scan calculation on a distance in DMOL3
# How to use it:
#   1.- In the xsd document define the sets (Edit --> Edit Sets)
#   2.- Define the distance constraint (Modify --> Constraints --> Measurements)
#   3.- Setup the following parameters in the script (lines 79-84)
#	my $steps = 3;
#	my $delta = 0.2;
#	my $initialxsd = "test.xsd";
#	my $iatom1 = 4;
#	my $iatom2 = 6;
#	my $nameSets = "Ethane";
#   4.- Run the script on the server (CTRL+F5)

use strict;
use Getopt::Long;
#To access the functionality of the MaterialsScript package
use MaterialsScript qw(:all);

sub get_all_atom_indexes {

    # Get all index atoms along with its XYZ coordinates.
    # This is useful to get indesex of atoms of interest.
    # Example: 
    #   get_all_atom_indexes($doc);

    my $doc = shift;     # Molecular document 

    # Get atoms by index =========================================
    for (my $i=0; $i<$doc->Atoms->Count; ++$i) {
        my $atom = $doc->Atoms($i);
        print $i. " " .$atom->X ." " . $atom->Y ." " . $atom->Z . "\n";
    }

}

sub move_a_fragment_along_distance {
 
    # Given a document, move the fragment $name by $delta alogn the 
    # vector defined by $iatom1 and $iatom2
    # Example:
    #  	move_a_fragment($doc, 4, 6, "Ethane", 0.2);
    # The name of the set must be previously defined in the XSD document.

    my $doc = shift;     # Molecular document 
    my $iatom1 = shift;  # Index of the first atom in the distance
    my $iatom2 = shift;  # Index of the second atom in the distance
    my $name = shift;    # Name of the set to move along the distance vector
    my $delta=shift;     # Displacements in angstroms

    
    my $atom1 = $doc->Atoms($iatom1);
    my $atom2 = $doc->Atoms($iatom2);
    my $atomstomove = $doc->Sets($name);
    my $vector = $atom1->XYZ - $atom2->XYZ;
    $vector->Normalize();
    my $monitor = $doc->CreateDistance([$atom1, $atom2]);
    $atomstomove->Translate($vector * $delta);
}

sub dmol3Optimization {

    my $doc = shift;     # Molecular document
    
    my $results = Modules->DMol3->GeometryOptimization->Run($doc, Settings(
		UseSymmetry => 'No', 	
		TheoryLevel => 'GGA', 
		NonLocalFunctional => 'BLYP', 
		Basis => 'DNP', 
		AtomCutoff => 3.3, 
		CoreTreatment => 'Effective Core Potentials', 
		DFTDMethod => 'Grimme', 
		UseDFTD => 'Yes', 
		KPointDerivation => 'Quality', 
		ElectronDensity	=> 'Yes',
		Electrostatics => 'Yes',
		CreateEnergyEvolutionChart=> 'Yes'));
    my $outTrajectory = $results->Trajectory;
   

}

# ================================================================================

my $steps = 3;
my $delta = 0.2;
my $initialxsd = "test.xsd";
my $iatom1 = 4;  # in the fix fragment
my $iatom2 = 6;  # in the mobile fragment
my $nameSets = "Ethane";

for (my $istep=0; $istep<$steps; ++$istep) {

        my $istep_c_padding = sprintf("%03d", $istep);
	my $istep_p_padding = sprintf("%03d", ($istep-1));

	my $strcurr = "scan".$istep_c_padding."/myFilename".$istep_c_padding.".xsd";
	my $newDoc = Documents->New($strcurr);

	# For the first step we copy the input structure. For the rest of steps
	# the final structure is chosen an the fragments are move by delta angstroms.
	if ($istep == 0) {
	
	    $newDoc->CopyFrom($Documents{$initialxsd});
	    
        } else {
        
            my $strprevious = "scan".$istep_p_padding."/myFilename".$istep_p_padding.".xsd";            
            $newDoc->CopyFrom($Documents{$strprevious});
                        
            # As the initial structure is not saved in the trj, 
            # here is copied in the current directory (just for Debug)
            my $strtmp = "scan".$istep_c_padding."/myFilename".$istep_p_padding.".xsd";
            my $tmpDoc = Documents->New($strtmp);
            $tmpDoc->CopyFrom($Documents{$strprevious});
            
            move_a_fragment_along_distance($newDoc, $iatom1, $iatom2, $nameSets, $delta);
            
            # Structure after move the fragments (just for Debug)
            my $strtmp = "scan".$istep_c_padding."/myFilename_init".$istep_c_padding.".xsd";
            my $tmpDoc = Documents->New($strtmp);
            $tmpDoc->CopyFrom($Documents{$strcurr});

            
        }
        
        dmol3Optimization($newDoc);
        
        my $atom1 = $newDoc->Atoms($iatom1);
    	my $atom2 = $newDoc->Atoms($iatom2);
        printf "%d %f (A) %f (kcal/mol)\n", $istep, $newDoc->CreateDistance([$atom1, $atom2])->Distance, $newDoc->Energy->TotalEnergy;
	

}


