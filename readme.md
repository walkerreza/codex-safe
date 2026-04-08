# 🚀Codex Safe Runner – Fix Git Worktree Conflict with Antigravity & Gemini Code Assist

PowerShell utility untuk mengisolasi eksekusi **Codex CLI** dari state Git utama, sehingga tetap kompatibel dengan **Antigravity / Gemini Code Assist** dalam satu repository.

---

![PowerShell](https://img.shields.io/badge/Powershell-Script-blue)
![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey)
![Status](https://img.shields.io/badge/Status-Stable-green)
![Git](https://img.shields.io/badge/Git-Worktree%20Fix-orange)

## ❗ Problem Statement

Ketika Codex dan Antigravity digunakan secara bersamaan dalam satu repository:

* Codex membuat **Git worktree** untuk eksekusi paralel
* Antigravity tidak kompatibel dengan konfigurasi tersebut, terutama:

  * `extensions.worktreeconfig`
  * kondisi workspace: `workspace infos is nil`
* Terjadi inkonsistensi state repository

### Dampak

* Proses agent gagal berjalan
* Workspace tidak dapat di-load
* Konflik state Git (non-deterministic behavior)

---

## ✨ Features

* Isolated execution untuk Codex CLI
* Automatic cleanup untuk seluruh worktree yang dibuat Codex
* Deteksi dan remediasi konflik konfigurasi Git
* Realtime monitoring terhadap perubahan worktree (`watch mode`)
* Single-repo workflow (tanpa cloning tambahan)
* One-command installer (IRM)
* Full uninstall dengan self-destruction

---

## ⚡ Installation

```powershell
irm https://raw.githubusercontent.com/walkerreza/codex-safe/main/codex-safe.ps1 | iex
```

Input konfigurasi path:

```
file path laragon/www: your_directory
```

Resolved path:

```
C:\laragon\www\your_directory
```

---

## 📦 Post Installation

Restart PowerShell session.

Command tersedia:

```powershell
codex-safe
```

---

## 🧠 Usage

### Repository Validation

```powershell
codex-safe -Mode check
```

### Safe Codex Execution

```powershell
codex-safe -Mode run
```

### Manual Cleanup

```powershell
codex-safe -Mode cleanup
```

### Realtime Monitoring

```powershell
codex-safe -Mode watch
```

### Pass-through Arguments ke Codex

```powershell
codex-safe -Mode run -CodexArgs "--help"
```

---

## 🗑️ Uninstall (Self-Destruct)

```powershell
codex-safe -Mode uninstall
```

Operasi yang dilakukan:

* Remove seluruh Codex worktree
* `git worktree prune`
* Unset `extensions.worktreeconfig`
* Remove direktori:

  * `C:\codex-temp`
  * `C:\Users\<user>\.codex`
* Remove alias `codex-safe`
* Self-delete script

---

## ⚙️ Execution Model

### Mode `run`

* Set environment variable:

  ```
  CODEX_HOME = C:\codex-temp
  ```
* Execute Codex CLI
* Post-execution:

  * Remove generated worktrees
  * `git worktree prune`
  * Reset local Git config
  * Validate repository integrity

### Mode `cleanup`

* Remove seluruh residual worktree
* Reset konfigurasi Git lokal

### Mode `watch`

* Monitor perubahan worktree secara kontinu
* Trigger cleanup sebelum konflik terjadi

### Mode `uninstall`

* Full cleanup environment Codex
* Remove seluruh artefak
* Self-destruction script

---

## ⚠️ Technical Rationale

**Codex CLI**:

* Menggunakan Git worktree untuk parallel task execution

**Antigravity**:

* Tidak mendukung repository dengan `worktreeconfig`

Tanpa isolasi:

* Repository state menjadi tidak konsisten
* Tooling gagal membaca workspace
* Debugging menjadi non-deterministic

---

## 🧠 Best Practices

### Recommended

* Gunakan `run` untuk setiap eksekusi Codex
* Jalankan `check` sebelum membuka Antigravity
* Aktifkan `watch` untuk workflow paralel

### Not Recommended

* Membiarkan worktree aktif dalam waktu lama
* Parallel write oleh multiple AI agents pada file yang sama

---

## 🛠️ File Layout

```
C:\scripts\codex-safe.ps1
C:\codex-temp\
```

---

## 🔧 Configuration

Edit:

```
C:\scripts\codex-safe.ps1
```

Configurable parameters:

* Default repository path
* Watch interval
* Worktree filtering rules
* Cleanup strategy

---

## 🧪 Troubleshooting

### Residual Worktree Detected

```powershell
git worktree list --porcelain
```

Cleanup:

```powershell
codex-safe -Mode cleanup
```

### Command Not Found

```powershell
. $PROFILE
```

### Codex Not Available

```powershell
codex --version
```

---

## 🔥 Design Principle

Multiple AI tooling dapat digunakan dalam satu workflow.

Namun:

> **Git state tidak boleh dibagikan secara mentah antar sistem yang tidak kompatibel.**

Script ini bertindak sebagai isolation layer.

---

## 🏁 License

MIT-style — bebas digunakan, dimodifikasi, dan didistribusikan.


<!--
Keywords:
codex cli worktree fix
git worktree conflict antigravity
extensions.worktreeconfig error fix
workspace infos is nil fix
gemini code assist git issue
codex safe runner powershell
-->

Common errors:
- extensions.worktreeconfig
- workspace infos is nil
- git worktree conflict
- antigravity workspace error

## 🔍 Related Searches

- fix extensions.worktreeconfig
- workspace infos is nil vscode
- git worktree conflict fix
- codex cli issue
- antigravity error workspace
