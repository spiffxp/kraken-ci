#!/bin/bash

if [ ! $# -eq 3 ]
  then
    echo "Invalid / incorrect / missing arguments supplied."
    echo "run <s3 url> <quiet period> <volume to backup or restore>"
    echo
    echo "example:"
    echo "run.sh s3://s3.amazonaws.com/my_bucker/my_directory 60 /var/jenkins_home"
    echo
    echo "This script will first try to restore backup from the given url, and then start backing up to that URL continuously, after every change + quiet period."
    exit 1
fi

if [[   ${AWS_ACCESS_KEY_ID} = "foobar_aws_key_id" || ${AWS_SECRET_ACCESS_KEY} = "foobar_aws_access_key" ]] ; then
    echo "AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables MUST be set"
    exit 1
fi

#
# Replace key and secret in the /.s3cfg file with the one the user provided
#
echo "" >> /.s3cfg
echo "access_key=${AWS_ACCESS_KEY_ID}" >> /.s3cfg
echo "secret_key=${AWS_SECRET_ACCESS_KEY}" >> /.s3cfg

echo "Using $1 as S3 URL"
echo "Using $2 as required quiet (file system inactivity) period before executing backup"
echo "Using $3 as the backup and restore volume"
echo
echo "Updating time data to prevent problems with S3 time mismatch"

inotifywait_events="modify,attrib,move,create,delete"


ntpdate pool.ntp.org

# start by restoring the last backup:
# This could fail if there's nothing to restore.

s3cmd --config=/.s3cfg --rexclude-from=./exclude-regexes --skip-existing sync $1 $3

# Now, start waiting for file system events on this path.
# After an event, wait for a quiet period of N seconds before doing a backup

while inotifywait -r -e $inotifywait_events . ; do
  echo "Change detected."
  while inotifywait -r -t $2 -e $inotifywait_events . ; do
    echo "waiting for quiet period.."
  done
  
  echo "starting backup"
  s3cmd --config=/.s3cfg --rexclude-from=./exclude-regexes --delete-removed sync $3 $1
  echo "done"
done
