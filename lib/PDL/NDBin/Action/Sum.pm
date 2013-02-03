package PDL::NDBin::Action::Sum;
# ABSTRACT: Action for PDL::NDBin that computes sum

=head1 DESCRIPTION

This class implements an action for PDL::NDBin.

=cut

use strict;
use warnings;
use PDL::Lite;		# do not import any functions into this namespace
use PDL::NDBin::Actions_PP;

=head1 METHODS

=head2 new()

	my $instance = PDL::NDBin::Action::Sum->new( $N );

Construct an instance for this action. Requires the number of bins $N as input.

=cut

sub new
{
	my $class = shift;
	my $m = shift;
	return bless { m => $m }, $class;
}

=head2 process()

	$instance->process( $iter );

Run the action with the given iterator $iter. This action will compute all bins
during the first call and will subsequently deactivate the variable.

=cut

sub process
{
	my $self = shift;
	my $iter = shift;
	my $type = $iter->data->type < PDL::long() ? PDL::long : $iter->data->type;
	$self->{out} = PDL->zeroes( $type, $self->{m} ) unless defined $self->{out};
	$self->{count} = PDL->zeroes( PDL::long, $self->{m} ) unless defined $self->{count};
	PDL::NDBin::Actions_PP::_isum_loop( $iter->data, $iter->idx, $self->{out}, $self->{count}, $self->{m} );
	# as the plugin processes all bins at once, every variable
	# needs to be visited only once
	$iter->var_active( 0 );
	return $self;
}

=head2 result()

	my $result = $instance->result;

Return the result of the computation.

=cut

sub result
{
	my $self = shift;
	PDL::NDBin::Actions_PP::_setnulltobad( $self->{count}, $self->{out} );
	return $self->{out};
}

1;
