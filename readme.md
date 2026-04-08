🚀 Codex Safe Runner (Antigravity Friendly)

Script PowerShell untuk menjalankan Codex CLI tanpa merusak environment Antigravity / Gemini Code Assist.

Masalah yang diselesaikan:

Codex membuat Git worktree
Antigravity error karena:
extensions.worktreeconfig
workspace infos is nil
Konflik state repo saat dua AI dipakai bersamaan
✨ Fitur
✅ Jalankan Codex dengan aman
✅ Auto cleanup worktree Codex
✅ Deteksi konflik Git (worktree & config)
✅ Mode monitor realtime (watch)
✅ 1 repo, tanpa perlu clone tambahan
✅ Integrasi cepat via codex-safe
⚡ Instalasi (1 command)
irm https://YOUR-URL/install-codex-safe.ps1 | iex

Lalu isi prompt:

file path laragon/www: japanlingo

➡️ otomatis jadi:

C:\laragon\www\japanlingo
📦 Setelah install

Tutup PowerShell, buka lagi.

Sekarang kamu punya command:

codex-safe
🧠 Cara Pakai
🔍 Cek repo aman atau tidak
codex-safe -Mode check
▶️ Jalankan Codex + auto cleanup
codex-safe -Mode run
🧹 Bersihkan manual
codex-safe -Mode cleanup
👀 Monitor realtime (anti konflik)
codex-safe -Mode watch
⚙️ Jalankan dengan argumen Codex
codex-safe -Mode run -CodexArgs "--help"
🧩 Cara Kerja

Script ini:

Jalankan Codex
Deteksi worktree dari:
.codex/worktrees
codex-temp

Hapus worktree:

git worktree remove --force
git worktree prune

Hapus config:

git config --local --unset extensions.worktreeconfig
Verifikasi repo aman untuk Antigravity
⚠️ Kenapa Ini Penting?

Codex:

pakai Git worktree untuk task paralel

Antigravity:

tidak kompatibel dengan worktreeconfig

➡️ hasilnya:

chat macet
agent tidak jalan
error workspace
🧠 Best Practice

✔ Gunakan script ini setiap selesai pakai Codex
✔ Jalankan check sebelum buka Antigravity
✔ Gunakan watch kalau kerja paralel

❌ Jangan biarkan worktree Codex aktif lama
❌ Jangan pakai 2 AI nulis file bersamaan

🛠️ Struktur File
C:\scripts\codex-safe.ps1
C:\codex-temp\
🔧 Customisasi

Edit file:

C:\scripts\codex-safe.ps1

Bisa diubah:

default repo path
interval watch
filtering worktree
behavior cleanup
🧪 Troubleshooting
Codex masih ganggu Antigravity?
git worktree list --porcelain

Kalau ada .codex/worktrees:

codex-safe -Mode cleanup
Command tidak ditemukan?

Restart PowerShell atau jalankan:

. $PROFILE
Codex tidak ditemukan?

Pastikan:

codex --version
🔥 Advanced

Script ini bisa di-upgrade jadi:

auto cleanup realtime
background daemon
multi-repo support
integration MCP bridge
🤝 Konsep Utama

Boleh pakai Codex & Antigravity bareng — tapi jangan share state Git mentah.

Script ini jadi “penjaga” di tengah.

🏁 License

Free to use, modify, and improve.

Kalau kamu mau, gue bisa lanjut:
👉 bikin versi README yang lebih “open-source style” (badge, install script auto publish, dll)
👉 atau langsung gue bantu publish ke GitHub + generate raw URL siap irm 🔥
