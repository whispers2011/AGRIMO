# FarmOS Deployment Documentation

## Overview
This document provides comprehensive instructions for deploying FarmOS using Docker on a Webdock VPS, including setup, configuration, backup procedures, and local-to-production deployment strategies.

## System Information
- **Server**: Webdock VPS (KVM Virtual Machine)
- **OS**: Ubuntu 24.04.2 LTS
- **Domain**: farmost11.vps.webdock.cloud
- **SSL**: Let's Encrypt (auto-configured)
- **Stack**: Docker, Nginx (reverse proxy), PostgreSQL, Redis

## Current Installation Details

### Docker Services
- **FarmOS**: Version 3.4.5 (port 8000)
- **PostgreSQL**: Version 13 (internal)
- **Redis**: Version 7 (caching)
- **Nginx**: Reverse proxy with SSL termination

### Directory Structure
```
/home/admin/farmos/
├── docker-compose.yml    # Docker Compose configuration
├── .env                   # Environment variables
├── php.ini               # Custom PHP settings
├── sites/                # FarmOS site files (persistent)
├── private/              # Private file storage
├── config/               # Configuration export/import
├── db-init/              # Database initialization scripts
├── backups/              # Backup storage
├── backup.sh             # Automated backup script
├── restore.sh            # Restoration script
└── DEPLOYMENT.md         # This file
```

## Initial Setup Instructions

### 1. Complete Web Installation
1. Visit: https://farmost11.vps.webdock.cloud
2. Follow the installation wizard:
   - Select "English" as the language
   - Choose "Standard" installation profile
   - Database configuration:
     - Database type: PostgreSQL
     - Database name: `farmos_db`
     - Database username: `farmos_user`
     - Database password: `SecureF@rmPassword2024`
     - Host: `db`
     - Port: `5432` (default)
   - Site configuration:
     - Site name: Your farm name
     - Site email: admin@farmost11.vps.webdock.cloud
     - Admin username: `admin`
     - Admin password: Choose a strong password
     - Admin email: Your email address

### 2. Post-Installation Configuration

#### Enable Required Modules
```bash
# Access the container
sudo docker exec -it farmos-www-1 bash

# Enable recommended modules
drush en farm_map farm_inventory farm_quantity farm_role_roles -y

# Clear cache
drush cr
```

#### Configure Private File System
1. The private files directory is already mounted at `/opt/drupal/private`
2. In FarmOS admin: Configuration → Media → File system
3. Set private file path to: `../private`

#### Configure Cron
```bash
# Add to crontab (run every 6 hours)
crontab -e
0 */6 * * * sudo docker exec -u www-data farmos-www-1 drush cron
```

## Docker Management Commands

### Basic Operations
```bash
# Start FarmOS
cd /home/admin/farmos
sudo docker compose up -d

# Stop FarmOS
sudo docker compose stop

# Restart FarmOS
sudo docker compose restart

# View logs
sudo docker compose logs -f

# View specific service logs
sudo docker compose logs -f www
sudo docker compose logs -f db
```

### Container Access
```bash
# Access FarmOS container
sudo docker exec -it farmos-www-1 bash

# Run Drush commands
sudo docker exec farmos-www-1 drush status
sudo docker exec farmos-www-1 drush cache-rebuild
```

## Backup and Restore Procedures

### Automated Backups
```bash
# Run manual backup
/home/admin/farmos/backup.sh

# Schedule daily backups at 2 AM
crontab -e
0 2 * * * /home/admin/farmos/backup.sh
```

### Restore from Backup
```bash
# Restore from specific backup
/home/admin/farmos/restore.sh /home/admin/farmos/backups/farmos_complete_backup_YYYYMMDD_HHMMSS.tar.gz
```

### Backup Contents
Each backup includes:
- PostgreSQL database dump
- Sites directory (uploaded files, settings)
- Private files directory
- Configuration directory
- Docker Compose and environment files

## Local Development Setup

### 1. Install Docker Locally
- **Windows/Mac**: Install Docker Desktop
- **Linux**: Install Docker and Docker Compose

### 2. Clone Production Configuration
```bash
# Create local directory
mkdir ~/farmos-local
cd ~/farmos-local

# Copy production docker-compose.yml
scp admin@farmost11.vps.webdock.cloud:/home/admin/farmos/docker-compose.yml .

# Modify for local development
sed -i 's/8000:80/8080:80/g' docker-compose.yml
```

### 3. Start Local Instance
```bash
# Start services
docker compose up -d

# Access at http://localhost:8080
```

## Deployment Strategy: Local to Production

### Method 1: Configuration Sync (Recommended)

#### Export from Local
```bash
# Export configuration
docker exec farmos-local-www-1 drush config:export

# Create deployment package
tar -czf farmos-config.tar.gz config/
```

#### Import to Production
```bash
# Upload configuration
scp farmos-config.tar.gz admin@farmost11.vps.webdock.cloud:/home/admin/farmos/

# Extract and import
ssh admin@farmost11.vps.webdock.cloud
cd /home/admin/farmos
tar -xzf farmos-config.tar.gz
sudo docker exec farmos-www-1 drush config:import -y
sudo docker exec farmos-www-1 drush cache:rebuild
```

### Method 2: Database Migration

#### Export Local Database
```bash
# Dump local database
docker exec farmos-local-db-1 pg_dump -U farmos_user -d farmos_db > local_dump.sql
gzip local_dump.sql
```

#### Import to Production
```bash
# Upload database dump
scp local_dump.sql.gz admin@farmost11.vps.webdock.cloud:/tmp/

# Backup production first!
/home/admin/farmos/backup.sh

# Import to production
ssh admin@farmost11.vps.webdock.cloud
gunzip -c /tmp/local_dump.sql.gz | sudo docker exec -i farmos-db-1 psql -U farmos_user -d farmos_db
sudo docker exec farmos-www-1 drush cache:rebuild
```

### Method 3: File Sync

#### Sync Files
```bash
# Sync uploaded files
rsync -avz --delete \
  ~/farmos-local/sites/default/files/ \
  admin@farmost11.vps.webdock.cloud:/home/admin/farmos/sites/default/files/

# Sync private files
rsync -avz --delete \
  ~/farmos-local/private/ \
  admin@farmost11.vps.webdock.cloud:/home/admin/farmos/private/
```

## Continuous Deployment with Git

### Setup Git Repository
```bash
# Initialize git in config directory
cd /home/admin/farmos/config
git init
git add .
git commit -m "Initial configuration"

# Setup remote repository (GitHub, GitLab, etc.)
git remote add origin git@github.com:youruser/farmos-config.git
git push -u origin main
```

### Deploy Changes
```bash
# On production server
cd /home/admin/farmos/config
git pull origin main
sudo docker exec farmos-www-1 drush config:import -y
sudo docker exec farmos-www-1 drush cache:rebuild
```

## Security Best Practices

### 1. Environment Variables
- Change default passwords in `.env` file
- Use strong, unique passwords
- Never commit `.env` to version control

### 2. SSL/TLS
- SSL is already configured via Let's Encrypt
- Auto-renewal is handled by Certbot

### 3. Firewall Rules
```bash
# Ensure only necessary ports are open
sudo ufw status

# Should show:
# 22/tcp (SSH)
# 80/tcp (HTTP - redirects to HTTPS)
# 443/tcp (HTTPS)
```

### 4. Regular Updates
```bash
# Update FarmOS
cd /home/admin/farmos
# Edit docker-compose.yml to use new version
sudo docker compose pull
sudo docker compose up -d

# Update system packages
sudo apt update && sudo apt upgrade
```

## Monitoring and Maintenance

### Health Checks
```bash
# Check container status
sudo docker ps

# Check disk usage
df -h

# Check memory usage
free -h

# Check FarmOS status
sudo docker exec farmos-www-1 drush status
```

### Log Monitoring
```bash
# View Nginx logs
tail -f /var/www/logs/access.log
tail -f /var/www/logs/error.log

# View Docker logs
sudo docker compose logs -f --tail=100
```

### Performance Tuning
1. **PHP Settings**: Edit `/home/admin/farmos/php.ini`
2. **PostgreSQL Tuning**: Add custom postgres.conf if needed
3. **Redis Configuration**: Adjust memory limits in docker-compose.yml

## Troubleshooting

### Common Issues and Solutions

#### 1. Container Won't Start
```bash
# Check logs
sudo docker compose logs www
sudo docker compose logs db

# Restart containers
sudo docker compose down
sudo docker compose up -d
```

#### 2. Database Connection Error
```bash
# Verify database is running
sudo docker exec farmos-db-1 pg_isready

# Check credentials in .env file
cat /home/admin/farmos/.env
```

#### 3. File Permission Issues
```bash
# Fix permissions
sudo chown -R www-data:www-data /home/admin/farmos/sites
sudo chown -R www-data:www-data /home/admin/farmos/private
```

#### 4. Clear Cache Issues
```bash
# Manual cache clear
sudo docker exec farmos-www-1 drush cache:rebuild

# If Drush fails, clear manually
sudo rm -rf /home/admin/farmos/sites/default/files/css/*
sudo rm -rf /home/admin/farmos/sites/default/files/js/*
```

## Support Resources

### Official Documentation
- FarmOS Docs: https://farmos.org/
- FarmOS Forum: https://farmos.discourse.group/
- GitHub: https://github.com/farmOS/farmOS

### Webdock Resources
- Webdock Docs: https://webdock.io/docs
- Support: https://webdock.io/support

### Database Credentials Reference
- **Admin User**: admin
- **Admin Password**: vcGMtMY3RYyT
- **MySQL Database**: farmost11
- **Database User**: farmost11
- **Database Password**: Run5tAJW8FAn
- **PostgreSQL (FarmOS)**:
  - Database: farmos_db
  - User: farmos_user
  - Password: SecureF@rmPassword2024

## Version History
- **2025-09-27**: Initial FarmOS 3.4.5 deployment
- Docker 28.4.0
- Docker Compose v2.38.2
- PostgreSQL 13
- Redis 7-alpine
- Nginx 1.29.0

---
*Last Updated: September 27, 2025*