#!/bin/bash

# FarmOS Status Check Script
# This script provides a quick overview of the FarmOS installation status

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}       FarmOS Installation Status         ${NC}"
echo -e "${BLUE}==========================================${NC}"
echo ""

# Check Docker containers
echo -e "${YELLOW}Docker Containers:${NC}"
sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep farmos

echo ""

# Check disk usage
echo -e "${YELLOW}Disk Usage:${NC}"
df -h | grep -E "Filesystem|/dev/sda1"

echo ""

# Check memory usage
echo -e "${YELLOW}Memory Usage:${NC}"
free -h | head -2

echo ""

# Check FarmOS accessibility
echo -e "${YELLOW}FarmOS Web Access:${NC}"
if curl -s -o /dev/null -w "%{http_code}" https://farmost11.vps.webdock.cloud | grep -q "200\|302"; then
    echo -e "${GREEN}✓ FarmOS is accessible at https://farmost11.vps.webdock.cloud${NC}"
else
    echo -e "${RED}✗ FarmOS is not accessible${NC}"
fi

echo ""

# Check database status
echo -e "${YELLOW}Database Status:${NC}"
if sudo docker exec farmos-db-1 pg_isready -U farmos_user > /dev/null 2>&1; then
    echo -e "${GREEN}✓ PostgreSQL is running and accepting connections${NC}"
else
    echo -e "${RED}✗ PostgreSQL is not responding${NC}"
fi

echo ""

# Check Redis status
echo -e "${YELLOW}Cache Status:${NC}"
if sudo docker exec farmos-redis-1 redis-cli ping > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Redis cache is operational${NC}"
else
    echo -e "${RED}✗ Redis cache is not responding${NC}"
fi

echo ""

# Check latest backup
echo -e "${YELLOW}Latest Backup:${NC}"
LATEST_BACKUP=$(ls -t /home/admin/farmos/backups/farmos_complete_backup_*.tar.gz 2>/dev/null | head -1)
if [ -n "$LATEST_BACKUP" ]; then
    BACKUP_SIZE=$(du -h "$LATEST_BACKUP" | cut -f1)
    BACKUP_DATE=$(stat -c %y "$LATEST_BACKUP" | cut -d' ' -f1,2 | cut -d'.' -f1)
    echo -e "${GREEN}✓ Latest backup: $(basename $LATEST_BACKUP)${NC}"
    echo -e "  Size: $BACKUP_SIZE"
    echo -e "  Date: $BACKUP_DATE"
else
    echo -e "${YELLOW}⚠ No backups found${NC}"
fi

echo ""

# Check cron jobs
echo -e "${YELLOW}Scheduled Tasks:${NC}"
if crontab -l 2>/dev/null | grep -q "farmos"; then
    echo -e "${GREEN}✓ Cron jobs are configured${NC}"
    crontab -l | grep farmos | while read line; do
        echo "  - $line"
    done
else
    echo -e "${YELLOW}⚠ No cron jobs configured${NC}"
fi

echo ""
echo -e "${BLUE}==========================================${NC}"
echo -e "${GREEN}Status check complete!${NC}"