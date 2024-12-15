-- Fonksiyonun var olup olmad���n� kontrol eder
IF OBJECT_ID ( 'En�okOynananUlke')
	BEGIN
		-- Fonksiyon varsa, siler
		DROP FUNCTION En�okOynananUlke;
	END
GO

-- Bu fonksiyon, verilen OyunId parametresine g�re en �ok oynanan �lkeyi d�nd�r�r.
-- Parametre olarak al�nan OyunId'ye ba�l� olarak, 'Koleksiyonlar' ve 'Kullanicilar' tablolar�ndaki
-- kullan�c�lar�n �lkelerini gruplar ve en fazla kullan�c�ya sahip olan �lkeyi belirler.

CREATE FUNCTION En�okOynananUlke(@OyunId INT)
RETURNS VARCHAR(50)
AS
	BEGIN
		-- Fonksiyonda kullan�lacak olan 'En�okOynananUlke' de�i�kenini tan�mlar.
		DECLARE @En�okOynananUlke VARCHAR(50)

		-- 'Koleksiyonlar' tablosundaki verilen 'OyunId' i�in, her �lkenin ka� kez g�r�nd���n� sayar.
		-- 'Kullanicilar' tablosuyla i� join yaparak, kullan�c�lar�n �lkelerine g�re gruplar.
		-- Ard�ndan, en �ok say�da kullan�c�ya sahip olan �lkeyi se�er ve 'En�okOynananUlke' de�i�kenine atar.
		SELECT TOP 1 
			u.Ulke = @En�okOynananUlke  -- Bu �lkeyi de�i�kene atar
		FROM 
			Koleksiyonlar k
		INNER JOIN Kullanicilar u ON k.KullaniciId = u.KullaniciId
		WHERE 
			k.OyunId = @OyunId  -- Parametre olarak al�nan oyun ID'si ile filtreleme yap�l�r
		GROUP BY 
			u.Ulke  -- �lkelere g�re gruplan�r
		ORDER BY 
			COUNT(*) DESC;  -- En fazla kullan�c�ya sahip �lke �nce gelir

		-- Hesaplanan en �ok oynanan �lke geri d�nd�r�l�r.
		RETURN @En�okOynananUlke;
	END



-- OyunID'si 1 olan oyununun en �ok hangi �lkede oynand���n� bulan sorgu
SELECT dbo.En�okOynananUlke(1) AS EnCokOynananUlke;
