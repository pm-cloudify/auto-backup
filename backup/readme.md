# Backup

this is the whole program used to backup from mongo db.

**backup-cli.sh**: this is the script used to run a backup.

### how to use it?

```bash
mv backup-cli.sh /usr/local/bin/mongo-backup
chmod +x /usr/local/bin/mongo-backup
sudo apt install cron
crontab -e
```

then add this cron job:

    0 */12 * * * /usr/local/bin/mongo-backup -u root -p password --db test -t todo > ~/todos-backup.log

it backups every 12 hours.

**Note**: this has security flaws its better to use scheduled pipelines to do backup. utilize github secrets to hold db credentials
