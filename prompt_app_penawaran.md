# Prompt: Aplikasi Penawaran — Bisnis Jasa & Kontraktor

---

## Konteks Proyek

Buatkan aplikasi Flutter untuk **manajemen penawaran (quotation)** milik bisnis jasa dan kontraktor.
Aplikasi ini digunakan oleh pemilik bisnis / admin untuk membuat, menyimpan, dan mencetak penawaran ke klien.

---

## Stack & Ketentuan Teknis

- **Framework:** Flutter (latest stable)
- **State Management:** Provider atau Riverpod (pilih yang paling kamu familiar)
- **Database lokal:** `sqflite` atau `Hive` untuk menyimpan data klien & penawaran
- **PDF Export:** package `pdf` + `printing` dari pub.dev
- **Target platform:** Android (utama), iOS (opsional)

---

## Fitur Utama

| Fitur | Keterangan |
|---|---|
| Buat Penawaran Baru | Form input lengkap, kalkulasi otomatis |
| List Penawaran | Daftar semua penawaran, bisa filter & search |
| Data Klien | Simpan & reuse data klien |
| Export PDF | Generate dokumen penawaran siap cetak / kirim |
| Total Otomatis | Subtotal, diskon, pajak, dan grand total dihitung otomatis |

---

## Struktur Navigasi (App Flow)

```
[Splash Screen]
      |
[Home Screen]
  ├── [Buat Penawaran Baru]
  │     ├── Step 1: Info Klien (pilih dari saved / input manual)
  │     ├── Step 2: Detail Pekerjaan / Item
  │     │         (nama item, satuan, qty, harga satuan)
  │     ├── Step 3: Ringkasan & Kalkulasi
  │     │         (subtotal, diskon %, pajak %, grand total)
  │     └── Step 4: Preview & Export PDF
  │
  └── [List Penawaran]
        ├── Card tiap penawaran (no. penawaran, nama klien, tanggal, total, status)
        ├── Tap → Detail Penawaran
        │         ├── Lihat semua item
        │         ├── Edit penawaran
        │         └── Export PDF ulang
        └── Hapus penawaran (swipe to delete / long press)
```

---

## Struktur Folder Project

```
lib/
├── main.dart
├── app/
│   └── routes.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   └── app_strings.dart
│   └── utils/
│       ├── currency_formatter.dart
│       └── pdf_generator.dart
├── data/
│   ├── models/
│   │   ├── client_model.dart
│   │   ├── item_model.dart
│   │   └── quotation_model.dart
│   └── repositories/
│       ├── client_repository.dart
│       └── quotation_repository.dart
├── db/
│   └── database_helper.dart
└── features/
    ├── home/
    │   └── home_screen.dart
    ├── quotation/
    │   ├── create/
    │   │   ├── create_quotation_screen.dart
    │   │   ├── widgets/
    │   │   │   ├── client_step.dart
    │   │   │   ├── items_step.dart
    │   │   │   └── summary_step.dart
    │   │   └── create_quotation_provider.dart
    │   ├── list/
    │   │   ├── quotation_list_screen.dart
    │   │   └── quotation_card_widget.dart
    │   └── detail/
    │       └── quotation_detail_screen.dart
    └── client/
        ├── client_list_screen.dart
        └── client_form_screen.dart
```

---

## Model Data

### `ClientModel`
```dart
class ClientModel {
  int? id;
  String name;         // Nama klien / perusahaan
  String phone;        // No. telepon
  String address;      // Alamat lengkap
  String? email;
  DateTime createdAt;
}
```

### `ItemModel` (baris item dalam penawaran)
```dart
class ItemModel {
  int? id;
  String description;  // Nama/deskripsi pekerjaan atau barang
  String unit;         // Satuan: m², m³, unit, ls (lump sum), dll
  double qty;
  double unitPrice;
  double get total => qty * unitPrice;
}
```

### `QuotationModel`
```dart
class QuotationModel {
  int? id;
  String quotationNumber;  // cth: PNW/2025/001
  ClientModel client;
  List<ItemModel> items;
  double discountPercent;  // default 0
  double taxPercent;       // default 11 (PPN)
  String? notes;           // Catatan tambahan
  String status;           // 'draft' | 'sent' | 'approved' | 'rejected'
  DateTime createdAt;

  double get subtotal => items.fold(0, (sum, i) => sum + i.total);
  double get discountAmount => subtotal * (discountPercent / 100);
  double get taxAmount => (subtotal - discountAmount) * (taxPercent / 100);
  double get grandTotal => subtotal - discountAmount + taxAmount;
}
```

---

## Detail Tiap Fitur

### 1. Home Screen
- Dua tombol utama: **"Buat Penawaran"** dan **"List Penawaran"**
- Tampilkan ringkasan singkat: total penawaran bulan ini, total nilai
- Shortcut ke **Data Klien**

### 2. Buat Penawaran (Multi-step Form)

**Step 1 — Info Klien:**
- Tombol "Pilih dari Daftar Klien" → bottom sheet / halaman daftar klien tersimpan
- Atau input manual (nama, telepon, alamat)
- Auto-generate nomor penawaran berdasarkan format `PNW/YYYY/XXX`

**Step 2 — Item Pekerjaan:**
- Tambah item: deskripsi pekerjaan, satuan, qty, harga satuan
- Total per item dihitung otomatis
- Bisa tambah banyak item (add more), edit, dan hapus item
- Dukung satuan umum kontraktor: `m²`, `m³`, `unit`, `ls`, `pkt`, `titik`, `meter`

**Step 3 — Ringkasan:**
- Tampilkan subtotal semua item
- Input diskon (%) — opsional
- Input pajak (%) — default 11% PPN, bisa diubah / di-skip
- Catatan tambahan (opsional)
- Grand total besar dan jelas

**Step 4 — Preview & Simpan:**
- Preview tampilan penawaran
- Tombol **Simpan** (ke database lokal)
- Tombol **Export PDF** → generate & share/print langsung

### 3. List Penawaran
- Tampil sebagai list card dengan info: nomor penawaran, nama klien, tanggal, grand total, badge status
- Search bar untuk cari by nama klien / nomor penawaran
- Filter by status (semua / draft / sent / approved)
- Swipe kiri untuk hapus dengan konfirmasi dialog

### 4. Detail Penawaran
- Tampilkan semua data penawaran lengkap
- Tombol **Edit** → kembali ke form dengan data pre-filled
- Tombol **Export PDF** → generate ulang
- Tombol ubah status (draft → sent → approved/rejected)

### 5. Export PDF
Format dokumen PDF penawaran:
```
[Logo / Nama Perusahaan Bokap]          [Nomor Penawaran]
[Alamat Perusahaan]                      [Tanggal]

Kepada Yth:
[Nama Klien]
[Alamat Klien]

PENAWARAN HARGA

No | Uraian Pekerjaan | Sat | Vol | Harga Satuan | Jumlah
---|------------------|-----|-----|--------------|-------
1  | ...              | ... | ... | Rp ...       | Rp ...

                              Subtotal  : Rp ...
                              Diskon    : Rp ...
                              PPN 11%   : Rp ...
                              Total     : Rp ...

Catatan: ...

Hormat kami,
[Nama Perusahaan]
```

---

## UX & UI Guidelines

- Gunakan **Material 3** design system
- Warna utama: biru tua profesional (`#1A3A5C`) atau bisa diganti sesuai brand
- Font: `Inter` atau `Poppins` via Google Fonts
- Semua angka rupiah format: `Rp 1.500.000` (titik sebagai pemisah ribuan)
- Form validation jelas dengan pesan error yang spesifik
- Loading indicator saat generate PDF
- Empty state yang informatif di list kosong

---

## Yang Perlu Disiapkan

1. Nama perusahaan bokap (untuk header PDF & nomor penawaran)
2. Alamat & kontak perusahaan (untuk footer PDF)
3. Logo perusahaan (opsional, bisa di-skip dulu)
4. Format nomor penawaran yang diinginkan (default: `PNW/YYYY/XXX`)
5. Apakah perlu fitur multi-user / login, atau cukup single user?

---

## Prioritas Development (Urutan Pengerjaan)

1. Setup project + struktur folder + database helper
2. Model data + repository
3. Home Screen
4. Fitur Buat Penawaran (form multi-step)
5. List & Detail Penawaran
6. Data Klien
7. Export PDF
8. Polish UI + empty states + validasi

---

*Prompt ini dibuat sebagai panduan pengembangan. Sesuaikan nama perusahaan, warna brand, dan format dokumen sebelum mulai coding.*
