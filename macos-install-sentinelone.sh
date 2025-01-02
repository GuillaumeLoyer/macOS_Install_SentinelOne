#!/usr/bin/env bash

# Exit script as soon as a command fails
set -e

# variables definition
log_folder="/var/log/intune_scripts"
log_file="$log_folder/Sentinel1.log"
mount_path="/private/var/tmp/sentinelone"

# Fonction pour afficher les messages de log
log_message() {
    echo "$(date) | $1" >> "$log_file"
    echo $1
}

# Create log folder
mkdir -m 755 -p $log_folder

log_message "===== starting script SentinelOne ======"

 # Check if Sentinel One Agent is Installed
if [[ -d /Applications/SentinelOne/ ]]; then
    log_message "Sentinel One Agent Installed"
    exit 0
else 
    # Create mount path
    log_message "creating folder '$mount_path' if doesn't exists"
    mkdir -p "$mount_path"
fi

log_message "checking if already mounted at '$mount_path'"
if mount | grep "$mount_path" > /dev/null; then
    log_message "'$mount_path' already mounted"
else
    log_message "mounting AZURE_SERVER_NAME.file.core.windows.net/sentinelone/Sentinel at '$mount_path'"
    mount -t smbfs "smb://STORAGE_ACCOUNT_NAME:KEY@AZURE_SERVER_NAME.file.core.windows.net/sentinelone/Sentinel" "$mount_path" >> $log_file 2>&1

    log_message "mount successful"
fi

log_message "Install SentinelOne Agent"
installer -pkg /private/var/tmp/sentinelone/S1.pkg -target /Applications >> $log_file 2>&1
log_message "SentinelOne Agent installed"

log_message "umouting mount '$mount_path'"
diskutil unmount "$mount_path" >> $log_file 2>&1
