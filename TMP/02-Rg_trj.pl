#use strict;
use MaterialsScript qw(:all);

# Open trajectory
my $doctrj = $Documents{"newtrj.xtd"};
my $trj = $Documents{"newtrj.xtd"}->Trajectory;


my $nframes = $trj->NumFrames;
#Modules->Forcite->Analysis->RadiusOfGyrationEvolution($doctrj, Settings(RadiusOfGyrationBinWidth => 0.2));

for (my $iframe=0; $iframe<$nframes; ++$iframe) {

    printf "# of frame: %d\n", $iframe;
    
    # Currrent Frame
    $trj->CurrentFrame = $iframe+1;

     
    my $molecules = $doctrj->AsymmetricUnit->Molecules;
    
    foreach my $imol (@$molecules) {
    
    	printf "%s %s KK\n",$imol, $imol->Sets;
    	my $iset = $imol->Sets;
    
    	Modules->Forcite->Analysis->RadiusOfGyrationEvolution($doctrj, Settings(RadiusOfGyrationBinWidth => 0.2, RadiusOfGyrationEvolutionSetA=>$imol));

    }
    
    my $a = $trj->FrameEnergy;
    printf "%f\n",$a;

 

    


}




























printf "Time taken: %d seconds", time()-$^T;
