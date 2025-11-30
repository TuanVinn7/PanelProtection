#!/bin/bash

# ==============================================================================
# Script Pemulihan ActivityController.php Pterodactyl
# Script ini mengembalikan file ActivityController.php dari backup terbaru
# yang dibuat oleh script proteksi.
# ==============================================================================

# Path ke Controller Activity
REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Server/ActivityController.php"
BACKUP_PATTERN="${REMOTE_PATH}.bak_*"

echo "--- Pterodactyl Activity Controller Restoration Script ---"
echo "Target file: $REMOTE_PATH"

# 1. Cari file backup terbaru
# ls -t akan mengurutkan berdasarkan waktu modifikasi (terbaru lebih dulu)
LATEST_BACKUP=$(ls -t ${BACKUP_PATTERN} 2>/dev/null | head -n 1)

if [ -z "$LATEST_BACKUP" ]; then
  echo "❌ Error: Tidak ditemukan file backup yang cocok dengan pola (${BACKUP_PATTERN})."
  echo "❗ Proteksi tidak dapat dihapus. Pastikan Anda menjalankan script ini dengan user yang memiliki akses yang benar."
  exit 1
fi

echo "✅ Ditemukan file backup terbaru: $LATEST_BACKUP"

# 2. Hapus file Controller yang terproteksi saat ini (Langkah 3 manual)
if [ -f "$REMOTE_PATH" ]; then
  echo "🗑️ Menghapus file yang terproteksi saat ini ($REMOTE_PATH)..."
  sudo rm -f "$REMOTE_PATH"
fi

# 3. Ganti Nama File Backup (Pemulihan) (Langkah 4 manual)
echo "📦 Mengembalikan file backup ke lokasi asli..."
# Gunakan 'sudo' karena operasi ini kemungkinan memerlukan izin root/sudo
if sudo mv "$LATEST_BACKUP" "$REMOTE_PATH"; then
  echo "🎉 File asli berhasil dikembalikan ke $REMOTE_PATH."
else
  echo "❌ Error: Gagal memindahkan file backup. Cek izin akses."
  exit 1
fi

# 4. Set ulang izin file (Langkah 6 manual)
echo "⚙️ Mengatur ulang izin file..."
sudo chmod 644 "$REMOTE_PATH"

# 5. Opsional: Hapus sisa file backup lama (Langkah 5 manual)
if ls ${BACKUP_PATTERN} 1> /dev/null 2>&1; then
    echo "🧹 Membersihkan sisa file backup lama..."
    sudo rm -f ${BACKUP_PATTERN}
fi

echo ""
echo "========================================================"
echo "✅ Pemulihan selesai! Proteksi telah dihapus."
echo "   Activity Panel seharusnya sudah dapat diakses oleh semua pengguna."
echo "========================================================"

exit 0
