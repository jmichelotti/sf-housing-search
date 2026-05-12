# Cron Setup for SF Housing Search

## Setting Up the Cron Job

1. Open your crontab for editing:
   ```bash
   crontab -e
   ```

2. Add the following line to run every 6 hours (midnight, 6 AM, noon, 6 PM):
   ```
   0 0,6,12,18 * * * /home/talon/dev/sf-housing-search/run-tracker.sh
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
| Every 6 hours (current) | `0 0,6,12,18 * * *` |
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

## Email Notifications

After each run, `run-tracker.sh` emails the session summary (contents of `tracker-latest.txt`) to `hopkinshousecp@gmail.com` from `sf-housing@thunderheadflix.com` via the Resend API. The new-finds count is surfaced in the subject line (e.g. `SF Housing 2026-05-07 12:00 — 2 new`).

If a run produces no stdout (empty or whitespace-only `tracker-latest.txt`), the script substitutes a `(no output captured from claude run — check tracker-log.txt)` body and tags the subject with `— no output` instead of mailing an empty message. The session prompt also explicitly instructs the agent to finish with a printed Step 6 summary, so silent runs should be rare.

**Required setup on a new machine:**

1. Create a Resend account, add `thunderheadflix.com` (Cloudflare auto-configure handles DNS).
2. Generate an API key restricted to `thunderheadflix.com` sending.
3. Save the key locally with restrictive permissions:
   ```bash
   mkdir -p ~/.config/resend && chmod 700 ~/.config/resend
   echo 'YOUR_KEY' > ~/.config/resend/key
   chmod 600 ~/.config/resend/key
   ```

If the key file is missing, the script logs `[email] missing ~/.config/resend/key — skipping` and continues without failing the run. Email failures are also logged (not fatal) — look for `[email] FAILED status=...` in `tracker-log.txt`.

## Disabling the Job

Comment out or remove the line from `crontab -e`:
```
# 0 */12 * * * /home/talon/dev/sf-housing-search/run-tracker.sh
```
