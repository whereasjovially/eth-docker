#!/bin/bash

node init_data.js

# Download staking deposit CLI
curl -L https://github.com/ethereum/staking-deposit-cli/releases/download/v2.8.0/staking_deposit-cli-948d3fc-linux-amd64.tar.gz -o staking-deposit-cli.tar.gz

# Extract the tar.gz file
tar -xvf staking-deposit-cli.tar.gz

# Change directory to the extracted folder
cd staking_deposit-cli-948d3fc-linux-amd64

source ../secrets.env

# run a cmd to generate msg
./deposit generate-bls-to-execution-change  \
  --chain="holesky" \
  --mnemonic="$WITHDRAWALS_MNEMONIC"\
  --validator_start_index=0 \
  --validator_indices="$VALIDATOR_INDICES" \
  --bls_withdrawal_credentials_list="$WITHDRAWALS_CREDENTIALS" \
  --execution_address="$EXECUTION_ADDRESS"