# Analisis Data Rental Mobil || SQL & Tableau

Project analisis data end-to-end untuk bisnis rental mobil: mulai dari perancangan database relasional (melanjutkan tugas perancangan ERD pada saat kuliah), penulisan query SQL untuk menjawab pertanyaan bisnis, hingga visualisasi dashboard interaktif.

**Oleh:** Muhammad Jiddan Gumilang
|| [email](mailto:muhammadjiddan.g@gmail.com) || [LinkedIn](https://www.linkedin.com/in/muhammadjiddangumilang) || [Tableau Public](https://public.tableau.com/views/Analisis_rentalMobil/KPI_RentalMobil?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

---

## Ringkasan Project

Project ini mensimulasikan proses tersebut untuk sebuah bisnis rental mobil:

```
Pertanyaan Bisnis > Cari Data > Analisis (SQL) > Insight > Rekomendasi Bisnis
```

**Cakupan pekerjaan:**
- Merancang ERD dan skema database relasional dari nol
- Membuat 6 tabel (4 tabel master, 2 tabel transaksi) dengan relasi PK/FK
- Menulis 17 query SQL analitik terbagi ke dalam 4 area bisnis dengan penyusunan query mayoritas mandiri, sebagian kecil dengan arahan AI saat menemui kebuntuan teknis (lihat catatan di bagian bawah)
- Menerjemahkan hasil query menjadi business insight dan rekomendasi
- Membangun 5 dashboard interaktif di Tableau Public

---

## Struktur Database

![ERD Rental Mobil](database/erd.png)

| Tabel | Jenis | Jumlah Data | Fungsi |
|---|---|---|---|
| `pelanggan` | Master | 300 | Data penyewa mobil |
| `mobil` | Master | 20 | Data unit armada |
| `supir` | Master | 15 | Data supir pendamping |
| `admin_rental` | Master | 5 | Data petugas yang memproses transaksi |
| `sewa` | Transaksi | 500 | Mencatat proses penyewaan |
| `bayar` | Transaksi | 500 | Mencatat proses pembayaran |

**Kenapa `sewa` dan `bayar` dipisah?** Karena keduanya merepresentasikan kejadian bisnis yang berbeda (proses sewa vs proses bayar), menghindari kolom NULL berlebih, dan lebih fleksibel untuk pengembangan (misal: cicilan, refund). Detail lengkap ada di [`database/erd.png`](database/erd.png) dan [`database/schema.sql`](database/schema.sql).

---

## Tech Stack

`Oracle SQL (Oracle Apex)` · `PL/SQL` · `Tableau Public` · `Draw.io / Lucidchart (ERD)`

**Konsep SQL yang diterapkan:** JOIN (INNER/LEFT/RIGHT), GROUP BY + fungsi agregat, HAVING vs WHERE, Window Function (`OVER()`), CASE WHEN.

---

## Struktur Repo

```
rental-mobil-data-analysis/
│
├── README.md
├── database/
│   ├── erd.png
│   ├── schema.sql          # CREATE TABLE untuk 6 tabel
├── queries/
│   ├── 01_revenue_keuangan.sql
│   ├── 02_analisis_pelanggan.sql
│   ├── 03_performa_mobil.sql
│   └── 04_performa_supir.sql
├── data/                   # export CSV tiap tabel
|   ├── mobil.csv
|   ├── admin_rental.csv
|   ├── bayar.csv
|   ├── sewa.csv
|   ├── supir.csv
|   ├── mobil.csv
└── docs/
    └── portfolio-summary.pdf
```

---

## Area 1 — Revenue & Keuangan

| Query | Insight Utama |
|---|---|
| Total pendapatan per bulan | Juni & Desember menyumbang Rp410.4M (41.1% dari total Rp999.1M). Desember (Rp211.1M) 7.3× lipat November (Rp29.0M), bisnis rapuh di luar peak season (Juni & Desember) |
| Pendapatan per kuartal | Q2→Q3 anjlok 37.6% (Rp307.0M → Rp191.7M, 144 → 87 transaksi), terlihat pola naik turun berbentuk M yang sangat bergantung pada momen liburan |
| Kontribusi denda | Total denda Rp11.7M (1.33% rata-rata revenue). Justru tertinggi di bulan sepi (Jan 2.20%, Nov 2.07%), terendah di peak season (Jun 0.85%, Des 0.76%) |
| Kerugian transaksi batal | 59 transaksi batal = Rp159.7M potensi hilang (16% dari revenue aktual). 45.8% pembatalan terjadi di peak season (Jun+Des) |
| Rata-rata nilai transaksi (AOV) | AOV rata-rata Rp2.27M. Uniknya, Juni (transaksi terbanyak) AOV-nya lebih rendah (Rp2.32M) dari Januari yang sepi (Rp2.68M) |

Query lengkap: [`queries/01_revenue_keuangan.sql`](queries/01_revenue_keuangan.sql)

> **Catatan koreksi:** Revenue di atas sudah dikoreksi dari perhitungan awal yang sempat menghitung transaksi berstatus `DP` (baru bayar sebagian) sebagai lunas penuh. Setelah dikoreksi dengan `CASE WHEN status_bayar = 'DP' THEN dp_awal ELSE total_bayar END`, total revenue turun dari Rp1.07B menjadi Rp999.1M (koreksi ~6.5%).

## Area 2 — Perilaku Pelanggan

| Query | Insight Utama |
|---|---|
| Top 10 pelanggan aktif | Cahyo Purnomo (ID:229) #1 dengan 7 transaksi. **Catatan data:** nama pelanggan ada yang duplikat (karena nama pelanggan berulang setiap 50 nama), semua insight di sini sudah di-dedup berdasarkan `id_pelanggan`, bukan nama |
| Pengeluaran tertinggi | Top 5 pelanggan (termasuk Cahyo Purnomo Rp30.7M) menyumbang Rp94M (9.4% dari total), distribusi spending pelanggan cukup tersebar, tidak bergantung 1 pelanggan |
| Keterlambatan berulang | 81 dari 300 pelanggan (27%) pernah terlambat. 11 pelanggan repeat offender. Cahyo Purnomo juga masuk 3 pelanggan paling sering terlambat (3×) |
| Penggunaan supir | 39.0% transaksi valid (172/441) pakai supir, berkontribusi kurang lebih sebesar 40.2% dari revenue (Rp402.1M), ini lebih tinggi dari proporsi volumenya, dihitung dengan window function `OVER()` |
| Churn (1x transaksi) | 92 pelanggan (38% dari total aktif) hanya bertransaksi 1x → kandidat win-back campaign |

Query lengkap: [`queries/02_analisis_pelanggan.sql`](queries/02_analisis_pelanggan.sql)

## Area 3 — Performa Armada Mobil

| Query | Insight Utama |
|---|---|
| Mobil paling sering disewa | Toyota 126 transaksi (25.2%); MPV tipe terlaris (180 transaksi, 36%). 3 unit teratas (31 transaksi masing-masing) semuanya SUV |
| Pendapatan per unit | Daihatsu City Car ID:11 tertinggi (Rp147.4M, Rp5,894,000/transaksi) — tapi unit ID:19 dengan tipe sama cuma Rp22.2M, selisih 5.6× ini  mengindikasikan terdapat 2 varian harga berbeda (luxury vs standard) di 1 nama model |
| Rata-rata lama sewa | Rata-rata 4.17 hari/transaksi. Armada Honda Sedan (ID:17) terlama (4.8 hari), konsisten dengan revenue/transaksi tertinggi (segmen bisnis/jarak jauh) |
| Mobil aktivitas rendah | Semua 20 unit tersewa >10× (tidak ada yang idle), tapi gap unit tersibuk (31×) vs tersedikit (14×) mencapai 121%, menunjukkan distribusi permintaan kurang merata |

Query lengkap: [`queries/03_performa_mobil.sql`](queries/03_performa_mobil.sql)

## Area 4 — Performa Supir

| Query | Insight Utama |
|---|---|
| Supir paling sering ditugaskan | Ganda Putra teratas dengan 21 penugasan (total, termasuk transaksi batal) memiliki gap 133% dari yang terendah, Dadang Hermawan (9×) |
| Pendapatan per supir | Ganda Putra Rp51.7M dari 20 trip berbayar (transaksi batal dikecualikan), dimana 3.5× lebih tinggi dari Bambang Riyadi (Rp14.8M). Anomali: Maman Suryadi cuma 9 trip tapi revenue/trip tertinggi (Rp3.43M), 1.33× di atas Ganda Putra |
| Supir belum ditugaskan | Semua 15 supir aktif beroperasi (0 idle), ini menunjukkan bahwa manajemen SDM yang baik, meski beban kerja antar supir tidak merata |

Query lengkap: [`queries/04_performa_supir.sql`](queries/04_performa_supir.sql)

---

## Dashboard (Tableau Public)

Lihat dashboard interaktif lengkap di [Tableau Public](https://public.tableau.com/views/Analisis_rentalMobil/KPI_RentalMobil?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link).

| Dashboard | Isi | Key Metric |
|---|---|---|
| Overview Bisnis | KPI cards + tren pendapatan bulanan | Rp999.1M total revenue 2024 |
| Performa Mobil | Bar chart terlaris, pendapatan, denda per mobil | Toyota MPV #1 terlaris |
| Analisis Pelanggan | Top 10 pelanggan, spending, penggunaan supir | Cahyo Purnomo #1 VIP |
| Analisis Pembayaran | Distribusi metode & status transaksi | 89.8% transaksi lunas, 10.2% masih DP |
| Performa Supir | Ranking, pendapatan, penugasan supir | Ganda Putra #1 produktif |

---

##  Key Recommendations

- Alokasikan armada maksimal di periode peak season (Juni & Desember)
- Program promo early bird / paket weekend untuk mengangkat performa Q3
- Sistem reminder H-1 pengembalian untuk menekan denda dan keterlambatan
- Program loyalty untuk top 10 pelanggan; win-back campaign untuk 92 pelanggan churn
- Evaluasi diversifikasi armada agar tidak terlalu bergantung pada satu merk (Toyota 25%)
- Sistem rotasi penugasan supir yang lebih merata

Detail insight dan narasi bisnis lengkap ada di [`docs/portfolio-summary.pdf`](docs/portfolio-summary.pdf).

---

##  Catatan Proses & Keterlibatan AI

Dataset pada project ini adalah **data dummy**, digenerate untuk keperluan pembelajaran dan portofolio — bukan data operasional perusahaan nyata.

Sebagai bentuk transparansi soal penggunaan AI dalam project ini:

- **17 query SQL** ([`queries/`](queries/)) sebagian besar saya tulis mandiri. 1–3 query disusun dengan arahan Claude (Anthropic) saat saya menemui kebuntuan teknis — proses koreksi dan penjelasannya menjadi bagian dari proses belajar saya.
- Selama proses review, saya juga menemukan (dengan bantuan diskusi AI untuk menelusuri akar masalahnya) bahwa perhitungan revenue awal keliru menghitung transaksi berstatus DP sebagai lunas penuh. Setelah dikoreksi, seluruh angka revenue di project ini (termasuk dashboard dan laporan) diperbarui ke basis yang benar — didokumentasikan secara terbuka di Area 1 di atas, bukan disembunyikan.
- Perancangan ERD, skema database, dan seluruh business insight adalah hasil pemikiran dan revisi saya sendiri, dengan AI sebagai partner diskusi untuk mengecek logika dan memberi umpan balik.

Saya menggunakan AI sebagai alat bantu, bukan pengganti proses belajar. Sehingga kejelasan soal apa yang saya kerjakan mandiri dan dengan bantuan AI penting untuk dicantumkan di sini.
