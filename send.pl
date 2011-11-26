#!/usr/bin/perl
#  Copyright (c) 2011 David Caldwell,  All Rights Reserved. -*- cperl -*-
use warnings; use strict; use v5.12;

use List::Util qw(sum);

# Expects dtermd on 10002 ("pure", non-telnet port)
my $host = shift || die "$0 <host> <file> [<another-file> ...]\n";
my $port = 10002;
($host, $port) = ($1,$2) if $host =~ /([^:]+):(\d+)/;

my $remote;

use Socket;
socket($remote, PF_INET, SOCK_STREAM, getprotobyname('tcp')) or die "socket: $!";
connect($remote, sockaddr_in($port, inet_aton($host))) or die "connect: $!";

#print $remote "LIST\r";
use IO::File;
autoflush $remote;
autoflush STDOUT;
sub wait_for_basic { while (read($remote, my $b, 1) == 1) { last if $b eq '?'; } }#print "rejecting '$b'\n" } };

sub die_hard { print $remote chr(3); sleep(1); print $remote "REM @_\n"; die @_ }

for my $filename (@ARGV) {
    open my $file, "<", $filename or die "open $filename: $!";

    print $remote "FILE:$filename\r";

#    wait_for_basic();

    my ($count,$checksum) = (0,0);
    my $start_time = time;

    while (read($file, my $data, 20)) {
        wait_for_basic();
        my @data;
        print $remote join(" ", @data = unpack("C*", $data)), "\r";

        $count += length $data;
        $checksum += sum(@data);

        while (<$remote>) {
            if (/<\s*(\d+)\s*,\s*(\d+)\s*>/) {
                die_hard "bad count $1 != $count" unless $1 == $count;
                die_hard "bad checksum $2 != $checksum" unless $2 == $checksum;
                last;
            }
        }
        printf "\r%s: %d bytes in %d seconds (%d bytes/sec)...", $filename, $count, time - $start_time, $count/(time-$start_time);
    }
    print "Done\n";

    wait_for_basic();
    print $remote "done\r";

    wait_for_basic();
}

print $remote "end\r";
