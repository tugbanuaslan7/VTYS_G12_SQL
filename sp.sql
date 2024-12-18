CREATE PROCEDURE RozetleriGuncelle
    @BaslangicTarihi DATETIME,
    @BitisTarihi DATETIME
AS
BEGIN
    -- Transaction başlatılıyor
    BEGIN TRANSACTION;

    BEGIN TRY
        -- En çok takipçi kazanan kullanıcıyı bulma
        DECLARE @EnCokTakipciKazanacakId INT;
        SELECT TOP 1 @EnCokTakipciKazanacakId = KullaniciId
        FROM tblTakipci
        WHERE TakipTarihi BETWEEN @BaslangicTarihi AND @BitisTarihi
        GROUP BY KullaniciId
        ORDER BY COUNT(*) DESC;

        -- En çok beğenilen kullanıcıyı bulma
        DECLARE @EnCokBegeniAlanId INT;
        SELECT TOP 1 @EnCokBegeniAlanId = KullaniciId
        FROM tblBegeni
        WHERE BegeniTarihi BETWEEN @BaslangicTarihi AND @BitisTarihi
        GROUP BY KullaniciId
        ORDER BY COUNT(*) DESC;

        -- En çok takipçi kazanan kullanıcının rozetini silme
        IF EXISTS (SELECT 1 FROM tblRozet WHERE KullaniciId = @EnCokTakipciKazanacakId AND RozetAd = 'En Çok Takipçi Kazanan')
        BEGIN
            DELETE FROM tblRozet WHERE KullaniciId = @EnCokTakipciKazanacakId AND RozetAd = 'En Çok Takipçi Kazanan';
        END

        -- En çok beğenilen kullanıcının rozetini silme
        IF EXISTS (SELECT 1 FROM tblRozet WHERE KullaniciId = @EnCokBegeniAlanId AND RozetAd = 'En Çok Beğenilen')
        BEGIN
            DELETE FROM tblRozet WHERE KullaniciId = @EnCokBegeniAlanId AND RozetAd = 'En Çok Beğenilen';
        END

        -- En çok takipçi kazanan kullanıcıya rozet ekleme
        INSERT INTO tblRozet (KullaniciId, RozetAd, RozetTarihi)
        VALUES (@EnCokTakipciKazanacakId, 'En Çok Takipçi Kazanan', GETDATE());

        -- En çok beğenilen kullanıcıya rozet ekleme
        INSERT INTO tblRozet (KullaniciId, RozetAd, RozetTarihi)
        VALUES (@EnCokBegeniAlanId, 'En Çok Beğenilen', GETDATE());

        -- İşlemler başarılı olduğunda transaction commit ediliyor
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Hata durumunda transaction geri alınıyor
        ROLLBACK TRANSACTION;

        -- Hata mesajı döndürülüyor
        THROW;
    END CATCH
END;
