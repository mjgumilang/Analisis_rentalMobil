# Analisis Data Rental Mobil — SQL & Tableau

Project analisis data end-to-end untuk bisnis rental mobil: mulai dari perancangan database relasional, penulisan query SQL untuk menjawab pertanyaan bisnis, hingga visualisasi dashboard interaktif.

**Oleh:** Muhammad Jiddan Gumilang
|| [email](mailto:muhammadjiddan.g@gmail.com) || [LinkedIn](https://www.linkedin.com/in/muhammadjiddangumilang) || [Tableau Public](https://public.tableau.com/views/Analisis_rentalMobil/KPI_RentalMobil?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

---

## Ringkasan Project

Data analyst tidak mulai dari data — tapi dari pertanyaan bisnis. Project ini mensimulasikan proses tersebut untuk sebuah bisnis rental mobil:

```
Pertanyaan Bisnis → Cari Data → Analisis (SQL) → Insight → Rekomendasi Bisnis
```

**Cakupan pekerjaan:**
- Merancang ERD dan skema database relasional dari nol
- Membuat 6 tabel (4 tabel master, 2 tabel transaksi) dengan relasi PK/FK
- Menulis 17 query SQL analitik terbagi ke dalam 4 area bisnis — mayoritas mandiri, sebagian kecil dengan arahan AI saat menemui kebuntuan teknis (lihat catatan di bagian bawah)
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
| Total pendapatan per bulan | Juni & Desember menyumbang Rp438.8M (41.1% dari total Rp1.07B); Desember (Rp223.9M) 6.6× lipat November (Rp33.7M) — bisnis rapuh di luar peak season |
| Pendapatan per kuartal | Q2→Q3 anjlok 39.4% (Rp336.2M → Rp203.9M, 144 → 87 transaksi) — pola "M-shape" yang sangat bergantung pada momen liburan |
| Kontribusi denda | Total denda Rp11.7M (1.24% rata-rata revenue). Justru tertinggi di bulan sepi (Jan 2.16%, Nov 1.78%), terendah di peak season (Jun 0.79%, Des 0.71%) |
| Kerugian transaksi batal | 59 transaksi batal = Rp159.7M potensi hilang (15% dari revenue aktual). 45.8% pembatalan terjadi di peak season (Jun+Des) |
| Rata-rata nilai transaksi (AOV) | AOV rata-rata Rp2.36M. Uniknya, Juni (transaksi terbanyak) AOV-nya lebih rendah (Rp2.48M) dari Januari yang sepi (Rp2.67M) |

Query lengkap: [`queries/01_revenue_keuangan.sql`](queries/01_revenue_keuangan.sql)

## Area 2 — Perilaku Pelanggan

| Query | Insight Utama |
|---|---|
| Top 10 pelanggan aktif | Cahyo Purnomo (ID:229) #1 dengan 7 transaksi. **Catatan data:** nama pelanggan ada yang duplikat (mis. Luthfi Anwar muncul di 2 ID berbeda) — semua insight di sini sudah di-dedup berdasarkan `id_pelanggan`, bukan nama |
| Pengeluaran tertinggi | Top 5 pelanggan (termasuk Cahyo Purnomo Rp32M) menyumbang Rp99M (9.3% dari total) — distribusi spending cukup tersebar, tidak bergantung 1 pelanggan |
| Keterlambatan berulang | 81 dari 300 pelanggan (27%) pernah terlambat; 11 pelanggan repeat offender. Cahyo Purnomo juga masuk 3 pelanggan paling sering terlambat (3×) |
| Penggunaan supir | 39.4% transaksi (197/500) pakai supir, berkontribusi ~44.7% revenue — lebih tinggi dari proporsi volumenya, dihitung dengan window function `OVER()` |
| Churn (1x transaksi) | 92 pelanggan (38% dari total aktif) hanya bertransaksi 1x → kandidat win-back campaign |

Query lengkap: [`queries/02_analisis_pelanggan.sql`](queries/02_analisis_pelanggan.sql)

## Area 3 — Performa Armada Mobil

| Query | Insight Utama |
|---|---|
| Mobil paling sering disewa | Toyota 126 transaksi (25.2%); MPV tipe terlaris (180 transaksi, 36%). 3 unit teratas (31 transaksi masing-masing) semuanya SUV |
| Pendapatan per unit | Daihatsu City Car ID:11 tertinggi (Rp149.4M, Rp5,978,000/transaksi) — tapi unit ID:19 dengan tipe sama cuma Rp23.9M, selisih 5.2× → indikasi 2 varian harga berbeda (luxury vs standard) di 1 nama model |
| Rata-rata lama sewa | Rata-rata 4.17 hari/transaksi. Honda Sedan (ID:17) terlama (4.8 hari) — konsisten dengan revenue/transaksi tertinggi (segmen bisnis/jarak jauh) |
| Mobil aktivitas rendah | Semua 20 unit tersewa >10× (tidak ada yang idle), tapi gap unit tersibuk (31×) vs tersedikit (14×) mencapai 121% — distribusi permintaan tidak merata |

Query lengkap: [`queries/03_performa_mobil.sql`](queries/03_performa_mobil.sql)

## Area 4 — Performa Supir

| Query | Insight Utama |
|---|---|
| Supir paling sering ditugaskan | Ganda Putra teratas dengan 21 penugasan (total, termasuk transaksi batal) — gap 133% dari yang terendah, Dadang Hermawan (9×) |
| Pendapatan per supir | Ganda Putra Rp56.1M dari 20 trip berbayar (transaksi batal dikecualikan) — 3.4× lebih tinggi dari Bambang Riyadi (Rp16.5M). Anomali: Maman Suryadi cuma 10 trip tapi revenue/trip tertinggi (Rp4.09M), 1.46× di atas Ganda Putra |
| Supir belum ditugaskan | Semua 15 supir aktif beroperasi (0 idle) — indikasi manajemen SDM yang baik, meski beban kerja antar supir tidak merata |

Query lengkap: [`queries/04_performa_supir.sql`](queries/04_performa_supir.sql)

---

## Dashboard (Tableau Public)

Lihat dashboard interaktif lengkap di [Tableau Public](https://public.tableau.com/views/Analisis_rentalMobil/KPI_RentalMobil?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link).

| Dashboard | Isi | Key Metric |
|---|---|---|
| Overview Bisnis | KPI cards + tren pendapatan bulanan | Rp1.07B total revenue 2024 |
| Performa Mobil | Bar chart terlaris, pendapatan, denda per mobil | Toyota MPV #1 terlaris |
| Analisis Pelanggan | Top 10 pelanggan, spending, penggunaan supir | Cahyo Purnomo #1 VIP |
| Analisis Pembayaran | Distribusi metode & status transaksi | 79% transaksi lunas |
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
- Perancangan ERD, skema database, dan seluruh business insight adalah hasil pemikiran dan revisi saya sendiri, dengan AI sebagai partner diskusi untuk mengecek logika dan memberi umpan balik.

Saya percaya AI adalah alat bantu, bukan pengganti proses belajar — sehingga kejelasan soal apa yang saya kerjakan mandiri vs. dengan bantuan penting untuk dicantumkan di sini.
