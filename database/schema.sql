-- ============================================================
-- SCHEMA: DATABASE RENTAL MOBIL
-- 4 tabel master (pelanggan, admin_rental, supir, mobil)
-- 2 tabel transaksi (sewa, bayar)
-- ============================================================

-- ============ TABEL MASTER ============

CREATE TABLE pelanggan (
    id_pelanggan     NUMBER PRIMARY KEY,
    nama_pelanggan   VARCHAR2(100) NOT NULL,
    email_pelanggan  VARCHAR2(100) NOT NULL,
    telp_pelanggan   VARCHAR2(15),
    alamat_pelanggan VARCHAR2(255),
    foto_ktp         VARCHAR2(255),
    kata_sandi       VARCHAR2(255),
    created_at       DATE DEFAULT SYSDATE
);

CREATE TABLE admin_rental (
    id_admin    NUMBER PRIMARY KEY,
    nama_admin  VARCHAR2(100) NOT NULL,
    email_admin VARCHAR2(100) NOT NULL,
    telp_admin  VARCHAR2(15),
    kata_sandi  VARCHAR2(255),
    role        VARCHAR2(20) DEFAULT 'ADMIN',
    created_at  DATE DEFAULT SYSDATE
);

CREATE TABLE supir (
    id_supir     NUMBER PRIMARY KEY,
    nama_supir   VARCHAR2(100) NOT NULL,
    email_supir  VARCHAR2(100),
    telp_supir   VARCHAR2(15),
    alamat_supir VARCHAR2(255),
    sim_supir    VARCHAR2(50),
    created_at   DATE DEFAULT SYSDATE
);

CREATE TABLE mobil (
    id_mobil             NUMBER PRIMARY KEY,
    tipe                 VARCHAR2(50) NOT NULL,
    merk                 VARCHAR2(50) NOT NULL,
    mesin                VARCHAR2(50),
    nomor_polisi         VARCHAR2(20) NOT NULL,
    harga_sewa           NUMBER(12,2) NOT NULL,
    harga_dp             NUMBER(12,2),
    status_ketersediaan  VARCHAR2(20) DEFAULT 'TERSEDIA',
    created_at           DATE DEFAULT SYSDATE
);

-- ============ TABEL TRANSAKSI ============

CREATE TABLE sewa (
    id_sewa       NUMBER PRIMARY KEY,
    id_pelanggan  NUMBER NOT NULL,
    id_mobil      NUMBER NOT NULL,
    id_supir      NUMBER,                 -- nullable: sewa boleh tanpa supir
    id_admin      NUMBER NOT NULL,
    tgl_ambil     DATE NOT NULL,
    tgl_kembali   DATE NOT NULL,
    jam_ambil     VARCHAR2(5),
    jam_kembali   VARCHAR2(5),
    alamat_ambil  VARCHAR2(255),
    pakai_supir   NUMBER(1) DEFAULT 0,
    denda         NUMBER(12,2) DEFAULT 0,
    status_sewa   VARCHAR2(20) DEFAULT 'AKTIF',
    catatan       VARCHAR2(500),
    created_at    DATE DEFAULT SYSDATE,
    CONSTRAINT fk_sewa_pelanggan FOREIGN KEY (id_pelanggan) REFERENCES pelanggan(id_pelanggan),
    CONSTRAINT fk_sewa_mobil     FOREIGN KEY (id_mobil)     REFERENCES mobil(id_mobil),
    CONSTRAINT fk_sewa_supir     FOREIGN KEY (id_supir)     REFERENCES supir(id_supir),
    CONSTRAINT fk_sewa_admin     FOREIGN KEY (id_admin)     REFERENCES admin_rental(id_admin)
);

CREATE TABLE bayar (
    id_bayar        NUMBER PRIMARY KEY,
    id_sewa         NUMBER NOT NULL,
    id_admin        NUMBER NOT NULL,
    metode_bayar    VARCHAR2(30),
    dp_awal         NUMBER(12,2) DEFAULT 0,
    sisa_bayar      NUMBER(12,2) DEFAULT 0,
    total_bayar     NUMBER(12,2) NOT NULL,
    tgl_bayar       DATE DEFAULT SYSDATE,
    status_bayar    VARCHAR2(20) DEFAULT 'LUNAS',
    bukti_transfer  VARCHAR2(255),
    CONSTRAINT fk_bayar_sewa  FOREIGN KEY (id_sewa)  REFERENCES sewa(id_sewa),
    CONSTRAINT fk_bayar_admin FOREIGN KEY (id_admin) REFERENCES admin_rental(id_admin)
);
