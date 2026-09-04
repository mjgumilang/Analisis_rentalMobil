-- ============================================================
-- AREA 2: ANALISIS PERILAKU PELANGGAN
-- ============================================================

-- Query 1: Top 10 Pelanggan Paling Aktif
SELECT
    p.nama_pelanggan,
    p.id_pelanggan,
    COUNT(s.id_sewa) AS total_transaksi
FROM sewa s
JOIN pelanggan p ON s.id_pelanggan = p.id_pelanggan
GROUP BY p.id_pelanggan, p.nama_pelanggan
ORDER BY total_transaksi DESC
FETCH FIRST 10 ROWS ONLY


-- Query 2: Pelanggan dengan Total Pengeluaran Tertinggi
SELECT
    p.nama_pelanggan,
    s.id_pelanggan,
    COUNT(s.id_sewa)   AS total_transaksi,
    SUM(b.total_bayar) AS total_pengeluaran
FROM bayar b
JOIN sewa s      ON b.id_sewa = s.id_sewa
JOIN pelanggan p ON s.id_pelanggan = p.id_pelanggan
GROUP BY p.nama_pelanggan, s.id_pelanggan
ORDER BY total_pengeluaran DESC;


-- Query 3: Pelanggan Paling Sering Terlambat
SELECT
    p.nama_pelanggan,
    p.id_pelanggan,
    COUNT(s.id_sewa) AS jumlah_keterlambatan
FROM sewa s
JOIN pelanggan p ON s.id_pelanggan = p.id_pelanggan
WHERE s.status_sewa = 'TERLAMBAT'
GROUP BY p.nama_pelanggan, p.id_pelanggan
ORDER BY jumlah_keterlambatan DESC


-- Query 4: Persentase Penggunaan Supir (Window Function)
SELECT 
    CASE WHEN s.pakai_supir = 0 then 'Tanpa Supir'
         ELSE 'Dengan Supir' END AS Keterangan,
    COUNT(*) as jumlah,
    ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER(),1) as presentase,
    ROUND(AVG(CASE WHEN b.status_bayar = 'LUNAS' THEN b.total_bayar
             WHEN b.status_bayar = 'DP' THEN b.dp_awal
             ELSE 0 END),2) as rata_rata_transaksi

FROM sewa s
JOIN bayar b ON s.id_sewa = b.id_sewa
WHERE s.status_sewa != 'BATAL'
GROUP by s.pakai_supir
ORDER by COUNT(*) DESC


-- Query 5: Identifikasi Pelanggan Churn (hanya 1x transaksi)
SELECT
    p.nama_pelanggan,
    p.id_pelanggan,
    COUNT(s.id_sewa) AS jumlah_transaksi
FROM pelanggan p
LEFT JOIN sewa s ON p.id_pelanggan = s.id_pelanggan
GROUP BY p.nama_pelanggan, p.id_pelanggan
HAVING COUNT(s.id_sewa) = 1
ORDER BY jumlah_transaksi DESC;
