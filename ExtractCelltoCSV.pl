#!perl

use strict;
use Getopt::Long;
use MaterialsScript qw(:all);

my @filestoexport = ("01-Defaults-T400K_deloc Blends Mixing/01-Defaults-T400K_deloc.std",
		     "01-Defaults-T400K_deloc_b Blends Mixing/01-Defaults-T400K_deloc_b.std",
		     "01-Defaults-T400K_deloc_c Blends Mixing/01-Defaults-T400K_deloc_c.std",);

my $exportDir = "Export";
my @labellist =("a", "b", "c");
my $index = 0;

foreach my $ifile (@filestoexport) {

	my $stddoc = $Documents{$ifile};

	my $typegraph = $stddoc->cell(1,2)->Type;
	my $graph = $stddoc->cell(1,2);

	print("Type: $typegraph\n");

	my $outnamefile = sprintf($exportDir."/Energy_400K_".$labellist[$index].".csv");
	print($outnamefile."\n");

	$graph->Export($outnamefile);

	$stddoc->close();

	$index += 1;
}
