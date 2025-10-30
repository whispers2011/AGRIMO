#!/bin/bash

# FarmOS Cron Setup Script
# This script sets up automated cron jobs for FarmOS maintenance

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Setting up FarmOS cron jobs...${NC}"

# Create a temporary cron file
CRON_FILE="/tmp/farmos_cron_$$"

# Get existing crontab (if any)
crontab -l > "$CRON_FILE" 2>/dev/null || true

# Add FarmOS cron jobs if not already present
if ! grep -q "farmos-www-1 drush cron" "$CRON_FILE"; then
    echo -e "${YELLOW}Adding FarmOS Drupal cron job...${NC}"
    echo "# FarmOS Drupal cron - runs every 6 hours" >> "$CRON_FILE"
    echo "0 */6 * * * sudo docker exec -u www-data farmos-www-1 drush cron > /dev/null 2>&1" >> "$CRON_FILE"
fi

if ! grep -q "/home/admin/farmos/backup.sh" "$CRON_FILE"; then
    echo -e "${YELLOW}Adding FarmOS backup cron job...${NC}"
    echo "# FarmOS daily backup at 2 AM" >> "$CRON_FILE"
    echo "0 2 * * * /home/admin/farmos/backup.sh > /home/admin/farmos/backups/backup.log 2>&1" >> "$CRON_FILE"
fi

# Install the new crontab
crontab "$CRON_FILE"

# Clean up
rm -f "$CRON_FILE"

echo -e "${GREEN}Cron jobs have been configured:${NC}"
echo "1. FarmOS Drupal cron - runs every 6 hours"
echo "2. FarmOS backup - runs daily at 2 AM"
echo ""
echo -e "${GREEN}You can view the cron jobs with: crontab -l${NC}"
echo -e "${GREEN}You can edit the cron jobs with: crontab -e${NC}"