#!/bin/bash
set -e
cd /var/www/html

# 1) If artisan missing → scaffold into a temp dir then move into /var/www/html
if [ ! -f artisan ]; then
  echo "🌀 Laravel not found. Scaffolding into /var/www/html…"
  TMPDIR=$(mktemp -d)
  composer create-project laravel/laravel "$TMPDIR" --prefer-dist
  shopt -s dotglob
  mv "$TMPDIR"/* .
  rm -rf "$TMPDIR"
  echo "✅ Laravel scaffolded into host/src."
else
  echo "✅ Laravel already present."
fi

# 2) Composer deps
echo "📦 Installing Composer dependencies…"
composer install --no-interaction --prefer-dist --optimize-autoloader

# 3) Permissions
echo "🔒 Fixing permissions…"
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# 4) Migrations & storage link
echo "🧱 Running migrations…"
php artisan migrate --force || echo "⚠️ Migration skipped"
echo "🔗 Ensuring storage link…"
php artisan storage:link || echo "⚠️ Storage link exists"

# 5) Start PHP‑FPM
echo "✅ Bootstrap complete. Starting PHP‑FPM."
exec php-fpm
