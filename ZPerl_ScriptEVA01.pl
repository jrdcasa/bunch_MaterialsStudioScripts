#!perl

use strict;
use Getopt::Long;
use MaterialsScript qw(:all);
use Cwd;


# ===========================================================
sub createDiBlockCopolymer {

    
    my $doc = $_[0];            # Molecular document
    my @rlist = @{$_[1]};       # Path to repeat unit 1
    my @nlist = @{$_[2]};       # Path to repeat unit 2


    # Length of both list must be equal
    my $l1 = scalar @rlist;
    my $l2 = scalar @nlist;
    if ($l1 != $l2) {
	print("ERROR: Length of list paths must be equal to the length of loading components\n");
	print("listcomp = (@rlist)\n");
	print("listchains = (@nlist)\n");
        print(" $l1, $l2\n");
	exit;
    }


    # Use BlockCopolymer tool to build the copolymer
    my $blockCopolymer = Tools->PolymerBuilder->BlockCopolymer;
    $blockCopolymer->ClearRepeatUnits();

    # Add repeat units
    my $idx = 0;
    my @RUlist = ();
    foreach my $item (@rlist){
       
   	my $repeatUnit = Documents->Import($item);
   	push @RUlist, $repeatUnit;
    	$blockCopolymer->AddRepeatUnit($repeatUnit, @nlist[$idx]);
    	$idx += 1;
    	
    }
    
    # Create the copolymer
    $blockCopolymer->Build($doc, 1);
    
    # Clean the project
    foreach my $item (@RUlist){
	$item->Delete();       
    }
    
}




# =================================== MAIN PROGRAM ==============================
# List with the positions of the comonomer, i.e 9 means the 9th position 
# of the monomer in the polymer. The list (9, 19, 28) will create a copolymer with
# the following sequence (monomer1: ETH and monomer2:EVA):
#    1ETH..8ETH-9EVA-10ETH...18ETH-19EVA-20ETH...27ETH-28EVA-29ETH...150ETH
# ncomonomer list stores the number of comonomers after the main monomer.
# The monomer 0 is always the reference monomer
# The next mononers are comonomers, the type of the repeat unit is given in the list @tcomonomerlist.
# This allows one to built a random copolymer with any number of comonomers

#  ********** INPUTS ********** 
my @comonomerlist  = (14, 27, 41, 55, 69, 83, 97, 111, 125, 139);
my @ncomonomerlist = ( 1,  1,  1,  1,  1,  1,  1,   1,   1,   1);
my @tcomonomerlist = ( 1,  1,  1,  1,  1,  1,  1,   1,   1,   1);
my $nmonomers = 150;
my @r_paths = ("structures://repeat-units/olefins/ethylene.xsd",
               "structures://repeat-units/vinyls/vinyl_acetate.xsd");
my $polymerDoc = Documents->New("ETH_EVA_18wt.xsd");
#  ********** END INPUTS ********** 

my $ncomonomers = $#comonomerlist+1;
my $idx=0;  # Count the number of monomers already put
my $nr0;
my $nr1;
my $tr1;

my $wkdir = getcwd."/ZPerl_ScriptEVA01_Files/Documents/";
print("Working directory in the server: ".$wkdir."\n");

my @copolymercompRU = ();
my @copolymercompN = ();
foreach my $item (@comonomerlist){

   
   if ($idx == 0) {
       # Number of repeat units 0
       $nr0 = $item - 1;
       $nr1 = @ncomonomerlist[$idx];
       $tr1 = @tcomonomerlist[$idx];
       
   } else {
       # Number of repeat units 1
       $nr0 = $item - @comonomerlist[$idx-1] - 1;
       $nr1 = @ncomonomerlist[$idx];
       $tr1 = @tcomonomerlist[$idx];
   }
   
   #my $repeatUnit0 = Documents->Import(@r_paths[0]);
   #my $repeatUnit1 = Documents->Import(@r_paths[$tr1]);
   
   push @copolymercompRU, @r_paths[0];
   push @copolymercompN, $nr0;
   push @copolymercompRU, @r_paths[$tr1];
   push @copolymercompN, $nr1;
   
   #$repeatUnit0 -> Delete();
   #$repeatUnit1 -> Delete();
   
   $idx += 1;


} 

# Create the tail sequence of the copolymer;
$nr0 = $nmonomers - @comonomerlist[$ncomonomers-1];
print("$nr0, $nmonomers,  @comonomerlist[$ncomonomers-1]\n");
push @copolymercompRU, @r_paths[0];
push @copolymercompN, $nr0;


createDiBlockCopolymer($polymerDoc, \@copolymercompRU, \@copolymercompN);

print "@copolymercompRU\n";
print "@copolymercompN\n";




