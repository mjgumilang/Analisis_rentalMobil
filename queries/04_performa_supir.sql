-- ============================================================
-- AREA 4: PERFORMA SUPIR
-- ============================================================

-- Query 1: Supir Paling Sering Ditugaskan
SELECT
    sup.nama_supir,
    sup.id_supir,
    COUNT(s.id_sewa) AS jumlah_ditugaskan
FROM sewa s
RIGHT JOIN supir sup ON sup.id_supir = s.id_supir
GROUP BY sup.nama_supir, sup.id_supir
ORDER BY jumlah_ditugaskan DESC;


-- Query 2: Pendapatan yang Dihasilkan per Supir
SELECT
    sup.nama_supir,
    sup.id_supir,
    COUNT(s.id_sewa)   AS jumlah_transaksi,
    SUM(b.total_bayar) AS jumlah_pendapatan
FROM bayar b
JOIN sewa s          ON s.id_sewa  = b.id_sewa
RIGHT JOIN supir sup ON sup.id_supir = s.id_supir
WHERE s.status_sewa != 'BATAL'
   OR s.status_sewa IS NULL
GROUP BY sup.nama_supir, sup.id_supir
ORDER BY jumlah_pendapatan DESC;


-- Query 3: Supir yang Belum Pernah Ditugaskan
SELECT
    sup.id_supir,
    sup.nama_supir
FROM supir sup
LEFT JOIN sewa s ON sup.id_supir = s.id_supir
WHERE s.id_sewa IS NULL;
