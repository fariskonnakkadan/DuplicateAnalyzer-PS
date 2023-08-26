# Duplicate File Finder
The Duplicate File Finder is a Python script that helps you identify and manage duplicate files within a specified folder. It calculates the hash of each file using SHA-256 and detects duplicate files based on their hash values.

### Features
Identifies duplicate files based on their hash values.
Supports multi-threaded processing for improved performance.
Option to delete duplicate files.

### Usage
Open a terminal and execute the script by providing the required information.

`python duplicateAnalyzerPython.py`
### Enter Details
- Enter the folder path where you want to search for duplicate files.
- Specify the file type (e.g., .txt, .jpg) to narrow down the search.
- Choose whether to delete duplicate files (yes/no).
- Enter the number of threads to use for parallel processing.

### Review Results
- If you choose not to delete duplicates, the script will display a list of duplicate files with their hash values.
- If you choose to delete duplicates, the script will delete duplicate files, keeping the first occurrence of each file.

### Dependencies
This script uses Python 3 and the concurrent.futures module for multi-threading.

## Note
Make sure you understand the consequences of deleting files before using the deletion feature.
Use this script responsibly and make necessary backups before deletion.
Feel free to customize the content and layout of the readme.md file according to your preferences and the specific details of your implementation.
This script utilizes Python 3 and the concurrent.futures module for multi-threading. No additional external libraries are required.

Notes
Carefully evaluate the implications of deleting files before utilizing the deletion feature.
Exercise caution and create backups before executing any file deletion.
This script is intended for personal use and should be used responsibly.
