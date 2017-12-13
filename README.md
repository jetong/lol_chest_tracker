# Track League of Legends Chest Availability

## Requirements
* A Riot API key (https://developer.riotgames.com)
* Install jq to parse json data from RIOT (https://stedolan.github.io/jq/download/)

## Setup
* git clone https://github.com/jetong/lol_chest_tracker.git
* in lol_chest_tracker directory, create file .api_key.txt with your Riot API key inside

## Usage
* Run add_summoner.sh with supplied arguments:
```
./add_summoner.sh summoner_name days hours minutes chests_available
```
where days, hours, and minutes is the amount of time until the next available chest (if hours and minutes are not known, use 0 as the value)

  Example using summoner name faker, 4 days until next available chest, and 2 chests currently available: 
```  
./add_summoner.sh faker 4 0 0 2
```

* After summoners have been added, simply run ./run.sh (ideally as an hourly cron job) to update lol_data.txt.
```
./run.sh
```
* View lol_data.txt for chest availability of each summoner tracked.

Listed in the following format, where the last data value is the number of chests available. [(see sample)](https://github.com/jetong/lol_chest_tracker/blob/master/lol_data.txt)
```
name:id:days:hours:minutes:timestamp:total_chests:chests_available
```
  
## Disclaimer
lol_chest_tracker isn't endorsed by Riot Games and doesn't reflect the views or opinions of Riot Games or anyone officially involved in producing or managing League of Legends. League of Legends and Riot Games are trademarks or registered trademarks of Riot Games, Inc. League of Legends © Riot Games, Inc.
