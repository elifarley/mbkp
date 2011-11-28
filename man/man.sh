CMD_BASE="$(readlink -m $0)" || CMD_BASE="$0"; CMD_BASE="$(dirname $CMD_BASE)"
_POD="$0"

_pod2man() {
  pod2man --center="mbkp Manual" --name="mbkp" --release="mbkp 0.1.0" --section=1 "$1"
}

_pod2man "$_POD"

: <<=cut
=pod

=encoding utf8

=head1 NAME

mbkp - Modular Backup tool

=head1 SYNOPSIS

B<mbkp> I<command> I<[option]>... I<[argument]>...

=head1 DESCRIPTION

Modular backup tool. Front end to B<Duplicity>.

=head1 OPTIONS

=head1 COMMANDS

=over 3

=item B<backup>

=item B<mbkp backup> I<[option]>... I<[argument]>...

perform a full or incremental backup

=item B<status>

=item B<mbkp status> I<[option]>... I<[argument]>...

show missing, new and modified files

=item B<list>

=item B<mbkp list> I<[option]>... I<[argument]>...

show all files in backup

=item B<verify>

=item B<mbkp verify> I<[option]>... I<[argument]>...

verify the integrity of the repository

=item B<restore>

=item B<mbkp restore> I<[option]>... I<[argument]>...

restore a backup

=back

=head1 ENVIRONMENT

=head1 FILES

=over 3

=item B<mbkp.conf>

General configuration file.

=back

=head1 NOTES

=head1 BUGS

=head1 EXAMPLE

=head1 AUTHORS

=head1 SEE ALSO

L<duplicity(1)>
=cut
