#!/bin/bash

# ====================================================================
#              ⚙️ KONFIGURASI PENTING (HARAP UBAH!)
# ====================================================================

# 1. Lokasi Root Pterodactyl Panel
PTERODACTYL_ROOT="/var/www/pterodactyl"

# 2. Detail Repositori GitHub
GITHUB_USERNAME="VAR_USERNAME_GITHUB_ANDA"
REPO_NAME="pterodactyl-backup-private"
GITHUB_TOKEN="VAR_TOKEN_PAT_GITHUB_ANDA" # GitHub Personal Access Token

# 3. Kredensial Database (Ambil dari file .env Pterodactyl)
DB_HOST="VAR_DB_HOST"
DB_NAME="VAR_DB_DATABASE"
DB_USER="VAR_DB_USERNAME"
DB_PASS="VAR_DB_PASSWORD"

# ====================================================================
#              📂 PENGATURAN LOKAL BACKUP
# ====================================================================

BACKUP_DIR="/root/pterodactyl_backup"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
TAR_FILE="panel_files_${TIMESTAMP}.tar.gz"
SQL_FILE="panel_database_${TIMESTAMP}.sql"
COMMIT_MESSAGE="Panel Backup - ${TIMESTAMP}"

echo "🚀 Memulai proses backup Pterodactyl Panel ke GitHub..."

# --- 1. Persiapan Direktori Backup ---
mkdir -p "$BACKUP_DIR"
cd "$BACKUP_DIR"

# Bersihkan file backup lama di direktori ini
rm -f *.tar.gz *.sql

echo "✅ Direktori backup disiapkan: $BACKUP_DIR"

# --- 2. Kompresi File Panel ---
echo "📦 Mengompres file Pterodactyl..."
# Mengabaikan folder cache dan vendor (akan diinstal ulang oleh composer)
tar -czf "$TAR_FILE" \
    --exclude='vendor' \
    --exclude='node_modules' \
    --exclude='storage/framework/cache' \
    --exclude='storage/logs/*' \
    -C "$(dirname "$PTERODACTYL_ROOT")" "$(basename "$PTERODACTYL_ROOT")"

if [ $? -ne 0 ]; then
    echo "❌ Gagal mengompres file Panel. Menghentikan skrip."
    exit 1
fi
echo "📦 Kompresi file berhasil: $TAR_FILE"

# --- 3. Backup Database ---
echo "💾 Mem-dump database MySQL..."
mysqldump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$SQL_FILE"

if [ $? -ne 0 ]; then
    echo "❌ Gagal mem-dump database. Cek kredensial DB. Menghentikan skrip."
    exit 1
fi
echo "💾 Database dump berhasil: $SQL_FILE"

# --- 4. Inisialisasi Git dan Upload ke GitHub ---
echo "☁️ Memulai upload ke GitHub..."
REMOTE_URL="https://${GITHUB_TOKEN}@github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"

# Hapus folder .git jika ada dan inisialisasi ulang
if [ -d .git ]; then
    rm -rf .git
fi

git init
git remote add origin "$REMOTE_URL" 2>/dev/null || git remote set-url origin "$REMOTE_URL"

git add "$TAR_FILE" "$SQL_FILE"
git commit -m "$COMMIT_MESSAGE"

# Memastikan branch utama adalah 'main' atau 'master'
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$GIT_BRANCH" != "main" ] && [ "$GIT_BRANCH" != "master" ]; then
    git branch -M main
    GIT_BRANCH="main"
fi

# Push ke repositori (gunakan -f untuk menimpa jika perlu, tapi hati-hati)
git push -u origin "$GIT_BRANCH"

if [ $? -ne 0 ]; then
    echo "❌ Gagal mengunggah ke GitHub. Cek Token PAT dan URL Repo."
    echo "URL Repo: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
    exit 1
fi

echo "✅ Backup berhasil diunggah ke repositori pribadi GitHub!"
echo "➡️ Commit: $COMMIT_MESSAGE"
echo "URL Repositori: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"

# --- 5. Bersihkan File Lokal ---
rm -f "$TAR_FILE" "$SQL_FILE"
echo "🗑️ File backup sementara lokal telah dihapus."

