use strict;
use MaterialsScript qw(:all);

my $doc = $Documents{"201-Step.xtd"};

Modules->Forcite->ChangeSettings([NumberOfSteps => 10000,
                                    TrajectoryFrequency => 1000,
                                     CurrentForcefield => "COMPASS",
                                    Pressure => 0.000101,
                                    StressXX => -0.000101,
                                    StressYY => -0.000101,
                                    StressZZ => -0.000101,
                                    TrajectoryRestart => "Yes",
                                    Temperature => 500,
                                    Ensemble3D => "NPT"]);

my $results = Modules->Forcite->Dynamics->Run($doc);

printf "Time taken: %d seconds", time()-$^T;
