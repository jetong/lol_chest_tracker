#!/bin/bash
set -e

API_KEY=$(cat .api_key.txt)

for SUMMONER_NAME in `cat lol_accounts.txt`; do
  SUMMONER_ID=$(curl -s https://na1.api.riotgames.com/lol/summoner/v3/summoners/by-name/$SUMMONER_NAME?api_key=$API_KEY | jq .id)

  # get current total number of chests and compare to old total to detect if a chest has been awarded.
  # update available_chests.txt when there is a difference
  CURRENT_CHESTS=$(curl -s https://na1.api.riotgames.com/lol/champion-mastery/v3/champion-masteries/by-summoner/$SUMMONER_ID?api_key=$API_KEY | jq .[].chestGranted | grep true |wc -l|tr -d "[:blank:]")
  OLD_CHESTS=$(grep "^$SUMMONER_NAME:" total_chests.txt | cut -d: -f3)
  DIFF=$((CURRENT_CHESTS-OLD_CHESTS))
  AVAILABLE_CHESTS=$(grep "^$SUMMONER_NAME:" available_chests.txt | cut -d: -f2) 
  AVAILABLE_CHESTS=$(($AVAILABLE_CHESTS - $DIFF))
  if [ $DIFF -ne 0 ]; then
    sed "s/^$SUMMONER_NAME:.*/$SUMMONER_NAME:$AVAILABLE_CHESTS/" <available_chests.txt >available_chests_tmp.txt
    mv -f available_chests_tmp.txt available_chests.txt
  fi
    
  echo "$SUMMONER_NAME:$SUMMONER_ID:$CURRENT_CHESTS" >> total_chests_tmp.txt
done

mv -f total_chests_tmp.txt total_chests.txt


