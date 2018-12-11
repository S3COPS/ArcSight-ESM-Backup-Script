# ArcSight-ESM-Backup-Script #
Based on the info from within:
Microfocus ArcSight ESM Software Version: 7.0 Technical Note: CORR-Engine Backup and Recovery - For Compact Mode Only
[https://community.softwaregrp.com/t5/ESM-and-ESM-Express/tkb-p/esm]

**Note: The script applies to ArcSight ESM with CORR-Engine in compact mode only.**

This procedure is for backing up the CORR-Engine and restoring it to the same machine or a new machine that has been set up to look exactly like the original machine.

This does not cover backup and restore of the any connectors installed on this machine. To back up the entire installation in one operation, stop all services and make a copy of /opt/arcsight on another storage medium. Include /etc/hosts and /etc/init.d. This can take a long time, if you have terabytes of data.

**WARNING - this script will stop the ArcSight Manager services, therefore there will be a period where events are not being received and analysts cannot access the Console. The process should take less than 20 minutes in total, but please ensure you dont run this script on a production instance without testing and appropriate Change Control approval.**
you can carry out these backups with the manager services running, but there is no guarantee that the data will be complete when you need to restore it.

**Assumptions:**
- ArcSight is installed in default folder locations (/opt/arcsight/)



**Pre-Requisites:**
- A Backup folder is created in: /opt/arcsight/BACKUPS/


## Script Steps ##
- **Stop services:** shut down all services except the mysqld service and the postgresql service.
- **Back up files:** Backup critical files and folders as defined in the above technical note
- **Export system tables:** Runs the export_system_tables command
- **Back up configuration data:** Runs the configbackup command:
- **Backup the PostgreSQL archive Metadata:**
- **Restarts Services:**
- **Compress the output:** from all the tasks above and tar into a file for export to secure backups / other media

**Note:** All files are copied into the backup file with the same folder paths and attributes wherever possible to allow for prompt restoration / copying.

If you dont want to do certain tasks (i.e. Export System Tables) then comment out the function within the file


## Execution: ##
./arc_full_backup.sh

## Output ##
The script will create a tar.gz file within the /opt/arcsight/BACKUPS folder called "ESM_BACKUP_<DATE>.tar.gz"
 
## Restoring the data ##
This is not part of the script and probably never should be as it will depend on what data you need to restore.
To get the data back in a format ready to restore - as per the current ArcSight Technical Note:
- copy the "ESM_BACKUP_<DATE>.tar.gz" file from storage to /opt/arcsight/BACKUPS
- tar -xzvf ESM_BACKUP_<DATE>.tar.gz
- Copy the files to the relevant locations for restoration.
  
  
  ## No guarantees or support, use at your own risk following suitable testing ##
  ## Caveat Emptor ##
