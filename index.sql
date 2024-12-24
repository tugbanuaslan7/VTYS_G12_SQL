-- 1. Veritabanını oluştur
CREATE DATABASE OyunVeritabani;
GO

-- Veritabanına bağlan
USE OyunVeritabani;
GO

-- 2. Tablonun oluşturulması
CREATE TABLE tblOyun (
    OYUN_ID INT IDENTITY(1,1) PRIMARY KEY, -- Otomatik artan birincil anahtar
    OYUN_ASILAD NVARCHAR(255) NOT NULL,
    YAYINLANDIGI_YIL DATE NOT NULL,
    OY_VEREN_KULLANICI_SAYISI INT NOT NULL,
    KATEGORI NVARCHAR(50)
);
GO

-- 3. Örnek verilerin eklenmesi
INSERT INTO tblOyun (OYUN_ASILAD, YAYINLANDIGI_YIL, OY_VEREN_KULLANICI_SAYISI, KATEGORI) VALUES 
('The Witcher 3: Wild Hunt', '2015-05-19', 5000000, 'RPG'),
('Cyberpunk 2077', '2020-12-10', 2300000, 'RPG'),
('Minecraft', '2011-11-18', 20000000, 'Sandbox'),
('Grand Theft Auto V', '2013-09-17', 10000000, 'Action'),
('Fortnite', '2017-07-25', 8000000, 'Battle Royale'),
('Among Us', '2018-11-16', 3000000, 'Party'),
('Elden Ring', '2022-02-25', 4000000, 'RPG'),
('League of Legends', '2009-10-27', 15000000, 'MOBA'),
('Valorant', '2020-06-02', 5000000, 'Shooter'),
('PUBG: Battlegrounds', '2017-03-23', 12000000, 'Battle Royale'),
('Overwatch 2', '2022-10-04', 700000, 'Shooter'),
('The Legend of Zelda: Breath of the Wild', '2017-03-03', 6000000, 'Adventure');
GO

-- 4. Performans testi (INDEX OLMADAN)
-- İlk sorgu: İndeks oluşturulmadan sorgu performansı testi
SET STATISTICS IO ON;

SELECT 
    OYUN_ID, OYUN_ASILAD, YAYINLANDIGI_YIL, OY_VEREN_KULLANICI_SAYISI
FROM 
    tblOyun
WHERE 
    YAYINLANDIGI_YIL > '2010-01-01'
    AND OY_VEREN_KULLANICI_SAYISI > 1000;
GO

-- İstatistiklerin kapatılması
SET STATISTICS IO OFF;
GO

-- 5. İndeks oluşturma
CREATE NONCLUSTERED INDEX IX_tblOyun_Yil_KullaniciSayisi
ON tblOyun (YAYINLANDIGI_YIL, OY_VEREN_KULLANICI_SAYISI)
INCLUDE (OYUN_ASILAD);
GO

-- 6. Performans testi (INDEX SONRASI)
-- Aynı sorgunun indeks oluşturulduktan sonraki performansı
SET STATISTICS IO ON;

SELECT 
    OYUN_ID, OYUN_ASILAD, YAYINLANDIGI_YIL, OY_VEREN_KULLANICI_SAYISI
FROM 
    tblOyun
WHERE 
    YAYINLANDIGI_YIL > '2010-01-01'
    AND OY_VEREN_KULLANICI_SAYISI > 1000;
GO

-- İstatistiklerin kapatılması
SET STATISTICS IO OFF;
GO
