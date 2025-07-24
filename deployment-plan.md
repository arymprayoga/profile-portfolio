# Laravel/Statamic Production Deployment Plan
*Optimized for Shared Hosting with SSH, Redis & Memcached Socket Support*

## 🎯 Project Overview
- **Framework**: Laravel 12.x + Statamic 5.x
- **Hosting**: Shared hosting with SSH access
- **Cache**: Redis & Memcached via sockets
- **Environment**: Production deployment with performance optimization

## 🚀 Hosting Advantages
- ✅ SSH Access (full artisan command support)
- ✅ Redis & Memcached (high-performance caching via sockets)
- ✅ Professional deployment capabilities
- ✅ Can follow Laravel 12.x best practices

---

## Phase 1: Environment & Cache Optimization

### 1.1 Production Environment Configuration
**File**: `.env.production` (template)

```env
# Application
APP_NAME="Ary M Prayoga Portfolio"
APP_ENV=production
APP_KEY=base64:YOUR_PRODUCTION_KEY
APP_DEBUG=false
APP_URL=https://yourdomain.com

# Database
DB_CONNECTION=mysql
DB_HOST=your_db_host
DB_PORT=3306
DB_DATABASE=your_production_db
DB_USERNAME=your_db_user
DB_PASSWORD=your_secure_password

# Cache Configuration
CACHE_STORE=redis
SESSION_DRIVER=memcached
QUEUE_CONNECTION=redis

# Redis Configuration (Socket)
REDIS_CLIENT=phpredis
REDIS_SCHEME=unix
REDIS_PATH=/path/to/redis.sock
REDIS_CACHE_DB=1
REDIS_SESSION_DB=2

# Memcached Configuration (Socket)
MEMCACHED_HOST=/path/to/memcached.sock
MEMCACHED_PORT=0

# Statamic Configuration
STATAMIC_LICENSE_KEY=your_license_key
STATAMIC_PRO_ENABLED=true
STATAMIC_STACHE_WATCHER=false
STATAMIC_STATIC_CACHING_STRATEGY=full
STATAMIC_REVISIONS_ENABLED=false
STATAMIC_GRAPHQL_ENABLED=false
STATAMIC_API_ENABLED=false
STATAMIC_GIT_ENABLED=false

# Performance
DEBUGBAR_ENABLED=false
LOG_LEVEL=error
```

### 1.2 Advanced Caching Strategy
- **Stache Cache**: Redis for Statamic's content index system
- **Static Cache**: Full static caching with Redis persistence
- **Session Cache**: Memcached for session storage
- **Application Cache**: Redis for general Laravel caching

---

## Phase 2: Configuration Files

### 2.1 Redis Socket Configuration
**File**: `config/database.php`

Add to redis configuration:
```php
'redis' => [
    'client' => env('REDIS_CLIENT', 'phpredis'),
    
    'default' => [
        'scheme' => env('REDIS_SCHEME', 'tcp'),
        'path' => env('REDIS_PATH', ''),
        'host' => env('REDIS_HOST', '127.0.0.1'),
        'port' => env('REDIS_PORT', '6379'),
        'database' => env('REDIS_DB', '0'),
    ],

    'cache' => [
        'scheme' => env('REDIS_SCHEME', 'tcp'),
        'path' => env('REDIS_PATH', ''),
        'host' => env('REDIS_HOST', '127.0.0.1'),
        'port' => env('REDIS_PORT', '6379'),
        'database' => env('REDIS_CACHE_DB', '1'),
    ],

    'sessions' => [
        'scheme' => env('REDIS_SCHEME', 'tcp'),
        'path' => env('REDIS_PATH', ''),
        'host' => env('REDIS_HOST', '127.0.0.1'),
        'port' => env('REDIS_PORT', '6379'),
        'database' => env('REDIS_SESSION_DB', '2'),
    ],
],
```

### 2.2 Memcached Socket Configuration
**File**: `config/cache.php`

Update memcached configuration:
```php
'memcached' => [
    'driver' => 'memcached',
    'persistent_id' => env('MEMCACHED_PERSISTENT_ID'),
    'sasl' => [
        env('MEMCACHED_USERNAME'),
        env('MEMCACHED_PASSWORD'),
    ],
    'options' => [
        // Memcached::OPT_CONNECT_TIMEOUT => 2000,
    ],
    'servers' => [
        [
            'host' => env('MEMCACHED_HOST', '127.0.0.1'),
            'port' => env('MEMCACHED_PORT', 11211),
            'weight' => 100,
        ],
    ],
],
```

### 2.3 Statamic Static Caching Configuration
**File**: `config/statamic/static_caching.php`

```php
'strategy' => env('STATAMIC_STATIC_CACHING_STRATEGY', 'full'),

'strategies' => [
    'full' => [
        'driver' => 'file',
        'path' => public_path('static'),
        'lock_hold_length' => 0,
        'permissions' => [
            'directory' => 0755,
            'file' => 0644,
        ],
    ],
],
```

### 2.4 Statamic Stache Configuration
**File**: `config/statamic/stache.php`

```php
'watcher' => env('STATAMIC_STACHE_WATCHER', false), // Disabled for production
'cache_store' => 'redis', // Use Redis for Stache cache
```

---

## Phase 3: Production Optimization Commands

### 3.1 Laravel 12.x Optimization Commands
```bash
# Clear all caches first
php artisan optimize:clear

# Cache configuration files
php artisan config:cache

# Cache routes
php artisan route:cache

# Cache Blade views
php artisan view:cache

# Cache events and listeners
php artisan event:cache

# Optimize everything
php artisan optimize
```

### 3.2 Statamic-Specific Optimization
```bash
# Clear Statamic cache
php artisan statamic:stache:clear

# Rebuild content indexes
php artisan statamic:stache:refresh

# Clear static cache
php artisan statamic:static:clear

# Pre-generate static pages
php artisan statamic:static:warm
```

### 3.3 Composer Optimization
```bash
# Install production dependencies
composer install --optimize-autoloader --no-dev

# Optimize autoloader
composer dump-autoload --optimize
```

### 3.4 Asset Compilation
```bash
# Build production assets
npm run build
```

---

## Phase 4: Deployment Implementation

### 4.1 File Structure Setup
```
/home/username/
├── laravel_app/              # Laravel application (outside public_html)
│   ├── app/
│   ├── config/
│   ├── .env                  # Production environment file
│   └── ...
└── public_html/              # Web-accessible directory
    ├── index.php             # Modified to point to Laravel
    ├── static/               # Static cache directory
    └── assets/               # Compiled assets
```

### 4.2 Modified public/index.php
```php
<?php

use Illuminate\Contracts\Http\Kernel;
use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

// Update these paths to point to your Laravel app directory
require __DIR__.'/../laravel_app/vendor/autoload.php';

$app = require_once __DIR__.'/../laravel_app/bootstrap/app.php';

$kernel = $app->make(Kernel::class);

$response = $kernel->handle(
    $request = Request::capture()
)->send();

$kernel->terminate($request, $response);
```

### 4.3 File Permissions
```bash
# Set proper permissions
chmod -R 755 /path/to/laravel_app
chmod -R 644 /path/to/laravel_app/storage
chmod -R 644 /path/to/laravel_app/bootstrap/cache
chmod 600 /path/to/laravel_app/.env
```

---

## Phase 5: Automated Deployment Script

### 5.1 Create deployment.sh
**File**: `deployment.sh`

```bash
#!/bin/bash

echo "🚀 Starting Laravel/Statamic deployment..."

# Navigate to application directory
cd /path/to/laravel_app

# Pull latest changes
echo "📦 Pulling latest changes..."
git pull origin main

# Install/update dependencies
echo "📋 Installing dependencies..."
composer install --optimize-autoloader --no-dev

# Build assets
echo "🎨 Building assets..."
npm run build

# Run database migrations
echo "🗄️ Running migrations..."
php artisan migrate --force

# Clear and optimize caches
echo "🧹 Clearing caches..."
php artisan optimize:clear

echo "⚡ Optimizing application..."
php artisan optimize

# Statamic optimizations
echo "📚 Optimizing Statamic..."
php artisan statamic:stache:refresh
php artisan statamic:static:warm

# Set permissions
echo "🔒 Setting permissions..."
chmod -R 755 storage bootstrap/cache
chmod 600 .env

echo "✅ Deployment completed successfully!"
```

Make executable:
```bash
chmod +x deployment.sh
```

---

## Phase 6: Monitoring & Health Checks

### 6.1 Health Check Route
Laravel 12.x includes a built-in health check at `/up`

### 6.2 Custom Health Checks
Add to `routes/web.php`:
```php
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'timestamp' => now()->toISOString(),
        'cache' => [
            'redis' => Cache::store('redis')->get('health_check') !== null,
            'memcached' => Cache::store('memcached')->get('health_check') !== null,
        ],
        'static_cache' => file_exists(public_path('static')),
    ]);
});
```

---

## Phase 7: Performance Monitoring

### 7.1 Cache Performance Testing
```bash
# Test Redis connection
php artisan tinker
>>> Cache::store('redis')->put('test', 'working', 60)
>>> Cache::store('redis')->get('test')

# Test Memcached connection  
>>> Cache::store('memcached')->put('test', 'working', 60)
>>> Cache::store('memcached')->get('test')
```

### 7.2 Static Cache Verification
```bash
# Check static cache generation
php artisan statamic:static:warm --queue

# Verify static files
ls -la public_html/static/
```

---

## Expected Performance Improvements

### 🎯 Performance Targets
- **90%+ faster** page loads with static caching
- **Sub-second** response times for cached content
- **Reduced server load** with optimized caching layers
- **Improved SEO** with faster load times

### 📊 Cache Benefits
- **Redis**: Persistent, fast key-value storage
- **Memcached**: High-performance session storage
- **Static Cache**: Pre-generated HTML files
- **Stache**: Optimized content indexing

---

## Security Checklist

### 🔒 Production Security
- [ ] `.env` file outside web root
- [ ] `APP_DEBUG=false` in production
- [ ] Proper file permissions (755/644)
- [ ] SSL/TLS certificate installed
- [ ] Security headers configured
- [ ] Database credentials secured
- [ ] Cache connections secured

---

## Maintenance & Updates

### 🔄 Regular Maintenance
```bash
# Weekly cache refresh
php artisan statamic:stache:refresh
php artisan statamic:static:warm

# Monthly optimization
php artisan optimize:clear
php artisan optimize

# Monitor logs
tail -f storage/logs/laravel.log
```

### 📋 Update Checklist
1. Test in staging environment
2. Backup database and files
3. Run deployment script
4. Verify functionality
5. Monitor performance
6. Rollback if issues occur

---

## Troubleshooting

### Common Issues
1. **Cache Connection Errors**: Verify socket paths
2. **Permission Issues**: Check file ownership
3. **Static Cache Not Working**: Verify web server config
4. **Performance Degradation**: Check cache hit rates

### Debug Commands
```bash
# Check cache status
php artisan cache:table

# Debug Statamic cache
php artisan statamic:stache:doctor

# Clear all caches
php artisan optimize:clear
```

---

## Next Steps

1. **Review Configuration Files**: Ensure all paths and credentials are correct
2. **Test in Staging**: Replicate production environment locally
3. **Create Backups**: Database and file system backups
4. **Monitor Performance**: Set up monitoring and alerting
5. **Security Audit**: Review security configurations
6. **Documentation**: Keep deployment docs updated

---

*This deployment plan is optimized for Laravel 12.x + Statamic 5.x on shared hosting with SSH, Redis, and Memcached support. Follow the phases sequentially for best results.*