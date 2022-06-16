#!perl

use strict;
use Getopt::Long;
use MaterialsScript qw(:all);

my $datestring = localtime();
print "Starting time $datestring\n";


#open the multiframe trajectory structure file or die 
my $doc = $Documents{"./PAM10_PVA10_Si2.xtd"}; 

if (!$doc) {die "no document";}


#$doc->GenerateLatticeDisplay(["PeriodicDisplayType" => "In-Cell"]);
my $trajectory = $doc->Trajectory;
my $lattice3d = $doc->Lattice3D;
                       


if ($trajectory->NumFrames>1) {

    # Open new report file
    my $report=Documents->New("xtd2xmol.txt");
    $report->Append("Found ".$trajectory->NumFrames." frames in the trajectory\n");
    $report->Close;
    
    # Open new xmol trajectory file
    my $xmolFile=Documents->New("trj_xyz.txt");
    
    #get beads in the structure
    my $beads = $doc->UnitCell->Beads;
    my $Nbeads=@$beads;

    # loops over the frames 
    for (my $frame=1; $frame<=$trajectory->NumFrames; ++$frame){

	print "Frame = " . $frame . " of " . $trajectory->NumFrames . " frames.\n ";
        $trajectory->CurrentFrame = $frame;


	my $lattice = $doc->SymmetryDefinition;
	my $lenA = $lattice->LengthA;
	my $lenB = $lattice->LengthB;
	my $lenC = $lattice->LengthC;


        #write header xyz
        $xmolFile->Append(sprintf "%i \n", $Nbeads);
        $xmolFile->Append(sprintf "Frame %i \n", $frame);
        foreach my $bead (@$beads) {
        
            # write atom symbol and x-y-z- coordinates
     i       
            my $unwrpX = $bead->X;
            my $unwrpY = $bead->Y;
            my $unwrpZ = $bead->Z;
            
            if ($unwrpX < 0.0  ) { 
            	my $nx = int(abs($bead->X)/$lenA)+1;
            	$unwrpX = $unwrpX + $nx*$lenA; 
            }
            if ($unwrpY < 0.0  ) { 
            	my $ny = int(abs($bead->Y)/$lenB)+1;
            	$unwrpY = $unwrpY + $ny*$lenB; 
            }
            if ($unwrpZ < 0.0  ) { 
            	my $nz = int(abs($bead->Z)/$lenC)+1;
            	$unwrpZ = $unwrpZ + $nz*$lenC; 
            }

            if ($unwrpX > $lenA) {
            	my $nx = int(abs($bead->X)/$lenA);
            	$unwrpX = $unwrpX - $nx*$lenA; 

            }            
            if ($unwrpY > $lenB) { 
            	my $ny = int(abs($bead->Y)/$lenB);
            	$unwrpY = $unwrpY - $ny*$lenB; 
            }
            if ($unwrpZ > $lenC) { 
            	my $nz = int(abs($bead->Z)/$lenC);
            	$unwrpZ = $unwrpZ - $nz*$lenC; 
            }

             
            $xmolFile->Append(sprintf "%s %f  %f  %f \n",$bead->BeadTypeName, $unwrpX, $unwrpY, $unwrpZ); 
        }
            
    } 
    #close trajectory file
    $xmolFile->Close;

} 
else { 
    print "The " . $doc->Name . " is not a multiframe trajectory file \n"; 
}

my  $datestring = localtime();
print "Jod Done time $datestring\n";

