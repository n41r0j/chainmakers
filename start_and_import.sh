#!/bin/bash

# to start a local vote2018 full node
komodod -ac_name=VOTE2018 -ac_supply=600000000 -addnode=78.47.196.146 &> vote2018.log &
sleep 3

# import addresses that we want to analyze
# Team ChainStrike
komodo-cli -ac_name=VOTE2018 importaddress RXrQPqU4SwARri1m2n7232TDECvjzXCJh4

# Chainmakers
komodo-cli -ac_name=VOTE2018 importaddress RGPido1EWcPWngDfkAcn4M4HXYt8avR4vs
komodo-cli -ac_name=VOTE2018 importaddress RSQUoSfM7R7SnatK6Udsb5t39movCpUKQE
