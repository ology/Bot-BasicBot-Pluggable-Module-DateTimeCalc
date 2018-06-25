package Bot::BasicBot::Pluggable::Module::DateTimeCalc;

# ABSTRACT: Calculate date-time operations

our $VERSION = '0.0301';

use strict;
use warnings;

use base qw(Bot::BasicBot::Pluggable);

use Date::Manip;
use DateTime;
use DateTime::Format::DateParse;

=head1 SYNOPSIS

  use Bot::BasicBot::Pluggable::Module::DateTimeCalc;
  my $bot = Bot::BasicBot::Pluggable::Module::DateTimeCalc->new( nick => 'TimeBot', '...' );
  $bot->run();

=head1 DESCRIPTION

A C<Bot::BasicBot::Pluggable::Module::DateTimeCalc> calculates date-time
operations.

This bot is coded to only respond when directly addressed, btw.

Since this module uses L<Date::Manip>, many different date-time formats are
supported.

=cut

=head1 METHODS

=head2 help()

Show the keyword help text.

=cut

sub help {
    my( $self, $arguments ) = @_;

    $self->say(
        channel => $arguments->{channel},
        body    => 'source|now|localtime $epoch|dow $stamp|diff $stamp $stamp|{add,sub}_{years,months,days,hours,minutes,seconds} $offset $stamp',
    );
}

=head2 said()

Process the date-time calculations.

=cut

sub said {
    my $self      = shift;
    my $arguments = shift;

    my $body = '?';

    my $re = qr/(\S+(?:\s+[\d:]+['"])?)/;

    if ( $arguments->{address} ) {
        # Return the source code link
        if ( $arguments->{body} =~ /^source$/ ) {
            $body = 'https://github.com/ology/Bot-BasicBot-Pluggable-Module-DateTimeCalc';
        }
        # Return the current time
        elsif ( $arguments->{body} =~ /^now$/ ) {
            $body = DateTime->now( time_zone => 'local' );
        }
        # Return the localtime string of a given timestamp
        elsif ( $arguments->{body} =~ /^localtime (\d+)$/ ) {
            $body = scalar localtime $1;
        }
        # Return the day of the week of a given timestamp
        elsif ( $arguments->{body} =~ /^dow $re$/ ) {
            my $capture = _capture($1);

            my $dt = _to_dt($capture);

            $body = $dt->day_name;
        }
        # Return the difference between two given timestamps
        elsif ( $arguments->{body} =~ /^diff $re $re$/ ) {
            my $capture1 = _capture($1);
            my $capture2 = _capture($2);

            my $dt1 = _to_dt($capture1);
            my $dt2 = _to_dt($capture2);

            $body = sprintf '%.2fd or %dh %dm %ds',
                $dt1->delta_ms($dt2)->hours / 24 + $dt1->delta_ms($dt2)->minutes / 1440 + $dt1->delta_ms($dt2)->seconds / 86400,
                $dt1->delta_ms($dt2)->hours,
                $dt1->delta_ms($dt2)->minutes,
                $dt1->delta_ms($dt2)->seconds;
        }
        # Return the addition or subtraction of the given span and offset from the given timestamp
        elsif ( $arguments->{body} =~ /^([a-zA-Z]+)_([a-zA-Z]+) (\d+) $re$/ ) {
            my $method = $1;
            my $span = $2;

            $method = 'subtract' if $method eq 'sub';

            my $capture = _capture($4);

            my $dt = _to_dt($capture);

            $body = $dt->$method( $span => $3 );
        }
        # Exit IRC
        elsif ( $arguments->{body} =~ /^leave$/ ) {
            $self->shutdown( $self->quit_message() );
            exit;
        }

        $self->say(
            channel => $arguments->{channel},
            body    => $body,
        );
    }
}

sub _capture {
    my ($string) = @_;
    $string =~ s/['"]//g;
    return $string;
}

sub _to_dt {
    my($capture) = @_;
    my $format = '%Y-%m-%dT%H:%M:%S';
    my $stamp = UnixDate( $capture, $format );
    my $dt = DateTime::Format::DateParse->parse_datetime($stamp);
    return $dt;
}

=head1 IRC COMMANDS

=head2 source

  > TimeBot: source

Return the github repository where this is hosted.

=head2 now

  > TimeBot: now

Return the current date and time.

=head2 localtime

  > TimeBot: localtime 123456

Return the date-time string given an epoch time.

=head2 dow

  > TimeBot: dow 2018-06-24

Return the day of the week for the given date-time stamp.

=head2 diff

  > TimeBot: diff '2018-06-24 17:51:17' '1/2/2032'

Return a duration string in days, hours, minutes and seconds from two date-time
stamps.

=head2 {add,sub}_{years,months,days,hours,minutes,seconds}

  > TimeBot: add_days 3 '1/2/2032'

Add or subtract the the given span from the given date-time stamp.

=head2 leave

  > TimeBot: leave

Exit the IRC and the running process.

=cut

1;
__END__

=head1 SEE ALSO

L<Bot::BasicBot::Pluggable>

L<Date::Manip>

L<DateTime>

L<DateTime::Format::DateParse>

=cut
