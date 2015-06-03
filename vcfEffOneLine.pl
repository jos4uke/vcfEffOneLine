#!/usr/bin/perl

#use warnings;

#-------------------------------------------------------------------------------
#
# Read a VCF file (via STDIN), split EFF fields from INFO column into many lines
# leaving one line per effect.
#
# Note: In lines having multiple effects, all other information will be 
#       repeated. Only the 'EFF' field will change.
#
#															Pablo Cingolani 2012
#													   MODIFIED BY BH NAJLA 2013
#													   MAINTAINED BY Joseph Tran 2013
#													   Version : v0.3
#-------------------------------------------------------------------------------


my $file =shift @ARGV || die "usage: vcfEffOnePerlLineN.pl fichier.vcf \n";

($prefixe=$file) =~ s/.vcf//;


my $outfile = "$prefixe"."_"."OneLineEff.vcf";

open (IN,$file);
open(OUT,">$outfile") or die "Can't write to file '$file' [$!]\\n";

my $verbosity = 0;

my $INFO_FIELD_NUM = 7;

#FILE OUT
while($l = <IN>) {
	# Show header lines
	if ($verbosity >= 10) { print $l; }
	if( $l =~ /^#/ ) { 
		if ($verbosity >= 10) { print $l; } 
	}	
	else {
		chomp $l;

		@t = @infos = @effs = (); # Clear arrays

		# Non-header lines: Parse fields
		@t = split /\t/, $l;

		# Get INFO column
		my $info = $t[ $INFO_FIELD_NUM ];

		# Parse INFO column 
		my @infos = split /;/, $info;

		# Find EFF field
		$infStr = "";
		foreach $inf ( @infos ) {
			# Is this the EFF field? => Find it and split it
			if( $inf =~/^EFF=(.*)/ ) { @effs = split /,/, $1; }
			else { $infStr .= ( $infStr eq '' ? '' : ';' ) . $inf; }
		}	

		# Print VCF line
		if( $#effs <= 0 )	{ print OUT "$l\n"; }	# No EFF found, just show line
		else {
			$pre = "";
			for( $i=0 ; $i < $INFO_FIELD_NUM ; $i++ ) { $pre .= ( $i > 0 ? "\t" : "" ) . "$t[$i]"; }

			$post = "";
			for( $i=$INFO_FIELD_NUM+1 ; $i <= $#t ; $i++ ) { $post .= "\t$t[$i]"; }

			foreach $eff ( @effs ) { print OUT $pre . "\t" . $infStr . ( $infStr eq '' ? '' : ';' ) . "EFF=$eff" . $post . "\n" ; }
		}
	}
}

close(OUT);
close(IN);

