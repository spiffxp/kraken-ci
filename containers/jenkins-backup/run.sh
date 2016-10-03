#!/bin/bash

if [ ! $# -eq 3 ] && [ ! $# -eq 2 ]
  then
    echo "Invalid / incorrect / missing arguments supplied."
    echo "run <s3 url> <quiet period> <volume to backup or restore>"
    echo "or"
    echo "run <s3 url> <volume to backup or restore>"
    echo "example:"
    echo "run.sh s3://s3.amazonaws.com/my_bucker/my_directory 60 /var/jenkins_home"
    echo
    echo "This script will start backing up to that URL continuously, after every change + quiet period."
    echo "example:"
    echo "run.sh s3://s3.amazonaws.com/my_bucker/my_directory /var/jenkins_home"
    echo
    echo "This script will try to restore backup from the given url"
    exit 1
fi


if [ $# -eq 3 ]; then
  echo "Using $1 as S3 URL"
  echo "Using $2 as required quiet (file system inactivity) period before executing backup"
  echo "Using $3 as the backup and restore volume"
fi

if [ $# -eq 2 ]; then
  echo "Using $1 as S3 URL"
  echo "Using $2 as the restore volume"
fi

# start by restoring the last backup:
# This could fail if there's nothing to restore.
if [ $# -eq 2 ]; then
  mkdir -p $2
  s3cmd --config=/.s3cfg --rexclude-from=./exclude-regexes --skip-existing sync $1 $2
else
  mkdir -p $3
  inotifywait_events="modify,attrib,move,create"

  # Now, start waiting for file system events on this path.
  # After an event, wait for a quiet period of N seconds before doing a backup

  while inotifywait -r -e $inotifywait_events $3; do
    echo "Change detected."
    while inotifywait -r -t $2 -e $inotifywait_events $3; do
      echo "waiting for quiet period.."
    done

    echo "starting backup"
    s3cmd --config=/.s3cfg --rexclude-from=./exclude-regexes --no-delete-removed sync $3 $1
    echo "done"
  done
fi
