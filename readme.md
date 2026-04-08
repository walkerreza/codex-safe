# 🚀 Codex Safe Runner (Antigravity Friendly)

Script PowerShell untuk menjalankan **Codex CLI** tanpa merusak environment **Antigravity / Gemini Code Assist**.

---

## ❗ Masalah yang Diselesaikan

Saat Codex dan Antigravity dipakai bersamaan:

* Codex membuat **Git worktree**
* Antigravity error:

  * `extensions.worktreeconfig`
  * `workspace infos is nil`
* Repo jadi konflik & AI tidak jalan

---

## ✨ Fitur

* ✅ Jalankan Codex dengan aman
* ✅ Auto cleanup worktree Codex
* ✅ Deteksi konflik Git
* ✅ Mode monitor realtime (`watch`)
* ✅ 1 repo (tanpa clone tambahan)
* ✅ Installer 1 command (IRM)
* ✅ Uninstall bersih + self destroy

---

## ⚡ Instalasi (1 Command)

```powershell
irm https://raw.githubusercontent.com/walkerreza/codex-safe/main/codex-safe.ps1 | iex
```

Lalu isi prompt:
contoh

```
file path laragon/www: japanlingo
```

➡️ Otomatis menjadi:
contoh

```
C:\laragon\www\japanlingo
```

---

## 📦 Setelah Install

Tutup PowerShell, lalu buka kembali.

Sekarang tersedia command:

```powershell
codex-safe
```

---

## 🧠 Cara Pakai

### 🔍 Cek repo aman atau tidak

```powershell
codex-safe -Mode check
```

### ▶️ Jalankan Codex + auto cleanup

```powershell
codex-safe -Mode run
```

### 🧹 Bersihkan manual

```powershell
codex-safe -Mode cleanup
```

### 👀 Monitor realtime (anti konflik)

```powershell
codex-safe -Mode watch
```

### ⚙️ Jalankan Codex dengan argumen

```powershell
codex-safe -Mode run -CodexArgs "--help"
```

---

## 🗑️ Uninstall (Self Destroy)

```powershell
codex-safe -Mode uninstall
```

Akan otomatis:

* 🧹 Hapus semua worktree Codex
* 🧹 `git worktree prune`
* 🧹 Hapus `extensions.worktreeconfig`
* 🧹 Hapus folder:

  * `C:\codex-temp`
  * `C:\Users\<user>\.codex`
* 🧹 Hapus alias `codex-safe`
* 💥 Hapus script `codex-safe.ps1` (self destroy)

---

## ⚙️ Cara Kerja

### Mode `run`

* Set `CODEX_HOME = C:\codex-temp`
* Jalankan Codex
* Setelah selesai:

  * Hapus worktree Codex
  * `git worktree prune`
  * Reset config Git
  * Verifikasi repo aman

### Mode `cleanup`

* Hapus semua sisa worktree Codex
* Reset config Git

### Mode `watch`

* Monitor perubahan worktree secara realtime
* Deteksi konflik sebelum terjadi

### Mode `uninstall`

* Full cleanup Codex + repo
* Hapus semua jejak
* Self delete script

---

## ⚠️ Kenapa Ini Penting?

**Codex**:

* Menggunakan Git worktree untuk paralel task

**Antigravity**:

* Tidak kompatibel dengan worktree tertentu

➡️ Tanpa cleanup:

* AI macet
* Repo rusak
* Debugging jadi chaos

---

## 🧠 Best Practice

### ✔️ Do

* Jalankan `codex-safe -Mode run` saat pakai Codex
* Jalankan `check` sebelum buka Antigravity
* Gunakan `watch` jika kerja paralel

### ❌ Don't

* Jangan biarkan worktree Codex aktif terlalu lama
* Jangan pakai 2 AI menulis file bersamaan

---

## 🛠️ Struktur File

```
C:\scripts\codex-safe.ps1
C:\codex-temp\
```

---

## 🔧 Customisasi

Edit file:

```
C:\scripts\codex-safe.ps1
```

Yang bisa diubah:

* Default repo path
* Interval watch
* Filter worktree
* Behavior cleanup

---

## 🧪 Troubleshooting

### Antigravity masih error?

```powershell
git worktree list --porcelain
```

Jika masih ada `.codex/worktrees`:

```powershell
codex-safe -Mode cleanup
```

### Command tidak ditemukan?

```powershell
. $PROFILE
```

### Codex tidak terdeteksi?

```powershell
codex --version
```

---

## 🔥 Filosofi

Menggunakan dua AI sekaligus itu boleh.

**Tapi jangan biarkan mereka berbagi state Git mentah.**

Script ini berfungsi sebagai *"penjaga"* di tengah.

---

## 🏁 License

Free to use, modify, and improve.
