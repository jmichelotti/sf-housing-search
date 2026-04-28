# Cron Setup for SF Housing Search

## Setting Up the Cron Job

1. Open your crontab for editing:
   ```bash
   crontab -e
   ```

2. Add the following line to run every 12 hours (at midnight and noon):
   ```
   0 */12 * * * /home/talon/dev/sf-housing-search/run-tracker.sh
   ```

3. Save and exit. Verify it was added:
   ```bash
   crontab -l
   ```

## Changing the Frequency

Edit the cron expression to adjust how often the search runs:

| Schedule | Cron Expression |
|----------|----------------|
| Every 12 hours | `0 */12 * * *` |
| Every 6 hours | `0 */6 * * *` |
| Every 4 hours | `0 */4 * * *` |
| Once daily (8 AM) | `0 8 * * *` |
| Twice daily (8 AM, 8 PM) | `0 8,20 * * *` |

## Important: PATH Configuration

Cron runs with a minimal environment. If the `claude` CLI is not on the default PATH, add the full path in `run-tracker.sh` or add a PATH export at the top of your crontab:

```
PATH=/home/talon/.local/bin:/usr/local/bin:/usr/bin:/bin
```

## Verifying It Works

1. Check the log file after a scheduled run:
   ```bash
   tail -100 /home/talon/dev/sf-housing-search/tracker-log.txt
   ```

2. Check if cron ran the job:
   ```bash
   grep -i cron /var/log/syslog | tail -20
   ```

3. Run manually to test:
   ```bash
   /home/talon/dev/sf-housing-search/run-tracker.sh
   ```

## Disabling the Job

Comment out or remove the line from `crontab -e`:
```
# 0 */12 * * * /home/talon/dev/sf-housing-search/run-tracker.sh
```
