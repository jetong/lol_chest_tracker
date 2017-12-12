#!/bin/bash
set -e

API_KEY=$(cat .api_key.txt)

# for each summoner in lol_data.txt, check if a chest has been consumed and/or awarded.
for LINE in `cat lol_data.txt`; do
  # parse line of data into variables
  IFS=':' read NAME ID DAYS_LEFT HOURS_LEFT MINUTES_LEFT TIMESTAMP OLD_CHESTS AVAILABLE_CHESTS <<< "$LINE"

  ### compare old_chests with current_chests to see if an available chest has been consumed by user (decrement available_chests)
  CURRENT_CHESTS=$(curl -s https://na1.api.riotgames.com/lol/champion-mastery/v3/champion-masteries/by-summoner/$ID?api_key=$API_KEY | jq .[].chestGranted | grep true |wc -l|tr -d "[:blank:]")
  DIFF=$(($CURRENT_CHESTS - $OLD_CHESTS))
  # decrement available_chests if a chest has been obtained by the user
  if [ $DIFF -ne 0 ]; then
    AVAILABLE_CHESTS=$(($AVAILABLE_CHESTS - $DIFF))
    sed "s/^$NAME:.*/$NAME:$ID:$DAYS_LEFT:$HOURS_LEFT:$MINUTES_LEFT:$TIMESTAMP:$OLD_CHESTS:$AVAILABLE_CHESTS/" <lol_data.txt >lol_data_tmp.txt
    mv -f lol_data_tmp.txt lol_data.txt
  fi

  ### if available_chests < 4 && current_date >= next_available_date, then increment available_chests
  if [ $AVAILABLE_CHESTS -lt 4 ]; then
    #determine next available date
    DAYS_LEFT_S=$(($DAYS_LEFT*24*3600))
    HOURS_LEFT_S=$(($HOURS_LEFT*3600))
    MINUTES_LEFT_S=$(($MINUTES_LEFT*60))
    NEXT_AVAILABLE_DATE=$(($TIMESTAMP+$DAYS_LEFT_S+$HOURS_LEFT_S+$MINUTES_LEFT_S))

    CURRENT_DATE=$(date +%s)
    if [ $CURRENT_DATE -ge $NEXT_AVAILABLE_DATE ]; then
      TIMESTAMP=$CURRENT_DATE
      DAYS_LEFT=6
      HOURS_LEFT=23
      MINUTES_LEFT=59
      AVAILABLE_CHESTS=$(($AVAILABLE_CHESTS + 1))
      sed "s/^$NAME:.*/$NAME:$ID:$DAYS_LEFT:$HOURS_LEFT:$MINUTES_LEFT:$TIMESTAMP:$OLD_CHESTS:$AVAILABLE_CHESTS/" <lol_data.txt >lol_data_tmp.txt
      mv -f lol_data_tmp.txt lol_data.txt
    fi
  fi
done
