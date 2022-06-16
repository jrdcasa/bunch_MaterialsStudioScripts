use strict;
use MaterialsScript qw(:all);

# Get the trajectory and cut it. The initial trj is overwritted.
my $doc = $Documents{"pA6-n10_NPT2.xtd"};
$doc->Trajectory->RemoveFrames(Frames(Start =>20, End => 9997));


printf "Time taken: %d seconds", time()-$^T;
