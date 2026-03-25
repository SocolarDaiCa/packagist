#!/bin/sh

# ============================================================
# Docker Bootstrap Script - Permission Setup
# ============================================================
# 1. bootstrap/cache & storage: Read + Write, NO execute
#    - Directories: 777 (need 'x' bit to traverse directories)
#    - Files: 666 (rw-rw-rw-, no execute)
#
# 2. All other files/folders: Read + Execute, NO write
#    - Directories: 555 (r-xr-xr-x)
#    - Files: 555 (r-xr-xr-x)
# ============================================================

APP_DIR="/var/www"

echo "============================================"
echo "Setting permissions for application..."
echo "============================================"

# --- Step 1: Set READ-ONLY + EXECUTE for everything first ---
echo "[1/2] Setting read + execute (no write) for all files and folders..."

# Directories: 555 (r-xr-xr-x) — can list & traverse, but cannot create/modify files
find "$APP_DIR" -type d \
    ! -path "*/storage/*" ! -path "*/storage" \
    ! -path "*/bootstrap/cache/*" ! -path "*/bootstrap/cache" \
    -exec chmod 555 {} +

# Files: 555 (r-xr-xr-x) — can read & execute, but cannot modify
find "$APP_DIR" -type f \
    ! -path "*/storage/*" \
    ! -path "*/bootstrap/cache/*" \
    -exec chmod 555 {} +

# --- Step 2: Set READ + WRITE (no execute) for storage & bootstrap/cache ---
echo "[2/2] Setting read + write (no execute) for storage & bootstrap/cache..."

if [ -d "$APP_DIR/storage" ]; then
    # Directories need 'x' to be traversable, so 777
    find "$APP_DIR/storage" -type d -exec chmod 777 {} +
    # Files: 666 (rw-rw-rw-, no execute)
    find "$APP_DIR/storage" -type f -exec chmod 666 {} +
    echo "  ✓ storage/ — directories: 777, files: 666"
fi

if [ -d "$APP_DIR/bootstrap/cache" ]; then
    # Directories need 'x' to be traversable, so 777
    find "$APP_DIR/bootstrap/cache" -type d -exec chmod 777 {} +
    # Files: 666 (rw-rw-rw-, no execute)
    find "$APP_DIR/bootstrap/cache" -type f -exec chmod 666 {} +
    echo "  ✓ bootstrap/cache/ — directories: 777, files: 666"
fi

echo "============================================"
echo "Permissions set successfully!"
echo "============================================"

# Run the command passed to docker (e.g., the default CMD)
exec "$@"
