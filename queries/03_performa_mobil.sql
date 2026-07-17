-- ============================================================
-- AREA 3: PERFORMA ARMADA MOBIL
-- ============================================================

-- Query 1: Mobil Paling Sering Disewa
SELECT
    m.merk || ' ' || m.tipe AS nama_mobil,
    m.id_mobil,
    COUNT(s.id_sewa) AS total_disewa
FROM sewa s
JOIN mobil m ON m.id_mobil = s.id_mobil
GROUP BY m.merk || ' ' || m.tipe, m.id_mobil
ORDER BY total_disewa DESC;


-- Query 2: Pendapatan per Unit Mobil
SELECT
    m.merk || ' ' || m.tipe AS nama_mobil,
    m.id_mobil,
    COUNT(s.id_sewa)    AS total_disewa,
    SUM(b.total_bayar)  AS pendapatan_per_mobil
FROM bayar b
JOIN sewa s  ON b.id_sewa  = s.id_sewa
JOIN mobil m ON m.id_mobil = s.id_mobil
WHERE s.status_sewa != 'BATAL'
GROUP BY m.merk || ' ' || m.tipe, m.id_mobil
ORDER BY pendapatan_per_mobil DESC;


-- Query 3: Rata-rata Lama Sewa per Mobil
SELECT
    m.id_mobil,
    m.merk || ' ' || m.tipe AS nama_mobil,
    COUNT(s.id_sewa) AS jumlah_transaksi,
    ROUND(AVG(s.tgl_kembali - s.tgl_ambil), 2) || ' hari' AS rata_lama_sewa
FROM sewa s
JOIN mobil m ON s.id_mobil = m.id_mobil
WHERE s.status_sewa != 'BATAL'
GROUP BY m.id_mobil, m.merk || ' ' || m.tipe
ORDER BY rata_lama_sewa DESC;


-- Query 4: Mobil dengan Aktivitas Rendah (<= 10x disewa)
SELECT
    m.id_mobil,
    m.merk || ' ' || m.tipe AS nama_mobil,
    COUNT(s.id_sewa) AS jumlah_transaksi
FROM sewa s
RIGHT JOIN mobil m ON m.id_mobil = s.id_mobil
GROUP BY m.id_mobil, m.merk || ' ' || m.tipe
HAVING COUNT(s.id_sewa) <= 10
ORDER BY jumlah_transaksi;
