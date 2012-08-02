package PDL::NDBin::Func::IStdDev;

use strict;
use warnings;
use PDL::Lite;		# do not import any functions into this namespace
use PDL::NDBin::Func::PP;

sub new
{
	my $class = shift;
	my $m = shift;
	return bless { m => $m }, $class;
}

sub process
{
	my $self = shift;
	my $iter = shift;
	$self->{out} = PDL->zeroes( PDL::double, $self->{m} ) unless defined $self->{out};
	$self->{count} = PDL->zeroes( PDL::long, $self->{m} ) unless defined $self->{count};
	$self->{avg} = PDL->zeroes( PDL::double, $self->{m} ) unless defined $self->{avg};
	PDL::NDBin::Func::PP::_istddev_loop( $iter->data, $iter->hash, $self->{out}, $self->{count}, $self->{avg}, $self->{m} );
	# as the plugin processes all bins at once, every variable
	# needs to be visited only once
	$iter->var_active( 0 );
	return $self;
}

sub result
{
	my $self = shift;
	PDL::NDBin::Func::PP::_istddev_post( $self->{count}, $self->{out} );
	return $self->{out};
}

1;
