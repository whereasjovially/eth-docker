#!/bin/bash

echo "USE AT YOUR OWN RISK"
read -p "Are you sure? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

source secrets.env

eth2-val-tools deposit-data \
  --source-min=$ACC_START_INDEX \
  --source-max=$ACC_END_INDEX \
  --amount=$DEPOSIT_AMOUNT \
  --fork-version=$FORK_VERSION \
  --withdrawals-mnemonic="$WITHDRAWALS_MNEMONIC" \
  --validators-mnemonic="$VALIDATORS_MNEMONIC" > $DEPOSIT_DATAS_FILE_LOCATION.txt

eth2-val-tools keystores \
  --source-min=$ACC_START_INDEX \
  --source-max=$ACC_END_INDEX \
  --insecure \
  --source-mnemonic="$VALIDATORS_MNEMONIC"

echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

source secrets.env

if [[ -z "${DEPOSIT_CONTRACT_ADDRESS}" ]]; then
  echo "need DEPOSIT_CONTRACT_ADDRESS environment var"
  exit 1 || return 1
fi


if [[ -z "${ETH1_FROM_ADDR}" ]]; then
  echo "need ETH1_FROM_ADDR environment var"
  exit 1 || return 1
fi
if [[ -z "${ETH1_FROM_PRIV}" ]]; then
  echo "need ETH1_FROM_PRIV environment var"
  exit 1 || return 1
fi

# Iterate through lines, each is a json of the deposit data and some metadata
while read x; do
   # TODO: check validity of deposit before sending it
   account_name="$(echo "$x" | jq '.account')"
   pubkey="$(echo "$x" | jq '.pubkey')"
   echo "Sending deposit for validator $account_name $pubkey"
   ethereal beacon deposit \
      --allow-unknown-contract=$FORCE_DEPOSIT \
      --address="$DEPOSIT_CONTRACT_ADDRESS" \
      --connection=https://holesky.drpc.org \
      --data="$x" \
      --value="$DEPOSIT_ACTUAL_VALUE" \
      --from="$ETH1_FROM_ADDR" \
      --privatekey="$ETH1_FROM_PRIV"
   echo "Sent deposit for validator $account_name $pubkey"
   sleep 2
done < "$DEPOSIT_DATAS_FILE_LOCATION.txt"

cp -r ./assigned_data/{keys,secrets} ./../.eth/validator_keys
./../ethd up

# Timeout duration (in seconds)
# TIMEOUT=60

# Command to run
# COMMAND="./../ethd keys import"

# Run the command with a timeout
# timeout $TIMEOUT $COMMAND

# Check if the command timed out
# if [ $? -eq 124 ]; then
    # echo "The command timed out. Restarting..."
    # You can put the command here to restart if needed
    # $COMMAND
# else
    # echo "Command completed successfully."
# fi