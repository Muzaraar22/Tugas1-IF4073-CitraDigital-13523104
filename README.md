# Tugas 1 IF4073 Pemrosesan Citra - Analisis dan Perbaikan Kualitas Citra

Aplikasi berbasis MATLAB untuk analisis dan perbaikan kualitas citra.
Program ini digunakan untuk menganalisis karakteristik citra uji (citra + histogram intensitas), menentukan
teknik enhancement yang sesuai, lalu menerapkannya serta membandingkan hasil sebelum dan
sesudah perbaikan.

## Deskripsi Singkat Program

Program mengimplementasikan empat kelompok teknik *image enhancement* sesuai spesifikasi tugas:

| Kelompok Teknik | Fungsi |
|---|---|
| *Intensity Transformation* | `src/intensity/` |
| *Histogram Equalization* | `src/equalization/` |
| *Histogram Specification/Matching* | `src/specification/` |
| *Image Filtering* dengan *Masking* | `src/filtering/` |


## Struktur Repositori

```
dataset/     Citra uji resmi (5 subfolder sesuai jenis permasalahan)
docs/        Spesifikasi tugas
src/         Implementasi teknik enhancement (intensity, equalization, specification, filtering)
  histogram/ Fungsi histogram buatan sendiri + plotting
  utils/     Fungsi pembantu bersama
scripts/     Skrip eksplorasi dan validasi
tests/       Unit test MATLAB
gui/         Pembantu GUI (belum digunakan)
```
