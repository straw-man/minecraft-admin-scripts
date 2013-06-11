#!/bin/sh
# /etc/init.d/mcbackup.sh
#
# The following configuration in /etc/crontab will run a minutely backup every fifteen minutes, and a daily backup once a day at 12:05 AM:
# 0,15,30,45 * * * * root /etc/init.d/mcbackup.sh minutely
# 5 0 * * root /etc/init.d/mcbackup.sh daily

# Configuration (no trailing slashes)

# Currently running server's location
SERVERDIRECTORY="/mnt/minecraftfs"
# Minutely backups directory
MINUTELYDIRECTORY="/mnt/syno/minecraft_backups/minutely"
# Daily backups directory
DAILYDIRECTORY="/mnt/syno/minecraft_backups/daily"
# Number of minutely backups to keep
KEEPMINUTELIES=96
# Number of daily backups to keep
KEEPDAILIES=30

case "$1" in
  minutely)
     # Create the current backup
     CURRENTTIME="`date +"%Y-%m-%d-%H:%M"`"
     MINUTELYCOUNT="`ls -l $MINUTELYDIRECTORY | wc -l`"
     mkdir $MINUTELYDIRECTORY/$CURRENTTIME
     cp -r $SERVERDIRECTORY/* $MINUTELYDIRECTORY/$CURRENTTIME

     # Prune oldest minutely backup
     if [ $MINUTELYCOUNT -gt $KEEPMINUTELIES ]
      then
        OLDESTMINUTELY="`ls -1 -t $MINUTELYDIRECTORY | tail -1`"
        rm -rf $MINUTELYDIRECTORY/$OLDESTMINUTELY
     fi
    ;;
  daily)
     # Copy second-oldest minutely backup to dailies to avoid conflict if a minutely is running
     SECONDOLDESTMINUTELY=$(ls -1 -t $MINUTELYDIRECTORY | tail --lines 2 | sed '2d')
     DAILYCOUNT="`ls -l $DAILYDIRECTORY | wc -l`"
     mkdir $DAILYDIRECTORY/$SECONDOLDESTMINUTELY
     cp -r $MINUTELYDIRECTORY/$SECONDOLDESTMINUTELY/* $DAILYDIRECTORY/$SECONDOLDESTMINUTELY

     # Prune oldest daily backup
     if [ $DAILYCOUNT -gt $KEEPDAILIES ]
      then
        OLDESTDAILY="`ls -1 -t $DAILYDIRECTORY | tail -1`"
        rm -rf $DAILYDIRECTORY/$OLDESTDAILY
     fi
    ;;
  *)
    echo "Usage: /etc/init.d/mcbackup.sh {minutely|daily}"
    exit 1
    ;;
esac

exit 0
