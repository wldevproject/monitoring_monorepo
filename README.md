# Monorepo Proyek Monitoring (Quick Start)

Repositori ini menggunakan FVM untuk manajemen versi Flutter per proyek dan Melos untuk manajemen monorepo.

## 🛠️ Prasyarat

1. **Git**
2. **Flutter SDK** (versi apapun, untuk instalasi Dart & FVM awal)
3. **FVM**: `dart pub global activate fvm`
4. **Melos**: `dart pub global activate melos`
    *Pastikan `$HOME/.pub-cache/bin` (atau path Windows yang sesuai) ada di PATH sistem Anda.*

## 📁 Struktur Utama

monitoring_monorepo/
├── packages/shared_core/   # Kode bersama (tema, API client, dll.)
├── monitoring_cuaca/       # Sub-proyek aplikasi 1
├── monitoring_kimia/       # Sub-proyek aplikasi 2
├── melos.yaml              # Konfigurasi Melos
└── pubspec.yaml            # Pubspec untuk root workspace (untuk Melos v3+)

## 🚀 Pengaturan Awal (Setelah Clone)

1. **Pindah ke Direktori Root Monorepo**:

    ```bash
    cd path/ke/monitoring_monorepo
    ```

2. **Install Dependensi Root untuk Melos**:
    *(Pastikan `pubspec.yaml` di root sudah ada `dev_dependencies: melos: ^versi_terbaru`)*

    ```bash
    dart pub get
    ```

3. **Bootstrap dengan Melos** (untuk linking paket & attempt pub get awal):

    ```bash
    melos bootstrap
    ```

4. **Ambil Dependensi dengan FVM yang Benar (Krusial!)**:

    ```bash
    melos run get_all
    ```

    *Skrip ini menjalankan `fvm flutter pub get` di setiap sub-proyek sesuai versi FVM yang dipin.*

5. **Setup FVM & `.env` per Sub-Proyek**:
    Untuk setiap sub-proyek (misalnya `monitoring_cuaca`):
    * `cd monitoring_cuaca`
    * `fvm install` (menginstal versi Flutter dari `.fvm/fvm_config.json` jika belum ada di cache FVM)
    * `cp .env.example .env` (salin contoh .env)
    * Edit `.env` dengan konfigurasi Anda.
    * `cd ..` (kembali ke root monorepo)

## 💻 Alur Kerja Umum

### Menjalankan Sub-Proyek Aplikasi

**Contoh untuk `monitoring_cuaca`:**

1. **Dari Terminal di Root Monorepo (Menggunakan Skrip Melos):**

    ```bash
    melos run run:monitoring_cuaca
    ```

2. **Dari Terminal Langsung di Direktori Sub-Proyek:**

    ```bash
    cd monitoring_cuaca
    fvm flutter run
    ```

3. **Dari IDE (VS Code):**
    * **Rekomendasi**: Buka folder root monorepo (`monitoring_monorepo`) di VS Code.
    * Gunakan terminal terintegrasi: `cd monitoring_cuaca` lalu `fvm flutter run`.
    * Atau, konfigurasikan `.vscode/launch.json` di root untuk setiap sub-proyek (atur `cwd` ke direktori sub-proyek).

### Mengedit Kode Bersama (`shared_core`)

* Lakukan perubahan di `packages/shared_core`.
* Perubahan akan langsung terlihat di sub-proyek yang menggunakan `shared_core` (setelah hot reload/restart di sub-proyek tersebut).
* Pastikan `shared_core` kompatibel dengan versi Flutter/Dart terendah yang digunakan sub-proyek.

## ✨ Perintah Melos Penting (Jalankan dari Root Monorepo)

* **`melos bootstrap`**: Inisialisasi dan link paket.
* **`melos run get_all`**: Ambil/update semua dependensi menggunakan FVM yang benar.
* **`melos run clean_all`**: Bersihkan semua proyek Flutter.
* **`melos run analyze_all`**: Analisis statis semua kode.
* **`melos run test_all`**: Jalankan semua tes.
* **`melos run format_all`**: Format semua kode Dart.

## 🔑 FVM (Flutter Version Manager)

* **`fvm list`**: Lihat versi Flutter yang dikelola FVM.
* **`fvm install <versi>`**: Instal versi Flutter baru.
* **`cd path/ke/sub_proyek`** lalu **`fvm use <versi>`**: Atur versi Flutter untuk sub-proyek tersebut.

## 🔒 Variabel Lingkungan (`.env`)

* Setiap sub-proyek memiliki file `.env`-nya sendiri (disalin dari `.env.example`).
* `shared_core` akan membaca variabel ini melalui `AppEnv` setelah `dotenv.load()` dipanggil di `main.dart` sub-proyek.
* **`.env` tidak di-commit ke Git.**

---
Ini adalah panduan cepat Anda. Untuk detail lebih lanjut, lihat dokumentasi FVM dan Melos.
