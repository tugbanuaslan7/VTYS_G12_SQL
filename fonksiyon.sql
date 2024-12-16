use boardgame

-- Fonksiyonun var olup olmadýðýný kontrol et
IF OBJECT_ID ( 'fncEnÇokOynananUlke') IS NOT NULL
	BEGIN
		-- Fonksiyon varsa sil
		DROP FUNCTION fncEnÇokOynananUlke;
	END
GO

-- Verilen OyunId parametresine göre en çok oynanan ülkeyi döndüren fonksiyon
-- Parametre olarak alýnan OyunId'ye baðlý olarak 'Koleksiyonlar' ve 'Kullanicilar' tablolarýndaki
-- kullanýcýlarýn ülkelerini gruplar ve en fazla kullanýcýya sahip olan ülkeyi belirler.

CREATE FUNCTION fncEnÇokOynananUlke(@OyunId INT)
RETURNS VARCHAR(50)
AS
	BEGIN
		-- Fonksiyonda kullanýlacak olan 'EnÇokOynananUlke' deðiþkenini tanýmla
		DECLARE @EnÇokOynananUlke VARCHAR(50)

		-- 'Koleksiyonlar' tablosundaki verilen 'OyunId' için, her ülkenin kaç kez göründüðünü say
		-- 'Kullanicilar' tablosuyla inner join yaparak, kullanýcýlarýn ülkelerine göre grupla
		-- En çok sayýda kullanýcýya sahip olan ülkeyi seçer ve 'EnÇokOynananUlke' deðiþkenine ata
		SELECT TOP 1 
			@EnÇokOynananUlke = u.ULKE_ID   -- Bu ülkeyi deðiþkene ata
		FROM 
			tblKoleksiyon k
		INNER JOIN tblUye u ON k.UYE_ID = u.UYE_ID
		WHERE 
			k.OYUN_ID = @OyunId  -- Parametre olarak alýnan oyun ID'si ile filtreleme yapýlýr
		GROUP BY 
			u.ULKE_ID  -- Ülkelere göre gruplanýr
		ORDER BY 
			COUNT(*) DESC;  -- En fazla kullanýcýya sahip ülke önce gelir

		-- Hesaplanan en çok oynanan ülke geri döndür
		RETURN @EnÇokOynananUlke;
	END
GO


-- OyunID'si 1 olan oyununun en çok hangi ülkede oynandýðýný bulan sorgu
SELECT dbo.fncEnÇokOynananUlke(1) AS EnCokOynananUlke;
