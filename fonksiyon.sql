use boardgame

-- Fonksiyonun var olup olmad���n� kontrol et
IF OBJECT_ID ( 'fncEn�okOynananUlke') IS NOT NULL
	BEGIN
		-- Fonksiyon varsa sil
		DROP FUNCTION fncEn�okOynananUlke;
	END
GO

-- Verilen OyunId parametresine g�re en �ok oynanan �lkeyi d�nd�ren fonksiyon
-- Parametre olarak al�nan OyunId'ye ba�l� olarak 'Koleksiyonlar' ve 'Kullanicilar' tablolar�ndaki
-- kullan�c�lar�n �lkelerini gruplar ve en fazla kullan�c�ya sahip olan �lkeyi belirler.

CREATE FUNCTION fncEn�okOynananUlke(@OyunId INT)
RETURNS VARCHAR(50)
AS
	BEGIN
		-- Fonksiyonda kullan�lacak olan 'En�okOynananUlke' de�i�kenini tan�mla
		DECLARE @En�okOynananUlke VARCHAR(50)

		-- 'Koleksiyonlar' tablosundaki verilen 'OyunId' i�in, her �lkenin ka� kez g�r�nd���n� say
		-- 'Kullanicilar' tablosuyla inner join yaparak, kullan�c�lar�n �lkelerine g�re grupla
		-- En �ok say�da kullan�c�ya sahip olan �lkeyi se�er ve 'En�okOynananUlke' de�i�kenine ata
		SELECT TOP 1 
			@En�okOynananUlke = u.ULKE_ID   -- Bu �lkeyi de�i�kene ata
		FROM 
			tblKoleksiyon k
		INNER JOIN tblUye u ON k.UYE_ID = u.UYE_ID
		WHERE 
			k.OYUN_ID = @OyunId  -- Parametre olarak al�nan oyun ID'si ile filtreleme yap�l�r
		GROUP BY 
			u.ULKE_ID  -- �lkelere g�re gruplan�r
		ORDER BY 
			COUNT(*) DESC;  -- En fazla kullan�c�ya sahip �lke �nce gelir

		-- Hesaplanan en �ok oynanan �lke geri d�nd�r
		RETURN @En�okOynananUlke;
	END
GO


-- OyunID'si 1 olan oyununun en �ok hangi �lkede oynand���n� bulan sorgu
SELECT dbo.fncEn�okOynananUlke(1) AS EnCokOynananUlke;
