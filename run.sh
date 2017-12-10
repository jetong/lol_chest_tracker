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

  if [ $AVAILABLE_CHESTS -lt 4 ]; then
    DAYS_LEFT=$(grep "^$SUMMONER_NAME:" chest_timer.txt | cut -d: -f2)
    HOURS_LEFT=$(grep "^$SUMMONER_NAME:" chest_timer.txt | cut -d: -f3)
    MINUTES_LEFT=$(grep "^$SUMMONER_NAME:" chest_timer.txt | cut -d: -f4)
    SCRIPT_TIMESTAMP=$(grep "^$SUMMONER_NAME:" chest_timer.txt | cut -d: -f5)
    DAYS_LEFT_S=$(($DAYS_LEFT*24*3600))
    HOURS_LEFT_S=$(($HOURS_LEFT*3600))
    MINUTES_LEFT_S=$(($MINUTES_LEFT*60))
    OLD_TIMESTAMP=$(( $((($SCRIPT_TIMESTAMP - $(($(($DAYS_LEFT_S + $HOURS_LEFT_S)) + $MINUTES_LEFT_S))))))) 
    CURRENT_TIMESTAMP=$(($(date +%s)+$((24*3600))))
    DIFF_SECS=$(($CURRENT_TIMESTAMP-$OLD_TIMESTAMP))
    DIFF_DAYS=$(($DIFF_SECS/$((24*3600))))
    CHESTS_ACCRUED=$(($DIFF_DAYS/7))
    echo "$SUMMONER_NAME:chests accrued $CHESTS_ACCRUED:diff secs $DIFF_SECS:diff days $DIFF_DAYS"
  fi
#    sed "s/^$SUMMONER_NAME:.*/$SUMMONER_NAME:$(($AVAILABLE_CHESTS+$CHESTS_ACCRUED))/" <available_chests.txt >available_chests_tmp.txt
#    mv -f available_chests_tmp.txt available_chests.txt

done

mv -f total_chests_tmp.txt total_chests.txt

####################################

  
# when chest counter goes down, 7day stopwatch counts down and awards a chest when it hits 0
# 
