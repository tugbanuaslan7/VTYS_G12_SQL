-- Fonksiyonun var olup olmadýðýný kontrol eder
IF OBJECT_ID ( 'EnÇokOynananUlke')
	BEGIN
		-- Fonksiyon varsa, siler
		DROP FUNCTION EnÇokOynananUlke;
	END
GO

-- Bu fonksiyon, verilen OyunId parametresine göre en çok oynanan ülkeyi döndürür.
-- Parametre olarak alýnan OyunId'ye baðlý olarak, 'Koleksiyonlar' ve 'Kullanicilar' tablolarýndaki
-- kullanýcýlarýn ülkelerini gruplar ve en fazla kullanýcýya sahip olan ülkeyi belirler.

CREATE FUNCTION EnÇokOynananUlke(@OyunId INT)
RETURNS VARCHAR(50)
AS
	BEGIN
		-- Fonksiyonda kullanýlacak olan 'EnÇokOynananUlke' deðiþkenini tanýmlar.
		DECLARE @EnÇokOynananUlke VARCHAR(50)

		-- 'Koleksiyonlar' tablosundaki verilen 'OyunId' için, her ülkenin kaç kez göründüðünü sayar.
		-- 'Kullanicilar' tablosuyla iç join yaparak, kullanýcýlarýn ülkelerine göre gruplar.
		-- Ardýndan, en çok sayýda kullanýcýya sahip olan ülkeyi seçer ve 'EnÇokOynananUlke' deðiþkenine atar.
		SELECT TOP 1 
			u.Ulke = @EnÇokOynananUlke  -- Bu ülkeyi deðiþkene atar
		FROM 
			Koleksiyonlar k
		INNER JOIN Kullanicilar u ON k.KullaniciId = u.KullaniciId
		WHERE 
			k.OyunId = @OyunId  -- Parametre olarak alýnan oyun ID'si ile filtreleme yapýlýr
		GROUP BY 
			u.Ulke  -- Ülkelere göre gruplanýr
		ORDER BY 
			COUNT(*) DESC;  -- En fazla kullanýcýya sahip ülke önce gelir

		-- Hesaplanan en çok oynanan ülke geri döndürülür.
		RETURN @EnÇokOynananUlke;
	END



-- OyunID'si 1 olan oyununun en çok hangi ülkede oynandýðýný bulan sorgu
SELECT dbo.EnÇokOynananUlke(1) AS EnCokOynananUlke;
