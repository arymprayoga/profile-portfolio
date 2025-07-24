#!/bin/bash

echo "🚀 Starting Laravel/Statamic deployment via Git..."

# Exit on any error
set -e

# Configuration
REPO_DIR="${PWD}"
PUBLIC_HTML_DIR="/home/$(whoami)/public_html"
LARAVEL_APP_DIR="/home/$(whoami)/laravel_app"

echo "📁 Current directory: ${REPO_DIR}"
echo "📁 Laravel app directory: ${LARAVEL_APP_DIR}"
echo "📁 Public HTML directory: ${PUBLIC_HTML_DIR}"

# Ensure we're in the Git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a Git repository. Run this script from your project root."
    exit 1
fi

# Pull latest changes (cPanel Git will handle this automatically)
echo "📦 Git repository updated via cPanel Git Version Control"

# Copy application files to Laravel app directory (outside public_html)
echo "📋 Copying application files..."
rsync -av --exclude='.git' --exclude='node_modules' --exclude='public_html' "${REPO_DIR}/" "${LARAVEL_APP_DIR}/"

# Install/update dependencies
echo "📦 Installing Composer dependencies..."
cd "${LARAVEL_APP_DIR}"
composer install --optimize-autoloader --no-dev --no-interaction

# Install Node.js dependencies if package.json exists
if [ -f "package.json" ]; then
    echo "📦 Installing Node.js dependencies..."
    npm ci --production
fi

# Build assets
echo "🎨 Building production assets..."
npm run build

# Copy public assets to public_html
echo "📁 Copying public assets to public_html..."
rsync -av "${LARAVEL_APP_DIR}/public/" "${PUBLIC_HTML_DIR}/"

# Copy production index.php if it exists
if [ -f "${LARAVEL_APP_DIR}/public/index.production.php" ]; then
    echo "📄 Using production index.php..."
    cp "${LARAVEL_APP_DIR}/public/index.production.php" "${PUBLIC_HTML_DIR}/index.php"
    
    # Update paths in index.php to match actual directory structure
    sed -i "s|laravel_app|$(basename ${LARAVEL_APP_DIR})|g" "${PUBLIC_HTML_DIR}/index.php"
fi

# Set up environment file
if [ -f "${LARAVEL_APP_DIR}/.env.production" ] && [ ! -f "${LARAVEL_APP_DIR}/.env" ]; then
    echo "🔧 Setting up production environment..."
    cp "${LARAVEL_APP_DIR}/.env.production" "${LARAVEL_APP_DIR}/.env"
    echo "⚠️  Remember to update .env with your actual database and cache socket paths!"
fi

# Run database migrations
if [ -f "${LARAVEL_APP_DIR}/.env" ]; then
    echo "🗄️ Running database migrations..."
    php artisan migrate --force
else
    echo "⚠️  Skipping migrations - .env file not found"
fi

# Clear and optimize caches
echo "🧹 Clearing all caches..."
php artisan optimize:clear

echo "⚡ Optimizing application..."
php artisan optimize

# Statamic optimizations
echo "📚 Optimizing Statamic..."
php artisan statamic:stache:clear
php artisan statamic:stache:refresh

# Pre-generate static cache if enabled
if grep -q "STATAMIC_STATIC_CACHING_STRATEGY=full" "${LARAVEL_APP_DIR}/.env" 2>/dev/null; then
    echo "🔥 Pre-generating static cache..."
    php artisan statamic:static:warm
fi

# Set proper permissions
echo "🔒 Setting file permissions..."
find "${LARAVEL_APP_DIR}/storage" -type f -exec chmod 644 {} \;
find "${LARAVEL_APP_DIR}/storage" -type d -exec chmod 755 {} \;
find "${LARAVEL_APP_DIR}/bootstrap/cache" -type f -exec chmod 644 {} \;
find "${LARAVEL_APP_DIR}/bootstrap/cache" -type d -exec chmod 755 {} \;

if [ -f "${LARAVEL_APP_DIR}/.env" ]; then
    chmod 600 "${LARAVEL_APP_DIR}/.env"
fi

# Create static cache directory if it doesn't exist
mkdir -p "${PUBLIC_HTML_DIR}/static"
chmod 755 "${PUBLIC_HTML_DIR}/static"

echo "✅ Git-based deployment completed successfully!"
echo ""
echo "📝 Next steps:"
echo "1. Update ${LARAVEL_APP_DIR}/.env with your production settings"
echo "2. Configure Redis/Memcached socket paths in .env"
echo "3. Test the site at your domain"
echo "4. Check /health endpoint for system status"