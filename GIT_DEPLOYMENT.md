# Git-Based Deployment with cPanel

This guide explains how to deploy your Laravel/Statamic portfolio using cPanel's Git Version Control feature.

## 🎯 Deployment Architecture

```
cPanel Account Structure:
/home/username/
├── laravel_app/              # Laravel application (secure, outside web root)
│   ├── app/, config/, etc.   # Full Laravel/Statamic codebase
│   ├── .env                  # Production environment file
│   └── vendor/               # Composer dependencies
└── public_html/              # Web-accessible directory
    ├── index.php             # Modified Laravel entry point
    ├── static/               # Static cache files
    └── build/                # Compiled assets
```

## 🚀 Initial Setup

### 1. Set Up Git Repository in cPanel
1. Log into cPanel
2. Go to **Git Version Control**
3. Click **Create** to add your repository
4. Enter your repository URL (GitHub/GitLab/etc.)
5. Set **Repository Path** to your account root (e.g., `/home/username/portfolio`)
6. Click **Create** to clone the repository

### 2. Configure Repository Settings
- **Branch**: Set to `main` or your production branch
- **Pull on Deploy**: Enable for automatic updates
- **Auto-deployment**: Optional (you can trigger manually)

## 📦 Deployment Process

### Option 1: Automatic Deployment (Recommended)
When you push changes to your repository:

1. **cPanel Git** automatically pulls latest changes
2. **Post-deployment hook** runs `deployment.sh` script
3. Application is automatically deployed and optimized

### Option 2: Manual Deployment
1. Go to **Git Version Control** in cPanel
2. Click **Pull or Deploy** for your repository
3. Run deployment script manually via SSH:
   ```bash
   cd /home/username/portfolio
   ./deployment.sh
   ```

## 🔧 Configuration Steps

### 1. Environment Configuration
After first deployment, update your production environment:

```bash
# SSH into your server
ssh username@yourserver.com

# Navigate to Laravel app directory
cd /home/username/laravel_app

# Edit production environment
nano .env
```

Update these critical settings:
```env
# Your domain
APP_URL=https://yourdomain.com

# Database (get from cPanel Database section)
DB_HOST=localhost
DB_DATABASE=username_dbname
DB_USERNAME=username_dbuser
DB_PASSWORD=your_db_password

# Redis socket path (check with hosting provider)
REDIS_SCHEME=unix
REDIS_PATH=/tmp/redis.sock

# Memcached socket path (check with hosting provider)
MEMCACHED_HOST=/tmp/memcached.sock
MEMCACHED_PORT=0

# Statamic License (if using Statamic Pro)
STATAMIC_LICENSE_KEY=your_license_key
```

### 2. Database Setup
```bash
# Run initial migration
php artisan migrate

# If you have seeders
php artisan db:seed
```

### 3. Storage Permissions
```bash
# Ensure proper permissions
chmod -R 755 storage bootstrap/cache
chmod 600 .env
```

## 🤖 Automated Deployment with Git Hooks

### Set Up Post-Receive Hook
Create a post-receive hook in your Git repository:

```bash
# In your cPanel File Manager or via SSH
cd /home/username/portfolio/.git/hooks

# Create post-receive hook
nano post-receive
```

Add this content:
```bash
#!/bin/bash
cd /home/username/portfolio
./deployment.sh
```

Make it executable:
```bash
chmod +x post-receive
```

### GitHub Actions Integration (Optional)
If using GitHub, you can set up actions to trigger deployment:

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - name: Deploy to cPanel
      uses: appleboy/ssh-action@v0.1.7
      with:
        host: ${{ secrets.HOST }}
        username: ${{ secrets.USERNAME }}
        password: ${{ secrets.PASSWORD }}
        script: |
          cd /home/username/portfolio
          git pull origin main
          ./deployment.sh
```

## 🔍 Monitoring & Troubleshooting

### Health Check
Visit `https://yourdomain.com/health` to verify:
- Application status
- Cache connections
- Static cache status

### Common Issues

#### 1. Permission Errors
```bash
# Fix storage permissions
find storage -type f -exec chmod 644 {} \;
find storage -type d -exec chmod 755 {} \;
```

#### 2. Cache Issues
```bash
# Clear all caches
php artisan optimize:clear
php artisan statamic:stache:clear
```

#### 3. Static Files Not Loading
Check that assets are properly copied to `public_html`:
```bash
ls -la /home/username/public_html/build/
```

#### 4. Database Connection Issues
Verify database credentials in cPanel:
- Go to **MySQL Databases**
- Check database name, username, and permissions
- Test connection in `.env` file

### Log Files
Monitor application logs:
```bash
# Laravel logs
tail -f /home/username/laravel_app/storage/logs/laravel.log

# cPanel error logs (location varies by hosting provider)
tail -f /home/username/logs/error_log
```

## 🚀 Performance Optimization

### 1. Enable OPcache
Ask your hosting provider to enable PHP OPcache for better performance.

### 2. Static Caching
Ensure static caching is working:
```bash
# Check static cache directory
ls -la /home/username/public_html/static/

# Manually warm cache
php artisan statamic:static:warm
```

### 3. Redis/Memcached
Verify cache connections:
```bash
# Test Redis
php artisan tinker
>>> Cache::store('redis')->put('test', 'working', 60)
>>> Cache::store('redis')->get('test')

# Test Memcached
>>> Cache::store('memcached')->put('test', 'working', 60)
>>> Cache::store('memcached')->get('test')
```

## 🔄 Update Workflow

1. **Develop locally** on feature branch
2. **Test thoroughly** in local environment
3. **Merge to main** branch
4. **Git push** triggers automatic deployment
5. **Verify deployment** via health check endpoint
6. **Monitor logs** for any issues

## 📝 Best Practices

- Always test in staging before deploying to production
- Keep `.env.production` template updated in repository
- Monitor disk space (Statamic content can grow)
- Regular database backups via cPanel
- Keep dependencies updated but test first
- Use semantic versioning for releases

## 🆘 Emergency Rollback

If deployment fails:
```bash
# Via cPanel Git Version Control
1. Go to Git Version Control
2. Select previous working commit
3. Click "Pull or Deploy"
4. Run deployment script

# Via SSH
cd /home/username/portfolio
git reset --hard PREVIOUS_COMMIT_HASH
./deployment.sh
```

Remember to always have a backup strategy and test deployments in staging first!