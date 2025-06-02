# Flash Monorepo

Ini adalah monorepo yang berisi beberapa proyek Flutter dan paket bersama.

## Struktur

- `packages/shared_core`: Berisi kode yang dibagikan antar proyek (tema, utilitas, konfigurasi API, dll.).
- `project_alpha/`: Sub-proyek Alpha.
- `project_beta/`: Sub-proyek Beta.

## Setup Awal

1. Pastikan [Flutter Version Manager (FVM)](https://fvm.app/docs/getting_started/installation) sudah terinstal.
2. Clone repositori ini.
3. Untuk setiap sub-proyek (misalnya, `project_alpha`):

    ```bash
    cd project_alpha
    fvm install  # Menginstal versi Flutter SDK yang didefinisikan di .fvm/fvm_config.json
    fvm flutter pub get
    ```

4. Salin `.env.example` menjadi `.env` di setiap sub-proyek dan isi nilainya.

## Menjalankan Sub-Proyek

Contoh untuk `project_alpha`:

```bash
cd project_alpha
fvm flutter run
