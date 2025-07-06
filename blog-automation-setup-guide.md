# E&N Tax Blog Automation Setup Guide

## Step 1: Prepare Your Environment

### Install Python (if not already installed)
1. Download Python 3.10+ from python.org
2. During installation, check "Add Python to PATH"
3. Verify installation: `python --version`

### Install Required Libraries
Open Terminal/Command Prompt and run:
```bash
pip install email imaplib json re datetime
```

## Step 2: Set Up Email Authentication

### For Gmail:
1. Enable 2-factor authentication on your Google account
2. Go to: https://myaccount.google.com/apppasswords
3. Generate an app-specific password for "Mail"
4. Save this password securely

### For Other Email Providers:
- Outlook: Use your regular password or app password if 2FA is enabled
- Yahoo: Generate app password at account security settings
- Custom domain: Use your regular email credentials

## Step 3: Configure the Script

### Create Configuration File
Create a file named `blog_config.json`:

```json
{
  "email_settings": {
    "email_address": "your-email@gmail.com",
    "imap_server": "imap.gmail.com",
    "imap_port": 993
  },
  "blog_settings": {
    "json_path": "/Users/daniel/Documents/AppProjects/EN-Tax-Website/blog-posts.json",
    "default_category": "Tax Planning",
    "default_read_time": "5 min read"
  },
  "parsing_rules": {
    "sender_filter": "chatgpt@openai.com",
    "subject_contains": "Daily Tax Blog",
    "content_markers": {
      "title_start": "Title:",
      "category_start": "Category:",
      "content_start": "Content:",
      "tags_start": "Tags:"
    }
  }
}
```

### Set Environment Variables
For security, store your password as an environment variable:

**On Mac/Linux:**
```bash
export BLOG_EMAIL_PASSWORD="your-app-password"
```

**On Windows:**
```cmd
set BLOG_EMAIL_PASSWORD=your-app-password
```

## Step 4: Test the Script

### Run Manual Test
```bash
python email_blog_processor.py --test
```

This will:
1. Connect to your email
2. Find the most recent blog post email
3. Parse it without marking as read
4. Show you what would be added to blog-posts.json

### Verify Parsing
Check that the script correctly extracts:
- Title
- Category (mapped to your categories)
- Content (formatted as HTML)
- Excerpt (first 150 characters)

## Step 5: Automate the Process

### Option A: Mac (launchd)
Create file: `~/Library/LaunchAgents/com.entax.blogprocessor.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.entax.blogprocessor</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/python3</string>
        <string>/Users/daniel/Documents/AppProjects/EN-Tax-Website/email_blog_processor.py</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>9</integer>
        <key>Minute</key>
        <integer>30</integer>
    </dict>
    <key>EnvironmentVariables</key>
    <dict>
        <key>BLOG_EMAIL_PASSWORD</key>
        <string>your-app-password</string>
    </dict>
</dict>
</plist>
```

Load it:
```bash
launchctl load ~/Library/LaunchAgents/com.entax.blogprocessor.plist
```

### Option B: Windows (Task Scheduler)
1. Open Task Scheduler
2. Create Basic Task
3. Name: "E&N Blog Processor"
4. Trigger: Daily at 9:30 AM
5. Action: Start a program
6. Program: `python.exe`
7. Arguments: `C:\path\to\email_blog_processor.py`

### Option C: Linux (cron)
Add to crontab:
```bash
30 9 * * * BLOG_EMAIL_PASSWORD="your-password" /usr/bin/python3 /path/to/email_blog_processor.py
```

## Step 6: Monitor and Maintain

### Set Up Logging
The script creates logs in `blog_processor.log`:
- Successfully processed posts
- Parsing errors
- Connection issues

### Email Notifications
Configure the script to email you when:
- A post is successfully added
- An error occurs
- No new posts are found (after several days)

### Regular Maintenance
- Check logs weekly
- Update parsing rules if ChatGPT's format changes
- Backup blog-posts.json regularly

## Troubleshooting

### Common Issues:

**"No new emails found"**
- Check sender filter matches exactly
- Verify emails aren't going to spam
- Ensure date/time settings are correct

**"Failed to parse content"**
- Review email format for changes
- Update parsing patterns in config
- Check for special characters

**"Authentication failed"**
- Regenerate app password
- Verify email settings
- Check 2FA is enabled

### Advanced Features to Add:

1. **Image Processing**: If ChatGPT starts including image URLs
2. **Multi-Category Detection**: Automatically assign multiple relevant categories
3. **SEO Optimization**: Auto-generate meta descriptions
4. **Social Media Integration**: Auto-post to Twitter/LinkedIn
5. **Analytics Tracking**: Monitor which posts get featured

## Backup Solution

Always have a manual fallback:
1. Keep blog-manager-final.html accessible
2. Set up email forwarding to a backup processor
3. Maintain a weekly manual check routine

This automation will save you approximately 10-15 minutes per day, or about 60-90 hours per year!
