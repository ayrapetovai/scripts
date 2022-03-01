# scripts

## docker-volume
This script saves content of docker volume to file.tar (BACKUP), and creates volume out of file.tar (RESTORE), created from the volume.  
BACKUP usage:
```shell
docker-volume backup [--path PATH] [VOLUME...]
```
- PATH    - directory for backups, `$PWD` by default.
- VOLUMEs - names of docker volumes to be backed up in folder PATH, all volumes by default

RESTORE usage:  
```shell
docker-volume restore [-f] [FILE...|PATH...]
```
- -f - remove previous volume, prune containers if needed, interactive.
- PATHs - directories of backups, where all `*.tar` files to be restored located.
- FILEs - docker volume backups files `*.tar`, that were created by this script.  