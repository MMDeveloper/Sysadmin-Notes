Find files in /path/to/directory older than 20 days that aren't zip files, gz files, jpg or gif files. Zip them into individual zip files, remove original files

```
find /path/to/directory -type f -mtime +20 \( ! -iname "*.zip" -and ! -iname "*.gz" -and ! -iname "*.jpg" -and ! -iname "*.gif" \) -exec zip -9vj {}.zip {} \; -exec rm -vf {} \;
```