# ArcSight-ESM-Backup-Script
Based on the info from within:
Microfocus ArcSight ESM Software Version: 7.0 Technical Note: CORR-Engine Backup and Recovery - For Compact Mode Only

**Note: The script applies to ArcSight ESM with CORR-Engine in compact mode only.**

This procedure is for backing up the CORR-Engine and restoring it to the same machine or a new machine that has been set up to look exactly like the original machine.

This does not cover backup and restore of the any connectors installed on this machine. To back up the entire installation in one operation, stop all services and make a copy of /opt/arcsight on another storage medium. Include /etc/hosts and /etc/init.d. This can take a long time, if you have terabytes of data.

##Script Steps##
**Stop services:** shut down all services except the mysqld service and the postgresql service.

**Back up files:** Backup critical files and folders as defined in the above technical note


**Export system tables:** Runs the export_system_tables command


**Back up configuration data:** Runs the configbackup command:


**Backup the PostgreSQL archive Metadata: **


**Restarts Services**


**Compress the output:** from all the tasks above and tar into a file for export to secure backups / other media


Execution:
./arc_full_backup.sh
