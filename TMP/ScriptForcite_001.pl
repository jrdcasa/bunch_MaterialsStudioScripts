use strict;
use MaterialsScript qw(:all);

my $doc = $Documents{"01-Step.xsd"};

my $results = Modules->Forcite->Dynamics->Run($doc, Settings(
        CurrentForcefield => "COMPASS",
        TrajectoryRestart => "No",
        Ensemble3D => "NPT",
        Temperature => 500,
        Pressure => 0.000101,
        NumberOfSteps => 10000000,
        TrajectoryFrequency => 20000));
        StressXX => -0.000101,
        StressYY => -0.000101,
        StressZZ => -0.000101,
my $outTrajectory = $results->Trajectory;

printf "Time taken: %d seconds", time()-$^T;
