-- VIEW'ın var olup olmadığını kontrol et
IF OBJECT_ID('viewEnÇokOynananUlke') IS NOT NULL
	BEGIN
	    -- bu isimde VIEW varsa sil
		DROP VIEW viewEnÇokOynananUlke;
	END
GO



-- oyunların hangi ülkede en çok oynandığını, o ülkeye ait oyuncu sayısını ve oyuncuların yaş gruplarını gösteren view
CREATE VIEW viewEnÇokOynananUlke
AS
SELECT 
    o.OYUN_ASILAD,
    COUNT(*) AS ToplamOyuncu,
    CASE 
        WHEN YEAR(GETDATE()) - YEAR(u.DOGUMTARIHI) BETWEEN 18 AND 25 THEN '18-25'
        WHEN YEAR(GETDATE()) - YEAR(u.DOGUMTARIHI) BETWEEN 26 AND 35 THEN '26-35'
        ELSE '35+'
    END AS YasGrubu,
    dbo.fncEnÇokOynananUlke(o.OYUN_ID) AS EnCokOynananUlke
FROM 
    tblKoleksiyon k
INNER JOIN tbloyun o ON k.OYUN_ID = o.OYUN_ID
INNER JOIN tblUye u ON k.UYE_ID = u.UYE_ID
GROUP BY 
    o.OYUN_ASILAD,
    CASE 
        WHEN YEAR(GETDATE()) - YEAR(u.DOGUMTARIHI) BETWEEN 18 AND 25 THEN '18-25'
        WHEN YEAR(GETDATE()) - YEAR(u.DOGUMTARIHI) BETWEEN 26 AND 35 THEN '26-35'
        ELSE '35+'
    END;

GO




------

CREATE VIEW viewEnÇokOynananUlke
AS
SELECT 
    o.OYUN_ASILAD,
    COUNT(*) AS ToplamOyuncu,
    CASE 
        WHEN YEAR(GETDATE()) - YEAR(u.DOGUMTARIHI) BETWEEN 18 AND 25 THEN '18-25'
        WHEN YEAR(GETDATE()) - YEAR(u.DOGUMTARIHI) BETWEEN 26 AND 35 THEN '26-35'
        ELSE '35+'
    END AS YasGrubu,
    enCokUlke.EnCokOynananUlke
FROM 
    tblKoleksiyon k
INNER JOIN tbloyun o ON k.OYUN_ID = o.OYUN_ID
INNER JOIN tblUye u ON k.UYE_ID = u.UYE_ID
CROSS APPLY (SELECT dbo.fncEnÇokOynananUlke(o.OYUN_ID) AS EnCokOynananUlke) enCokUlke
GROUP BY 
    o.OYUN_ASILAD,
    CASE 
        WHEN YEAR(GETDATE()) - YEAR(u.DOGUMTARIHI) BETWEEN 18 AND 25 THEN '18-25'
        WHEN YEAR(GETDATE()) - YEAR(u.DOGUMTARIHI) BETWEEN 26 AND 35 THEN '26-35'
        ELSE '35+'
    END,
    enCokUlke.EnCokOynananUlke;
GO



-- Test: View'ı kullanarak oyun türüne, tasarımcıya ve oyuncu yaş gruplarına göre veri çeken sorgu
SELECT 
	o.OYUN_ASILAD,
    ec.YasGrubu,
    ec.ToplamOyuncu,
    ec.EnCokOynananUlke,
    t.TASARIMCI_AD -- Tasarımcı adı
FROM 
    viewEnÇokOynananUlke ec
INNER JOIN tbloyun o ON ec.OYUN_ASILAD = o.OYUN_ASILAD
INNER JOIN tbloyuntasarimci ot ON o.OYUN_ID = ot.OYUN_ID -- Oyun ile tasarımcı arasındaki ilişkiyi ekledik
INNER JOIN tblTasarimci t ON ot.TASARIMCI_ID = t.TASARIMCI_ID -- Tasarımcı bilgilerini alıyoruz
INNER JOIN tbloyun_tur otr ON otr.OYUN_ID = o.OYUN_ID
INNER JOIN tbltur tur ON tur.TUR_ID = otr.TUR_ID
WHERE 
    otr.TUR_ID = 1  -- Oyun türüne göre filtreleme
ORDER BY 
    o.OYUN_ASILAD, ec.ToplamOyuncu DESC;
	








CREATE VIEW viewEnÇokOynananUlke
AS
with encokoynanan as (
select 
Oyun_ıd,
dbo.fncEnÇokOynananUlke(o.OYUN_ID) AS EnCokOynananUlke
from tbloyun

)
SELECT 
    o.OYUN_ASILAD,
    COUNT(*) AS ToplamOyuncu,
    CASE 
        WHEN YEAR(GETDATE()) - YEAR(u.DOGUMTARIHI) BETWEEN 18 AND 25 THEN '18-25'
        WHEN YEAR(GETDATE()) - YEAR(u.DOGUMTARIHI) BETWEEN 26 AND 35 THEN '26-35'
        ELSE '35+'
    END AS YasGrubu,
	e.EnCokOynananUlke

FROM 
    tblKoleksiyon k
INNER JOIN tbloyun o ON k.OYUN_ID = o.OYUN_ID
INNER JOIN tblUye u ON k.UYE_ID = u.UYE_ID
inner join encokoynanan e on o.OYUN_ID = e.OYUN_ID
GROUP BY 
    o.OYUN_ASILAD,
    CASE 
        WHEN YEAR(GETDATE()) - YEAR(u.DOGUMTARIHI) BETWEEN 18 AND 25 THEN '18-25'
        WHEN YEAR(GETDATE()) - YEAR(u.DOGUMTARIHI) BETWEEN 26 AND 35 THEN '26-35'
        ELSE '35+'
    END;

GO
