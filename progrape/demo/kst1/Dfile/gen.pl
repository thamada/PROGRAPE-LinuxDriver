#!/usr/bin/perl

my $N = 300;
my $XSCALE = 1.0;
my $YSCALE = 1.0;

srand(12345);

print $N ."\n";

for(my $i=0;$i<$N;$i++){
    my $x = (rand(1.0)*$XSCALE - $XSCALE/2.0);
    my $y = (rand(1.0)*$YSCALE - $XSCALE/2.0);
    my $s = sprintf("%e\t%e\n",$x,$y);
    print $s;
}
