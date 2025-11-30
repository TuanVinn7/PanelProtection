#!/bin/bash

# Path ke Controller Activity
REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Server/ActivityController.php"
BACKUP_PATTERN="${REMOTE_PATH}.bak_*"

echo "🚀 Memulai proses penghapusan proteksi Anti Akses Activity Panel..."

# 1. Cari file backup terbaru berdasarkan pola
LATEST_BACKUP=$(ls -t ${BACKUP_PATTERN} 2>/dev/null | head -n 1)

if [ -z "$LATEST_BACKUP" ]; then
  echo "❌ Error: Tidak ditemukan file backup lama (${BACKUP_PATTERN})."
  echo "❗ Proteksi tidak dapat dihapus secara otomatis. File $REMOTE_PATH mungkin masih mengandung kode proteksi."
  echo "👉 Harap periksa dan kembalikan secara manual ke kode aslinya."
  exit 1
fi

echo "📦 Ditemukan file backup terbaru: $LATEST_BACKUP"

# 2. Hapus file yang terproteksi saat ini
if [ -f "$REMOTE_PATH" ]; then
  rm -f "$REMOTE_PATH"
  echo "🗑️ File yang terproteksi saat ini telah dihapus."
fi

# 3. Kembalikan file backup ke lokasi aslinya
mv "$LATEST_BACKUP" "$REMOTE_PATH"
echo "✅ File asli telah dikembalikan ke $REMOTE_PATH"

# 4. Set ulang izin file (permintaan izin standar Pterodactyl)
chmod 644 "$REMOTE_PATH"

# 5. Opsional: Bersihkan sisa file backup lama (yang bukan yang baru saja dipulihkan)
if ls ${BACKUP_PATTERN} 1> /dev/null 2>&1; then
    echo "🧹 Membersihkan sisa file backup lama..."
    rm -f ${BACKUP_PATTERN}
fi

echo "🎉 Proteksi Anti Akses Activity Panel berhasil dihapus!"
echo "📂 Lokasi file sekarang berisi kode asli."
echo "--------------------------------------------------------"
echo "Untuk menjalankan script ini, gunakan perintah:"
echo "chmod +x remove_activity_protection.sh"
echo "sudo ./remove_activity_protection.sh"

exit 0

