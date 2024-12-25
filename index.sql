
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
