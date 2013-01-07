#!/bin/sh
#script to clean up graphios spooler as File.remove from python doesn't reclaim the disk space of the deleted files

/usr/bin/sudo /sbin/service nagios stop
sleep 20s
/usr/bin/sudo /sbin/service graphios stop
/usr/bin/sudo rm -rf /var/spool/nagios/graphios
/usr/bin/sudo -u nagios mkdir /var/spool/nagios/graphios
/usr/bin/sudo /sbin/service nagios start
/usr/bin/sudo /sbin/service graphios start
