# Automated Project Bootstrapping

This is my Individual Lab. I wrote `setup_project.sh` to bootstrap the Student Attendance Tracker workspace. The python script, csv, config, and log files were given to us. The shell script creates the folders and files, lets you change the thresholds, checks that python3 is installed, and archives the project if you press Ctrl+C.

## How to run

Make the script executable (only need to do this once):

```
chmod +x setup_project.sh
```

Run it and pass a name. That name is used for the folder:

```
./setup_project.sh yourname
```

This creates `attendance_tracker_yourname` with this structure:

```
attendance_tracker_yourname/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
└── reports/
    └── reports.log
```

The script will ask if you want to change the warning and failure percentages. Default warning is 75 and default failure is 50. Just press Enter to keep the defaults, or type a new number. It uses `sed` to update `Helpers/config.json`.

At the end it does a health check. It runs `python3 --version` and also checks that all the folders and files were created.

## How to trigger the archive

The script has a trap for SIGINT (Ctrl+C).

While the script is still running (for example when it is waiting for you to type the threshold values), press:

```
Ctrl + C
```

What happens:

1. The trap catches the interrupt
2. The project folder is packed into `attendance_tracker_yourname_archive.tar.gz`
3. The original folder is deleted so the workspace stays clean

If you let the script finish normally, nothing gets archived. You have to interrupt it with Ctrl+C.
