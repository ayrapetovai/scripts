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

## cdhist
This script keeps track on `cd` history. Binds `Alt+,` and `Alt+.` to go back and next, requires [bash-preexec](https://raw.githubusercontent.com/rcaloras/bash-preexec), does not work on macOS, uses HISTIGNORE variable. No history polluting. FIXME: make it work on macOS (`Alt+,` gives `≤`).

