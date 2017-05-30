#!/usr/bin/perl

use strict;
use warnings;
use POSIX 'floor';

my $pi = atan2(1, 1) * 4;

my $N  = 64;	# Number of FFT Points
my $NB = 16;	# Number of Twiddle Data Bits

my $ND = int(log(2**($NB-1))/log(10)) + 2;	# Number of Decimal Digits
my $NX = int(($NB + 3) / 4);	# Number of Hexadecimal Digits

for (my $n = 0; $n < $N; ++$n) {
#	my $wr = 1;							my $wi = 0;
#	my $wr = cos(2 * $pi * $n / $N);	my $wi = sin(2 * $pi * $n / $N);
#	my $wr = sin(2 * $pi * $n / $N);	my $wi = -cos(2 * $pi * $n / $N);
#	my $wr = cos(2 * $pi * $n / $N);	my $wi = 0;
	my $wr = cos(15 * 2*$pi * $n/$N);	my $wi = sin(15 * 2*$pi * $n/$N);
	$wr *= 0.9999;
	$wi *= 0.9999;

	my $wr_d = floor($wr * 2**($NB-1) + 0.5);	$wr_d -= 1 if ($wr_d == 2**($NB-1));
	my $wi_d = floor($wi * 2**($NB-1) + 0.5);	$wi_d -= 1 if ($wi_d == 2**($NB-1));
	my $wr_u = ($wr_d < 0) ? ($wr_d + 2**$NB) : $wr_d;
	my $wi_u = ($wi_d < 0) ? ($wi_d + 2**$NB) : $wi_d;

#	printf("%${ND}d  %${ND}d  ", $wr_d, $wi_d);
#	printf("%0${NB}b  %0${NB}b  ", $wr_u, $wi_u);
	printf("%0${NX}X  %0${NX}X  ", $wr_u, $wi_u);
	printf("// %2d", $n);
	printf(" % .3f % .3f", $wr, $wi);
	print "\n";
}
