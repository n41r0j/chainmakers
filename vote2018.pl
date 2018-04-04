#!/usr/bin/env perl
use strict;
use warnings;
no warnings 'experimental';
use JSON;
use Data::Dumper;

my $vote2018    = qq{komodo-cli -ac_name=VOTE2018};
# this will return all votes, but does not include source address
# we must go to the raw transactions
my $json        = qx{$vote2018 listunspent 0 999999};
my $votes       = decode_json($json);
my @txids       = ();
my $total_votes = 0.0;
my $CHAINSTRIKE = "RXrQPqU4SwARri1m2n7232TDECvjzXCJh4";
my @CHAINMAKERS = qw/
        RGPido1EWcPWngDfkAcn4M4HXYt8avR4vs
        RSQUoSfM7R7SnatK6Udsb5t39movCpUKQE
/;

# whitelist of addresses, all other addresses are ignored
#my $whitelist   = [ $CHAINSTRIKE ];
my $whitelist   = [ @CHAINMAKERS ];

# addresses that voted for us
my $addresses   = {}; # with amounts
my @addresses   = ();

for my $vote (@$votes) {
    # skip recipient addresses which are not in our whitelist
    my $addr = $vote->{address};
    #print "address=$addr\n";
    if ($vote->{address} ~~ $whitelist) {
        # valid address
    } else {
        #warn "ignored address $addr";
        next;
    }
    #print $vote->{amount} . "\n";

    push @txids, $vote->{txid};

    $total_votes += $vote->{amount};
    #warn Dumper [ $vote ];
}

for my $txid (@txids) {
    my $json = qx{$vote2018 getrawtransaction $txid 1};
    my $tx   = decode_json($json);
    my $vin  = $tx->{vin};

    for my $input (@$vin) {
        #print Dumper [ $input ];
        my $input_txid = $input->{txid};
        my $input_vout = $input->{vout};
        #print "$txid, $input_txid,$input_vout\n";

        # now we must look up this tx with vout index to finally get the address
        my $json = vote2018("getrawtransaction $input_txid 1");
        my $tx2  = decode_json($json);
        #print Dumper [ $tx2 ];
        my $vout = $tx2->{vout};
        #print Dumper [ $vout ];
        if (my $output = $vout->[$input_vout]) {
            #print Dumper [ $output ];
            my $addrs = $output->{scriptPubKey}{addresses};
            for my $a (@$addrs) {
                print "$a\n" unless $addresses->{$a};
                $addresses->{$a} = 1;
            }
        } else {
            warn "no output found! vout=$input_vout";
            #exit;
        }
    }

}

sub vote2018 {
    my ($cmd) = @_;
    #print "running $cmd\n";
    return qx{$vote2018 $cmd};
}

my $num_txids = @txids;
my $num_addrs = (keys %$addresses);
printf "Total votes = %.2f\n", $total_votes;
print "From $num_addrs addresses in $num_txids transactions\n";

