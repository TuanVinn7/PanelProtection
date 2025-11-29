#!/bin/bash

# Path ke Controller Activity
REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Server/ActivityController.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Anti Akses Activity Panel..."

if [ -f "$REMOTE_PATH" ]; then
  mv "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup file lama dibuat di $BACKUP_PATH"
fi

mkdir -p "$(dirname "$REMOTE_PATH")"
chmod 755 "$(dirname "$REMOTE_PATH")"

cat > "$REMOTE_PATH" << 'EOF'
<?php

namespace Pterodactyl\Http\Controllers\Server;

use Illuminate\View\View;
use Illuminate\Support\Facades\Auth;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Repositories\Eloquent\ActivityRepository;
use Pterodactyl\Models\Server;
use Pterodactyl\Http\Requests\Server\ActivityRequest;

class ActivityController extends Controller
{
    /**
     * ActivityController constructor.
     */
    public function __construct(private ActivityRepository $repository)
    {
    }

    /**
     * Displays a list of recent activity for a given server.
     */
    public function index(ActivityRequest $request, Server $server): View
    {
        // 🔒 Anti akses menu Activity Panel selain user ID 1
        $user = Auth::user();
        if (!$user || $user->id !== 1) {
            abort(403, 'Forbidden');
        }

        return view('server.activity', [
            'server' => $server,
            'activities' => $this->repository->getPaginatedServerActivities(
                $server->id,
                $request->input('page', 1)
            ),
        ]);
    }
}
EOF

chmod 644 "$REMOTE_PATH"

echo "✅ Proteksi Anti Akses Activity Panel berhasil dipasang!"
echo "📂 Lokasi file: $REMOTE_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH (jika sebelumnya ada)"
echo "Forbidden."
