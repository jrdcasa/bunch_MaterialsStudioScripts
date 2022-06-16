#!perl

use strict;
use Getopt::Long;
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

my $strcurr = "Try02.xsd";
my $newDoc = $Documents{$strcurr};
get_all_atom_indexes($newDoc);
