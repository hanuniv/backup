#!/bin/bash

# This is the back up script for most important directories

function rsynctodir {
	rsync -av --delete --exclude-from='rsync_ignore' ~ $1 | tee -a "Backup_Log/Backup_Log-`date +'%Y-%m-%d'`"
}

target_dir="SnapShot-`date +'%Y-%m-%d'`"
exist_backups=$(find . -maxdepth 1 -type d | grep -E 'SnapShot-[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}'| sort)
mkdir -p Backup_Log   # make a Log directory if not exist
n=$(echo $exist_backups | wc -w)
if [[ "$n" -ge 1 ]]; then
	echo " ---- After scanning the directory ----"
	if [[ "$n" -eq 1 ]]; then
		echo -e "\t 1 copy of backup exists in the directory:"
	else
		echo -e "\t $n copies of backup exists in the directory:"
	fi
	for i in $exist_backups; do
		echo -e "\t$i"
	done
	lastest_backup=${exist_backups##*\./}
	# if exist back up directory of the same name
	if [[ $lastest_backup == $target_dir ]]; then
		read -p "Seemed  you have backed up today. Update it? [y/x] "
		case $REPLY in
			y|Y )
				rsynctodir $target_dir
			    exit;
			    ;;
			x|X) 
				echo "Exit. No changes made"
				exit
				;;
		esac
	else # no back up directory of the same name
		echo "Options:"
		echo "1. Rename last backup ($lastest_backup) to $target_dir and update"
		echo "2. Backup to new directory $target_dir"
		read -p "Please Select: [1-2] >" 
		case "$REPLY" in
			 1) mv $lastest_backup $target_dir
				rsynctodir $target_dir
				;;
			 2) rsynctodir $target_dir
				;;
		esac
	fi
else
	read -p "No old exist_backups in this directory, backup to directory '$target_dir'? [y/n] > "
	case $REPLY in
		y|Y)
			rsynctodir $target_dir
			;;
		n|N )
			echo "Exit. No changes made"
			exit
			;;
	esac
fi
