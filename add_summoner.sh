#!/bin/bash

# parse argument values into variables
IFS=" " read NAME DAYS_LEFT HOURS_LEFT MINUTES_LEFT AVAILABLE_CHESTS <<< "$@"

API_KEY=$(cat .api_key.txt)
ID=$(curl -s https://na1.api.riotgames.com/lol/summoner/v3/summoners/by-name/$NAME?api_key=$API_KEY | jq .id)
TIMESTAMP=$(date +%s)
OLD_CHESTS=$(curl -s https://na1.api.riotgames.com/lol/champion-mastery/v3/champion-masteries/by-summoner/$ID?api_key=$API_KEY | jq .[].chestGranted | grep true |wc -l|tr -d "[:blank:]")


# Check for valid argument passing
ARG_LENGTH=$#
if [ $ARG_LENGTH -eq 5 ]; then
  if [ $ID != null ]; then
    echo "$NAME:$ID:$DAYS_LEFT:$HOURS_LEFT:$MINUTES_LEFT:$TIMESTAMP:$OLD_CHESTS:$AVAILABLE_CHESTS" >> lol_data.txt
  else
    echo "Invalid summoner name and/or API key"
  fi
else
  echo "Invalid number of argument passed."
  echo "Usage: $0 summoner_name days hours minutes chests_available"
fi

