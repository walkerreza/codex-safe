# 🚀 Codex Safe Runner

**Run Codex CLI safely alongside Antigravity / Gemini Code Assist**

PowerShell script untuk menjalankan **Codex CLI tanpa merusak environment Git**, terutama saat dipakai bersamaan dengan Antigravity.

---

## ⚠️ Problem

Saat Codex dan Antigravity dipakai dalam repo yang sama:

* Codex membuat **Git worktree**
* Antigravity tidak kompatibel dengan:

  * `extensions.worktreeconfig`
  * workspace state → `workspace infos is nil`
* Terjadi konflik state repo

### Dampaknya:

* ❌ Chat macet
* ❌ Agent tidak jalan
* ❌ Workspace error

---

## ✨ Features

* ✅ Safe run untuk Codex CLI
* ✅ Auto cleanup worktree Codex
* ✅ Deteksi konflik Git (worktree & config)
* ✅ Realtime monitoring (`watch mode`)
* ✅ Single repo (tanpa clone tambahan)
* ✅ Simple command: `codex-safe`

---

## ⚡ Installation

```powershell
irm https://YOUR-URL/install-codex-safe.ps1 | iex
```

Saat diminta, isi path project:

```
laragon/www: japanlingo
```

➡️ Otomatis menjadi:

```
C:\laragon\www\japanlingo
```

---

## 📦 After Installation

Tutup PowerShell, lalu buka lagi.

Sekarang tersedia command:

```powershell
codex-safe
```

---

## 🧠 Usage

### 🔍 Check repo status

```powershell
codex-safe -Mode check
```

### ▶️ Run Codex (auto cleanup)

```powershell
codex-safe -Mode run
```

### 🧹 Manual cleanup

```powershell
codex-safe -Mode cleanup
```

### 👀 Realtime monitor (anti konflik)

```powershell
codex-safe -Mode watch
```

### ⚙️ Run dengan argumen Codex

```powershell
codex-safe -Mode run -CodexArgs "--help"
```

---

## 🧩 How It Works

Script ini akan:

1. Menjalankan Codex CLI
2. Mendeteksi worktree dari:

   * `.codex/worktrees`
   * `codex-temp`
3. Menghapus worktree:

```powershell
git worktree remove --force
git worktree prune
```

4. Membersihkan config Git:

```powershell
git config --local --unset extensions.worktreeconfig
```

5. Verifikasi repo aman untuk Antigravity

---

## ⚠️ Why This Matters

**Codex** menggunakan Git worktree untuk task paralel.

**Antigravity** tidak kompatibel dengan `worktreeconfig`.

➡️ Tanpa cleanup:

* Workspace bisa rusak
* AI agent gagal jalan
* State repo jadi tidak konsisten

---

## 🧠 Best Practices

### ✔️ Do

* Gunakan script ini setiap selesai pakai Codex
* Jalankan `check` sebelum buka Antigravity
* Gunakan `watch` saat kerja paralel

### ❌ Don't

* Jangan biarkan worktree Codex aktif terlalu lama
* Jangan gunakan 2 AI menulis file bersamaan

---

## 🛠️ File Structure

```
C:\scripts\codex-safe.ps1
C:\codex-temp\
```

---

## 🔧 Customization

Edit file:

```
C:\scripts\codex-safe.ps1
```

Yang bisa diubah:

* Default repo path
* Interval watch
* Filtering worktree
* Behavior cleanup

---

## 🧪 Troubleshooting

### Codex masih ganggu Antigravity?

```powershell
git worktree list --porcelain
```

Jika masih ada `.codex/worktrees`:

```powershell
codex-safe -Mode cleanup
```

---

### Command tidak ditemukan?

Restart PowerShell atau jalankan:

```powershell
. $PROFILE
```

---

### Codex tidak ditemukan?

Pastikan:

```powershell
codex --version
```

---

## 🔥 Advanced Ideas

Script ini bisa dikembangkan menjadi:

* Auto cleanup realtime
* Background daemon
* Multi-repo support
* MCP bridge integration

---

## 🤝 Core Concept

Boleh pakai Codex & Antigravity bersamaan —
**tapi jangan share state Git mentah.**

Script ini berfungsi sebagai *"penjaga"* di tengah.

---

## 🏁 License

Free to use, modify, and improve.

---

## 💡 Next Steps

* Tambahkan GitHub badges
* Publish install script (raw URL)
* Setup CI untuk testing script
