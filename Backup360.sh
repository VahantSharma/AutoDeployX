#!/bin/bash

# Set the log file locations and email settings
# Files store last time status of backup
LOG_FILE="backup_log.txt"
ERROR_LOG_FILE="backup_error_log.txt"
EMAIL_NOTIFICATION="samvanrocks12315@gmail.com"

# Function to log messages with timestamps and log type (INFO or ERROR)
log_message() {
    local message=$1
    local log_type=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    # Write to the appropriate log file based on the type of message (INFO or ERROR)
    if [ "$log_type" == "ERROR" ]; then
        echo "$timestamp - ERROR: $message" >> "$ERROR_LOG_FILE"
    else
        echo "$timestamp - INFO: $message" >> "$LOG_FILE"
    fi
}

# Function to send an email notification (e.g., on success or failure)
send_email_notification() {
    local subject=$1
    local body=$2
    # Send the email with the subject and body
    echo -e "$body" | mail -s "$subject" "$EMAIL_NOTIFICATION"
}

# Function to clean up old backups (older than 7 days)
cleanup_old_backups() {
    local backup_dir=$1
    # Find and delete backups older than 7 days, then log the result
    local removed_files=$(find "$backup_dir" -type f -name "*.tar.gz" -mtime +7 -exec rm -f {} \;)
    
    if [ "$removed_files" ]; then
        log_message "Removed backups older than 7 days in $backup_dir." "INFO"
    else
        log_message "No backups older than 7 days to remove in $backup_dir." "INFO"
    fi
}

# Function to ensure the destination directory exists; if not, create it
createDestDir() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        log_message "Created destination directory: $dir" "INFO"
    fi
}

# Main backup function
backup_files() {
    # reads the source, dest of the backups
    # user interactive coz provides options of file compression & email notification
    read -p "Enter the source directory to back up: " sourceDir
    read -p "Enter the destination directory: " destDir
    read -p "Do you want to compress the backup? (yes/no): " compress
    read -p "Would you like to receive email notifications on success or failure? (yes/no): " emailNotification

    # Redundant check to ensure ki directory exists, else exits 
    if [ ! -d "$sourceDir" ]; then
        log_message "ERROR: Source directory $sourceDir does not exist." "ERROR"
        echo "Source directory does not exist. Exiting."
        send_email_notification "Backup Failed" "Source directory $sourceDir does not exist." && exit 1
    fi

    # Checks DestDir, creates one if not present
    createDestDir "$destDir"

    # backup name generator
    backupNameGenerator=$(basename "$sourceDir")_backup_$(date '+%Y%m%d_%H%M%S')

    if [ "$compress" == "yes" ]; then
        # If user wants compression, create a tar.gz backup
        backup_file="$destDir/$backupNameGenerator.tar.gz"
        tar -czf "$backup_file" -C "$sourceDir" .
        # Check if the backup was successful
        if [ $? -eq 0 ]; then
            log_message "Successfully created compressed backup: $backup_file" "INFO"
            # Send email notification if requested
            [ "$emailNotification" == "yes" ] && send_email_notification "Backup Success" "Backup $backup_file was created successfully."
        else
            log_message "ERROR: Failed to create compressed backup: $backup_file" "ERROR"
            echo "Backup failed. Exiting."
            [ "$emailNotification" == "yes" ] && send_email_notification "Backup Failed" "Failed to create compressed backup $backup_file."
            exit 1
        fi
    else
        # If no compression is selected, just copy the files
        backup_dir="$destDir/$backupNameGenerator"
        cp -r "$sourceDir"/* "$backup_dir"
        # Check if the copying was successful
        if [ $? -eq 0 ]; then
            log_message "Successfully copied files from $sourceDir to $backup_dir" "INFO"
            # Send email notification if requested
            [ "$emailNotification" == "yes" ] && send_email_notification "Backup Success" "Files were copied successfully to $backup_dir."
        else
            log_message "ERROR: Failed to copy files from $sourceDir to $backup_dir" "ERROR"
            echo "Backup failed. Exiting."
            [ "$emailNotification" == "yes" ] && send_email_notification "Backup Failed" "Failed to copy files to $backup_dir."
            exit 1
        fi
    fi

    # Perform cleanup by removing backups older than 7 days
    cleanup_old_backups "$destDir"

    # Final message indicating the operation was successful
    echo "Backup operation completed successfully!"
    log_message "Backup operation completed successfully." "INFO"
    [ "$emailNotification" == "yes" ] && send_email_notification "Backup Success" "Backup completed successfully!"
}

# Run the main backup function
backup_files
