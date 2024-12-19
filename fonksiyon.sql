use boardgame

-- Fonksiyonun var olup olmadığını kontrol et
IF OBJECT_ID ( 'fncEnÇokOynananUlke') IS NOT NULL
	BEGIN
		-- Fonksiyon varsa sil
		DROP FUNCTION fncEnÇokOynananUlke;
	END
GO

-- Verilen OyunId parametresine göre bu oyunu en çok oynayan ülkeyi döndüren fonksiyon
-- Parametre olarak alınan OyunId'ye bağlı olarak 'Koleksiyonlar' ve 'Kullanicilar' tablolarındaki
-- kullanıcıların ülkelerini gruplar ve en fazla kullanıcıya sahip olan ülkeyi belirler.

CREATE FUNCTION fncEnÇokOynananUlke(@OyunId INT)
RETURNS VARCHAR(50)
AS
	BEGIN
		-- Fonksiyonda kullanılacak olan 'EnÇokOynananUlke' değişkenini tanımla
		DECLARE @EnÇokOynananUlke VARCHAR(50)

		-- 'Koleksiyonlar' tablosundaki verilen 'OyunId' için, her ülkenin kaç kez göründüğünü say
		-- 'Kullanicilar' tablosuyla inner join yaparak, kullanıcıların ülkelerine göre grupla
		-- En çok sayıda kullanıcıya sahip olan ülkeyi seçer ve 'EnÇokOynananUlke' değişkenine ata
		SELECT TOP 1 
			@EnÇokOynananUlke = u.ULKE_ID   -- Bu ülkeyi değişkene ata
		FROM 
			tblKoleksiyon k
		INNER JOIN tblUye u ON k.UYE_ID = u.UYE_ID
		WHERE 
			k.OYUN_ID = @OyunId  -- Parametre olarak alınan oyun ID'si ile filtreleme yapılır
		GROUP BY 
			u.ULKE_ID  -- Ülkelere göre gruplanır
		ORDER BY 
			COUNT(*) DESC;  -- En fazla kullanıcıya sahip ülke önce gelir

		-- Hesaplanan en çok oynanan ülke geri döndür
		RETURN @EnÇokOynananUlke;
	END
GO


-- OyunID'si 1 olan oyununun en çok hangi ülkede oynandığını bulan sorgu
SELECT dbo.fncEnÇokOynananUlke(1) AS EnCokOynananUlke;
