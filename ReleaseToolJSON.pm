=head1 NAME

EPrints::Plugin::Export::ReleaseToolJSON

=cut

package EPrints::Plugin::Export::ReleaseToolJSON;

use EPrints::Plugin::Export::JSON;

@ISA = ( "EPrints::Plugin::Export::JSON" );

use strict;


sub new
{
	my( $class, %opts ) = @_;

	my( $self ) = $class->SUPER::new( %opts );

	$self->{name} = "Release Tool JSON";

	return $self;
}



sub _epdata_to_json

{
	my( $self, $epdata, $depth, $in_hash, %opts ) = @_;

	my $pad = "  " x $depth;
	my $pre_pad = $in_hash ? "" : $pad;
	

	if( !ref( $epdata ) )
	{
		
		if( !defined $epdata )
		{
			return "null"; # part of a compound field
		}
	
		if( $epdata =~ /^-?[0-9]*\.?[0-9]+(?:e[-+]?[0-9]+)?$/i )
		{
			return $pre_pad . ($epdata + 0);
		}
		else
		{
			return $pre_pad . EPrints::Utils::js_string( $epdata );
		}
	}
	elsif( ref( $epdata ) eq "ARRAY" )
	{
		return "$pre_pad\[\n" . join(",\n", grep { length $_ } map {
			$self->_epdata_to_json( $_, $depth + 1, 0, %opts )
		} @$epdata ) . "\n$pad\]";
	}
	elsif( ref( $epdata ) eq "HASH" )
	{
		return "$pre_pad\{\n" . join(",\n", map {
			$pad . "  \"" . $_ . "\": " . $self->_epdata_to_json( $epdata->{$_}, $depth + 1, 1, %opts )
		} keys %$epdata) . "\n$pad\}";
	}
	elsif( $epdata->isa( "EPrints::DataObj" ) )
	{
		my $subdata = {};

		return "" if(
			$opts{hide_volatile} &&
			$epdata->isa( "EPrints::DataObj::Document" ) &&
			$epdata->has_relation( undef, "isVolatileVersionOf" )
		  );

		foreach my $field ($epdata->get_dataset->get_fields)
		{
			next if !$field->get_property( "export_as_xml" );
			next if defined $field->{sub_name};
			my $value = $field->get_value( $epdata );
			next if !EPrints::Utils::is_set( $value );
			my $field_name = $field->get_name;
            $field_name = "id" if $field_name eq "eprintid" && $depth == 1;
            $field_name = "description" if $field_name eq "abstract";
            $field_name = "subject" if $field_name eq "subjects";
            $field_name = "identifier_url" if $field_name eq "official_url";
            $field_name = "identifier_number" if $field_name eq "number";          
            $field_name = "status" if $field_name eq "eprint_status";
            $field_name = "record" if $field_name eq "full_text_status";
            $subdata->{$field_name} = $value;
		}

		$subdata->{uri} = $epdata->uri;$subdata->{status} = "200";

		

		return $self->_epdata_to_json( $subdata, $depth + 1, 0, %opts );

	}
}

1;

=head1 COPYRIGHT

=for COPYRIGHT BEGIN

Copyright 2019 University of Southampton.
EPrints 3.4 is supplied by EPrints Services.

http://www.eprints.org/eprints-3.4/

=for COPYRIGHT END

=for LICENSE BEGIN

This file is part of EPrints 3.4 L<http://www.eprints.org/>.

EPrints 3.4 and this file are released under the terms of the
GNU Lesser General Public License version 3 as published by
the Free Software Foundation unless otherwise stated.

EPrints 3.4 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with EPrints 3.4.
If not, see L<http://www.gnu.org/licenses/>.

=for LICENSE END

