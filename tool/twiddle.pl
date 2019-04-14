#!/usr/bin/perl

use strict;
use warnings;
use POSIX 'floor';

my $pi = atan2(1, 1) * 4;

my $N = 1024;	# Number of FFT Points
my $NB = 32;	# Number of Twiddle Data Bits

my $ND = int(log(2**($NB-1))/log(10)) + 2;	# Number of Decimal Digits
my $NX = int(($NB + 3) / 4);	# Number of Hexadecimal Digits

my $XX = "x" x $NX;	# Hexadecimal Unknown Value String

printf("//      wn_re = cos(-2pi*n/%2d)  ", $N);
printf("        wn_im = sin(-2pi*n/%2d)\n", $N);

for (my $n = 0; $n < $N; ++$n) {
	my $wr = cos(-2 * $pi * $n / $N);
	my $wi = sin(-2 * $pi * $n / $N);

	my $wr_d = floor($wr * 2**($NB-1) + 0.5);	$wr_d -= 1 if ($wr_d == 2**($NB-1));
	my $wi_d = floor($wi * 2**($NB-1) + 0.5);	$wi_d -= 1 if ($wi_d == 2**($NB-1));
	my $wr_u = ($wr_d < 0) ? ($wr_d + 2**$NB) : $wr_d;
	my $wi_u = ($wi_d < 0) ? ($wi_d + 2**$NB) : $wi_d;

#	printf("%${ND}d  %${ND}d  ", $wr_d, $wi_d);
#	printf("%0${NB}b  %0${NB}b  ", $wr_u, $wi_u);
#	printf("%0${NX}X  %0${NX}X  ", $wr_u, $wi_u);
	my $dontcare = 1;
	$dontcare = 0 if ($n < $N/4);
	$dontcare = 0 if (($n < 2*$N/4) && ($n % 2 == 0));
	$dontcare = 0 if (($n < 3*$N/4) && ($n % 3 == 0));
	$wr_u = 0 if ($n == 0);
	my $wr_s = ($dontcare) ? $XX : sprintf("%0${NX}X", $wr_u);
	my $wi_s = ($dontcare) ? $XX : sprintf("%0${NX}X", $wi_u);
	printf("assign  wn_re[%2d] = ${NB}'h$wr_s;   ", $n);
	printf("assign  wn_im[%2d] = ${NB}'h$wi_s;   ", $n);
	printf("// %2d", $n);
	printf(" % .3f % .3f", $wr, $wi);
	print "\n";
}
