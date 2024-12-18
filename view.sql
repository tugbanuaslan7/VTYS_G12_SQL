-- VIEW'ın var olup olmadığını kontrol et
IF OBJECT_ID('vEnÇokOynananUlkeler') IS NOT NULL
	BEGIN
	    -- VIEW varsa sil
		DROP VIEW vEnÇokOynananUlkeler;
	END
GO

use boardgame

-- oyunların hangi ülkede en çok oynandığını, o ülkeye ait oyuncu sayısını ve oyuncuların yaş gruplarını gösteren view
CREATE VIEW EnCokOynananOyunlarByTurVeYas
AS
SELECT 
    o.OyunAdi,
    COUNT(*) AS ToplamOyuncu,
    CASE 
        WHEN YEAR(GETDATE()) - YEAR(u.DogumTarihi) BETWEEN 18 AND 25 THEN '18-25'
        WHEN YEAR(GETDATE()) - YEAR(u.DogumTarihi) BETWEEN 26 AND 35 THEN '26-35'
        ELSE '35+'
    END AS YasGrubu,
    dbo.EnCokOynananUlke(o.OyunID) AS EnCokOynananUlke
FROM 
    Koleksiyonlar k
INNER JOIN Oyunlar o ON k.OyunID = o.OyunID
INNER JOIN Kullanicilar u ON k.KullaniciId = u.KullaniciId
GROUP BY 
    o.OyunAdi,
    CASE 
        WHEN YEAR(GETDATE()) - YEAR(u.DogumTarihi) BETWEEN 18 AND 25 THEN '18-25'
        WHEN YEAR(GETDATE()) - YEAR(u.DogumTarihi) BETWEEN 26 AND 35 THEN '26-35'
        ELSE '35+'
    END;

GO

-- Test: View'ı kullanarak oyun türüne, tasarımcıya ve oyuncu yaş gruplarına göre veri çeken sorgu
SELECT 
    o.OyunAdi,
    ec.YasGrubu,
    ec.ToplamOyuncu,
    ec.EnCokOynananUlke,
    t.TasarimciAdi -- Tasarımcı adı
FROM 
    EnCokOynananOyunlarByTurVeYas ec
INNER JOIN Oyunlar o ON ec.OyunAdi = o.OyunAdi
INNER JOIN tbloyuntasarimci ot ON o.OyunID = ot.OYUN_ID -- Oyun ile tasarımcı arasındaki ilişkiyi ekledik
INNER JOIN tbltasarimci t ON ot.TASARIMCI_ID = t.TASARIMCI_ID -- Tasarımcı bilgilerini alıyoruz
WHERE 
    o.OyunTuru = 'Aksiyon'  -- Oyun türüne göre filtreleme
ORDER BY 
    ec.YasGrubu, ec.ToplamOyuncu DESC;

