# deduplicateFiles
supid and unefficient deduplicate file , generate hash and hardlink file to a folder and locks with admin .
to use in NTFS file systems


- reads input folder recursively /file
- read file and generate hash
- hardlink file to path using the hashes if fail rename file ans try again



