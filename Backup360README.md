# Backup Automation Script Documentation

### Overview

This bash script streamlines file and directory backups with support for compression, logging, and email notifications. It’s designed to simplify the backup process for both novice and experienced users while ensuring reliability and efficiency.

---

### Features
- msmtp used instead of mail coz gmail support krta hai and 2 factor authentication wala auth easy follow ho jata hai. 
- Automated Backups: Effortlessly back up directories to a specified location.
- Compression Support: Create compressed .tar.gz backups for efficient storage.
- Detailed Logging: Maintain separate logs for backup operations (INFO) and errors (ERROR).
- Email Notifications: Stay informed about backup success or failure via email.
- Old Backup Cleanup: Automatically remove backups older than 7 days.
- User-Friendly Interface: Interactive prompts guide users through the backup process.

---

### Prerequisites

- Linux Environment: The script is compatible with Linux systems with bash installed.
- Email Configuration: Install and configure msmtp for Gmail to enable email notifications.
- Basic Permissions: Ensure the script has permission to access source and destination directories.

---

### Installation
- Clone or download the script into your working directory.
- Make the script executable:
```bash 
chmod +x backup_script.sh
```
---

### Usage

- Running the Script
To initiate the script:

```bash
./backup_script.sh
```
### User Prompts
- Source Directory: Directory specify krdeta hai to back up (e.g., /home/user/documents).
- Destination Directory: Specify where the backup should be saved (e.g., /home/user/backups).
- Compression: Choose whether to compress the backup (yes or no). (tar.zip use kr rha hun, gzip uncompress ke liye use kr rha hun)
- Email Notifications: Opt to receive notifications about the backup's status (yes or no).

---

## Core Functionalities

### 1. Logging

The script logs operations and errors with timestamps:

Backup Logs: Recorded in backup_log.txt.
Error Logs: Recorded in backup_error_log.txt.

---

### 2. Email Notifications
T
he script uses msmtp to send email notifications for:

- Backup success.
- Backup failure.
- Notification Format:

Subject: Descriptive status (e.g., "Backup Success" or "Backup Failed").
Body: Detailed information about the operation.


---

### 3. Cleanup of Old Backups
Backups older than 7 days in the destination directory are automatically deleted to optimize storage.

---

### 4. Directory Management
The script ensures the destination directory exists, creating it if necessary.

### 5. Backup Options
Compressed Backup
Files are archived and compressed into .tar.gz.

```bash
Example location: /home/user/backups/documents_backup_20241129_153045.tar.gz.
```
Uncompressed Backup
Files are directly copied to the destination directory.
```bash
Example location: /home/user/backups/documents_backup_20241129_153045/.
```



