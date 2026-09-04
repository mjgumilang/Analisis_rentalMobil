-- ============================================================
-- AREA 1: REVENUE & KEUANGAN
-- ============================================================

-- Query 1: Total Pendapatan per Bulan
SELECT
    TO_CHAR(s.tgl_ambil, 'YYYY-MM') AS bulan,
    COUNT(s.id_sewa) AS jumlah_transaksi,
    SUM(CASE WHEN b.status_bayar = 'LUNAS' THEN b.total_bayar
             WHEN b.status_bayar = 'DP' THEN b.dp_awal
             ELSE 0 END) AS total_pendapatan
FROM sewa s
JOIN bayar b ON s.id_sewa = b.id_sewa
WHERE s.status_sewa != 'BATAL'
GROUP BY TO_CHAR(s.tgl_ambil, 'YYYY-MM')
ORDER BY bulan


-- Query 2: Pendapatan per Kuartal
SELECT
    TO_CHAR(s.tgl_ambil, 'YYYY') AS tahun,
    'Q' || TO_CHAR(s.tgl_ambil, 'Q') AS kuartal,
    COUNT(s.id_sewa) AS jumlah_transaksi,
    SUM(CASE WHEN b.status_bayar = 'LUNAS' THEN b.total_bayar
             WHEN b.status_bayar = 'DP' THEN b.dp_awal
             ELSE 0 END) AS total_pendapatan,
    ROUND(AVG(CASE WHEN b.status_bayar = 'LUNAS' THEN b.total_bayar
                   WHEN b.status_bayar = 'DP' THEN b.dp_awal
                   ELSE 0 END), 0) AS rata_rata_transaksi
FROM sewa s
JOIN bayar b ON s.id_sewa = b.id_sewa
WHERE s.status_sewa != 'BATAL'
GROUP BY TO_CHAR(s.tgl_ambil, 'YYYY'), TO_CHAR(s.tgl_ambil, 'Q')
ORDER BY tahun, kuartal


-- Query 3: Kontribusi Denda terhadap Pendapatan
SELECT
    TO_CHAR(s.tgl_ambil, 'YYYY-MM')         AS bulan,
    SUM(b.total_bayar)                       AS total_pendapatan,
    SUM(s.denda)                             AS total_denda,
    ROUND(SUM(s.denda) /
          SUM(b.total_bayar) * 100, 2)       AS persen_kontribusi_denda
FROM sewa s
JOIN bayar b ON s.id_sewa = b.id_sewa
WHERE s.status_sewa != 'BATAL'
GROUP BY TO_CHAR(s.tgl_ambil, 'YYYY-MM')
ORDER BY bulan


-- Query 4: Kerugian dari Transaksi Batal
-- Catatan: total_bayar = 0 untuk transaksi BATAL by design (lihat seed-data.sql),
-- sehingga potensi kerugian dihitung dari harga_sewa x lama_sewa, bukan total_bayar.
SELECT
    TO_CHAR(s.tgl_ambil, 'YYYY-MM')            AS bulan,
    COUNT(s.id_sewa)                            AS jumlah_batal,
    SUM(m.harga_sewa *
       (s.tgl_kembali - s.tgl_ambil))          AS potensi_pendapatan_hilang
FROM sewa s
JOIN mobil m ON s.id_mobil = m.id_mobil
WHERE s.status_sewa = 'BATAL'
GROUP BY TO_CHAR(s.tgl_ambil, 'YYYY-MM')
ORDER BY jumlah_batal DESC


-- Query 5: Rata-rata Nilai Transaksi per Bulan
SELECT
    TO_CHAR(s.tgl_ambil, 'MM-YYYY')                    AS bulan,
    COUNT(s.id_sewa)                                    AS jumlah_transaksi,
    ROUND(AVG(m.harga_sewa *
        (s.tgl_kembali - s.tgl_ambil)), 0)             AS rata_rata_pendapatan
FROM sewa s
JOIN mobil m ON s.id_mobil = m.id_mobil
WHERE s.status_sewa != 'BATAL'
GROUP BY TO_CHAR(s.tgl_ambil, 'MM-YYYY')
ORDER BY bulan
