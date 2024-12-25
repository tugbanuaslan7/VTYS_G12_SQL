IF OBJECT_ID('trg_KoleksiyonRozetVeProfilGuncelleme') IS NOT NULL
	BEGIN
	    DROP TRIGGER trg_KoleksiyonRozetVeProfilGuncelleme;
	END
GO



CREATE TABLE tblProfilGuncelleme (
    PROFIL_ID INT IDENTITY(1,1),
    UYE_ID INT,
    ToplamOyunSayisi INT,
    SonGuncellemeTarihi DATETIME
);


CREATE TRIGGER trg_KoleksiyonRozetVeProfilGuncelleme
ON tblKoleksiyon
AFTER INSERT, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Değişkenler
    DECLARE @uyeId INT;
    DECLARE @toplamOyunSayisi INT;

    BEGIN TRANSACTION;

    BEGIN TRY
      
        -- Kullanıcının toplam oyun sayısını hesapla
        SELECT @toplamOyunSayisi = COUNT(*)
        FROM tblKoleksiyon
        WHERE UYE_ID = @uyeId;

        -- Kullanıcının oyun sayısına göre işlem kontrolü
        IF @toplamOyunSayisi > 14
            THROW 50008, 'Koleksiyona eklenen maksimum oyun sınırı aşıldı. İşlem iptal edildi.', 1;

        -- Eski rozetleri sil
        DELETE FROM tblRozet
        WHERE UYE_ID = @uyeId;

        -- Yeni rozet ekle
        IF @toplamOyunSayisi >= 12
            INSERT INTO tblRozet (ROZET_AD, UYE_ID)
            VALUES ('Efsane Koleksiyoncu', @uyeId);
        ELSE IF @toplamOyunSayisi >= 4
            INSERT INTO tblRozet (ROZET_AD, UYE_ID)
            VALUES ('Usta Koleksiyoncu', @uyeId);
        ELSE IF @toplamOyunSayisi >= 3
            INSERT INTO tblRozet (ROZET_AD, UYE_ID)
            VALUES ('Amatör Koleksiyoncu', @uyeId);

        -- tblProfilGuncelleme tablosunu güncelle
        IF EXISTS (SELECT 1 FROM tblProfilGuncelleme WHERE UYE_ID = @uyeId)
        BEGIN
            UPDATE tblProfilGuncelleme
            SET ToplamOyunSayisi = @toplamOyunSayisi,
                SonGuncellemeTarihi = GETDATE()
            WHERE UYE_ID = @uyeId;
        END
        ELSE
        BEGIN
            INSERT INTO tblProfilGuncelleme (UYE_ID, ToplamOyunSayisi, SonGuncellemeTarihi)
            VALUES (@uyeId, @toplamOyunSayisi, GETDATE());
        END;

        -- İşlemleri tamamla
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Hata durumunda rollback yap
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Hata bilgilerini döndür
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH;
END;


