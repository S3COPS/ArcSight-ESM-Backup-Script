#!/bin/bash
#
#############################################################################################################
# Name: ArcSight ESM Full System Backup script
# Author: S3COPS
# Source location: https://github.com/S3COPS/ArcSight-ESM-Backup-Script
# Version: 0.1 (Alpha)
# Supported OS Version(s): RHEL / CENTOS 7.x
# Supported ArcSight ESM Version: Tested on ESM 7.0
#
# Based on guidance within Technical Note: CORR-Engine Backup and Recovery
#
#############################################################################################################
#
### Set Globals
#
WHO="$(whoami)"; # get the name of the user executing this script
BKPFOLDER=/opt/arcsight/BACKUPS/ESM_BACKUP_`date "+%Y-%m-%d"`/
BKPFILE=ESM_BACKUP_`date "+%Y-%m-%d"`
LOGFILE="/opt/arcsight/BACKUPS/arc_backup_log.txt"; # define the log file
#
#
### Worker Functions
function arcLog(){
# Logging function
    arcTimeStamp="$(date)" # Full timestamp Format: (OS DEFAULT)
	touch $LOGFILE
	\cp /dev/null $LOGFILE # Start the log fresh - this could be removed and set to append and logrotate configured to manage the file
	echo -e "\n" >> $LOGFILE
	echo '==============================================================================================' >> $LOGFILE
    echo -e "$arcTimeStamp" 'Commencing ArcSight ESM Backup' >> $LOGFILE # Append entry to the log
}
#
#
function setFolder(){
# Set the backup folder - this will expect the backup to be run no more than daily - change as required
mkdir -p /opt/arcsight/BACKUPS/ESM_BACKUP_`date "+%Y-%m-%d"`
clear
echo -e "\n"
echo '=============================================================================================='
echo -e "\n"
echo 'Files will be backed up to the following folder:'
echo $BKPFOLDER
echo -e "\n"
echo '=============================================================================================='
echo -e $arcTimeStamp 'ArcSight Backup Folder set ' $BKPFOLDER >> $LOGFILE # Append entry to the log
sleep 5s
}
#
#
function setPass(){
# Enter CORR-Engine Password - this can be embedded in the script - but that would be bad practice!.
clear
echo -e "\n"
echo '=============================================================================================='
echo -e "\n"
echo 'Enter CORR-Engine Password'
echo 'Take care to ensure you enter the details correctly.....'
echo -e "\n"
echo '=============================================================================================='
echo -e "\n"
echo 'Enter the CORR-Engine Password .....'
read -p 'Password: ' CORRE_PASS
# this has set variable: $CORRE_PASS
echo -e $arcTimeStamp 'CORR-Engine Password Entered ' >> $LOGFILE # Append entry to the log
sleep 5s
}
#
#
function stopServices(){
# Stop ArcSight Services, with the exception of mysqld and PostGreSQL
	echo '=============================================================================================='
	echo 'Stopping ArcSight Manager and Logger Services'
	echo 'This process may take 5 - 10 minutes'
	echo '=============================================================================================='
	sleep 2s
/etc/init.d/arcsight_services stop manager
/etc/init.d/arcsight_services stop logger_web
/etc/init.d/arcsight_services stop logger_httpd
/etc/init.d/arcsight_services stop logger_servers
/etc/init.d/arcsight_services stop execprocsvc
/etc/init.d/arcsight_services stop aps
echo -e $arcTimeStamp 'All ArcSight Manager and Logger Services have been stopped ' >> $LOGFILE # Append entry to the log
sleep 1m
}
#
#
function fileBackup(){
# Backup key files as listed within Technical Note: CORR-Engine Backup and Recovery
	echo '=============================================================================================='
	echo 'Copying key OS and ArcSight Application files.....'
	echo -e $arcTimeStamp 'Copying key OS and ArcSight Application files..... ' >> $LOGFILE # Append entry to the log
	echo '=============================================================================================='
	sleep 2s
cp --parents -pf /home/arcsight/.bash_profile $BKPFOLDER
cp --parents -pf /opt/arcsight/logger/data/mysql/my.cnf $BKPFOLDER
cp --parents -pf /etc/hosts $BKPFOLDER
cp --parents -pf /opt/arcsight/manager/config/server.properties $BKPFOLDER
cp --parents -pf /opt/arcsight/manager/config/database.properties $BKPFOLDER
cp --parents -pf /opt/arcsight/logger/current/arcsight/logger/user/logger/logger.properties $BKPFOLDER
cp --parents -pf /opt/arcsight/manager/config/server.wrapper.conf $BKPFOLDER
cp --parents -Rpf /opt/arcsight/manager/config/jetty $BKPFOLDER
cp --parents -pf /opt/arcsight/manager/jre/lib/security/cacerts $BKPFOLDER
cp --parents -pf /opt/arcsight/manager/user/manager/license/arcsight.lic $BKPFOLDER
cp --parents -pf /opt/arcsight/manager/config/keystore* $BKPFOLDER
echo -e $arcTimeStamp 'Copying key OS and ArcSight Application files complete ' >> $LOGFILE # Append entry to the log
sleep 5s
}
#
#
function configBackup(){
# Backup ArcSight Configuration
	echo '=============================================================================================='
	echo 'Carrying out ArcSight Configuration Backup.....'
	echo -e $arcTimeStamp 'Carrying out ArcSight Configuration Backup..... ' >> $LOGFILE # Append entry to the log
	echo '=============================================================================================='
	sleep 2s
/opt/arcsight/logger/current/arcsight/logger/bin/arcsight configbackup
cp --parents -pf /opt/arcsight/logger/current/arcsight/logger/tmp/configs/configs.tar.gz $BKPFOLDER
rm -f /opt/arcsight/logger/current/arcsight/logger/tmp/configs/configs.tar.gz
echo -e $arcTimeStamp 'ArcSight Configuration Backup Complete ' >> $LOGFILE # Append entry to the log
sleep 5s
}
#
#
function exportSystem(){
# Export ArcSight System Tables
# This will be executed as the ArcSight User
	echo '=============================================================================================='
	echo 'Exporting ArcSight System Tables.....'
	echo -e $arcTimeStamp 'Exporting ArcSight System Tables..... ' >> $LOGFILE # Append entry to the log
	echo '=============================================================================================='
	sleep 2s
sudo su -c "/opt/arcsight/manager/bin/arcsight export_system_tables arcsight $CORRE_PASS arcsight –s" arcsight
sudo su -c "gzip /opt/arcsight/manager/tmp/arcsight_dump_system_tables.sql" arcsight
cp --parents -pf /opt/arcsight/manager/tmp/arcsight_dump_system_tables.sql.gz $BKPFOLDER
rm -f /opt/arcsight/manager/tmp/arcsight_dump_system_tables.sql.gz
echo -e $arcTimeStamp 'Exporting ArcSight System Tables Complete ' >> $LOGFILE # Append entry to the log
sleep 5s
}
#
#
function exportPostgresMeta(){
# Export PostGreSQL Archives Metadata
	echo '=============================================================================================='
	echo 'Exporting PostGreSQL Archives Metadata.....'
	echo -e $arcTimeStamp 'Exporting PostGreSQL Archives Metadata..... ' >> $LOGFILE # Append entry to the log
	echo '=============================================================================================='
	sleep 2s
/opt/arcsight/logger/current/arcsight/bin/pg_dump -d rwdb -c -n data -U web |gzip -9 -v > $BKPFOLDER'postgres_data.sql.gz'
echo -e $arcTimeStamp 'PostGreSQL Archives Metadata Complete ' >> $LOGFILE # Append entry to the log
sleep 5s
}
#
#
function startServices(){
# Start all ArcSight Services
	echo '=============================================================================================='
	echo 'Restarting ArcSight Services'
	echo -e $arcTimeStamp 'Restarting ArcSight Services..... ' >> $LOGFILE # Append entry to the log
	echo '=============================================================================================='
	/etc/init.d/arcsight_services start all
	echo "ArcSight Services Starting"
	echo -e 'The ArcSight Services may take up to 10 minutes to restart'
	sleep 5m
# first pass at checking manager service is running - 4 attempts over a 20 minute window will be made before the script will exit
	echo -e 'Confirming ArcSight Manager services are available'
		if sudo su -c "/opt/arcsight/manager/bin/arcsight managerup" arcsight |grep -q "Manager is running.";
		then 
		echo "$(date) | ArcSight Manager Service has succesfully restarted"
		else
		sleep 5m
		echo -e 'Confirming ArcSight Manager services are available'
			if sudo su -c "/opt/arcsight/manager/bin/arcsight managerup" arcsight |grep -q "Manager is running.";
			then 
			echo "$(date) | ArcSight Manager Service has succesfully restarted"
			else
			sleep 5m
			echo -e 'Confirming ArcSight Manager services are available'
					if sudo su -c "/opt/arcsight/manager/bin/arcsight managerup" arcsight |grep -q "Manager is running.";
					then 
					echo "$(date) | ArcSight Manager Service has succesfully restarted"
					else
					sleep 5m
					echo -e 'Confirming ArcSight Manager services are available'
						if sudo su -c "/opt/arcsight/manager/bin/arcsight managerup" arcsight |grep -q "Manager is running.";
						then 
						echo "$(date) | ArcSight Manager Service has succesfully restarted"
						else
						echo "ArcSight Manager Service has failed to restart, check service status on completion of this script"
						fi
					fi
			fi
		fi
	echo -e "\n"
	echo '=============================================================================================='
echo -e $arcTimeStamp 'Restarting ArcSight Services Complete ' >> $LOGFILE # Append entry to the log
}
#
#
function zipUp(){
# Archive the backup folder ready for copy to backup location
	echo '=============================================================================================='
	echo 'Creating ArcSight ESM Configuration Backup file.....'
	echo -e $arcTimeStamp 'Creating ArcSight ESM Configuration Backup file..... ' >> $LOGFILE # Append entry to the log
	echo '=============================================================================================='
	sleep 2s
cd /opt/arcsight/BACKUPS
tar -zcvf $BKPFILE.tar.gz $BKPFILE
rm -rf $BKPFOLDER
	echo '=============================================================================================='
	echo 'ArcSight Configuration Backup file created'
	echo $BKPFILE'.tar.gz'
	echo 'Copy this file to a secure location for backup purposes'
	echo '=============================================================================================='
	echo -e $arcTimeStamp 'ArcSight Configuration Backup file '$BKPFILE'.tar.gz created ' >> $LOGFILE # Append entry to the log
	echo -e $arcTimeStamp 'Copy this file to a secure location for backup purposes ' >> $LOGFILE # Append entry to the log
	sleep 2s
}
#
#
function arcAbort(){
# What to do if we fail a function
    echo "$(date +"%T") | Backup failed [FATAL]" >> $LOGFILE;
    echo "$(date +"%T") | FAIL at $1";
    exit;
}
#
#
### Start
# This is the first part of the script to be executed and controls the firing of all of the functions above
# Each function will fire in sequence but will trigger an abort function if it fails for any reason
if [ $UID == 0 ] 
then 
    clear;
	echo '=============================================================================================='
	echo '==============================================================================================';
    echo -e "\n\n\n ArcSight ESM Full System Backup Script\n\n\n";
	echo '==============================================================================================';
	echo '=============================================================================================='
	echo -e "\n\n"
	arcLog || arcAbort "arcLog"
	setFolder || arcAbort "setFolder"	
	setPass || arcAbort "setPass"
	stopServices || arcAbort "stopServices"
	fileBackup || arcAbort "fileBackup"
	configBackup || arcAbort "configBackup"
	exportSystem || arcAbort "exportSystem"
	exportPostgresMeta || arcAbort "exportPostgresMeta"
	startServices || arcAbort "startServices"
	zipUp || arcAbort "zipUp"
	echo "$(date +"%T") | Backup complete; see log for details";
	echo -e $arcTimeStamp 'Backup Complete'\n\n >> $LOGFILE # Append entry to the log
	echo '==============================================================================================' >> $LOGFILE	
else
    echo "This script needs to be run as the root user";
	echo -e $arcTimeStamp 'This script needs to be run as the root user ' >> $LOGFILE # Append entry to the log
	exit;
fi
