CREATE DATABASE Game1
/* tek bir sıkınntı var create rozet tablosuna uye_ıd eklenecek ve uye_sahiptir_rozet tablosu silincek*/
USE Game1;
GO

-- Gerekli tabloları oluştur
CREATE TABLE tblKoleksiyon (
    KOLEKSIYON_ID INT IDENTITY(1,1),
    UYE_ID INT,
    OYUN_ID INT
);

CREATE TABLE tblUye (
    UYE_ID INT PRIMARY KEY,
    UYE_AD NVARCHAR(50)
);

CREATE TABLE tblOyun (
    OYUN_ID INT PRIMARY KEY,
    OYUN_AD NVARCHAR(50)
);

CREATE TABLE tblRozet (
    ROZET_ID INT IDENTITY(1,1),
    ROZET_AD NVARCHAR(50),
    UYE_ID INT
);

CREATE TABLE tblProfilGuncelleme (
    PROFIL_ID INT IDENTITY(1,1),
    UYE_ID INT,
    ToplamOyunSayisi INT,
    SonGuncellemeTarihi DATETIME
);

-- Test verilerini ekle
INSERT INTO tblUye (UYE_ID, UYE_AD)
VALUES (1, 'Ali'), (2, 'Ayşe');

INSERT INTO tblOyun (OYUN_ID, OYUN_AD)
VALUES (1, 'Oyun A'), (2, 'Oyun B'), (3, 'Oyun C');



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
        -- INSERTED veya DELETED tablosundan kullanıcı bilgilerini al
        IF EXISTS (SELECT 1 FROM INSERTED)
            SELECT TOP 1 @uyeId = UYE_ID FROM INSERTED;
        ELSE IF EXISTS (SELECT 1 FROM DELETED)
            SELECT TOP 1 @uyeId = UYE_ID FROM DELETED;

        -- Kullanıcının var olup olmadığını kontrol et
        IF NOT EXISTS (SELECT 1 FROM tblUye WHERE UYE_ID = @uyeId)
            THROW 50005, 'Geçersiz kullanıcı ID. İşlem iptal edildi.', 1;

        -- Koleksiyona eklenen/verilen oyunların geçerli olup olmadığını kontrol et
        IF EXISTS (
            SELECT 1
            FROM INSERTED i
            WHERE NOT EXISTS (SELECT 1 FROM tblOyun o WHERE o.OYUN_ID = i.OYUN_ID)
        )
            THROW 50006, 'Eklenmek istenen oyunlardan biri geçerli değil.', 1;

        IF EXISTS (
            SELECT 1
            FROM DELETED d
            WHERE NOT EXISTS (SELECT 1 FROM tblOyun o WHERE o.OYUN_ID = d.OYUN_ID)
        )
            THROW 50007, 'Silinmek istenen oyunlardan biri geçerli değil.', 1;

        -- Kullanıcının toplam oyun sayısını hesapla
        SELECT @toplamOyunSayisi = COUNT(*)
        FROM tblKoleksiyon
        WHERE UYE_ID = @uyeId;

        -- Kullanıcının oyun sayısına göre işlem kontrolü
        IF @toplamOyunSayisi > 1000
            THROW 50008, 'Maksimum koleksiyon sınırı aşıldı. İşlem iptal edildi.', 1;

        -- Eski rozetleri sil
        DELETE FROM tblRozet
        WHERE UYE_ID = @uyeId;

        -- Yeni rozet ekle
        IF @toplamOyunSayisi >= 1000
            INSERT INTO tblRozet (ROZET_AD, UYE_ID)
            VALUES ('Efsane Koleksiyoncu', @uyeId);
        ELSE IF @toplamOyunSayisi >= 500
            INSERT INTO tblRozet (ROZET_AD, UYE_ID)
            VALUES ('Usta Koleksiyoncu', @uyeId);
        ELSE IF @toplamOyunSayisi >= 100
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


-- Koleksiyona oyun ekle
INSERT INTO tblKoleksiyon (UYE_ID, OYUN_ID)
VALUES (1, 1);

-- Sonuçları kontrol et
SELECT * FROM tblRozet; -- Rozet eklendi mi?
SELECT * FROM tblProfilGuncelleme; -- Profil güncellendi mi?



-- Koleksiyona geçersiz oyun ekle
BEGIN TRY
    INSERT INTO tblKoleksiyon (UYE_ID, OYUN_ID)
    VALUES (1, 999); -- 999 mevcut olmayan bir oyun ID
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS HataMesaji;
END CATCH;





-- Koleksiyondan oyun sil
DELETE FROM tblKoleksiyon
WHERE UYE_ID = 1 AND OYUN_ID = 1;

-- Sonuçları kontrol et
SELECT * FROM tblRozet; -- Rozet kaldırıldı mı?
SELECT * FROM tblProfilGuncelleme; -- Profil güncellendi mi?



-- Kullanıcıya 1001 oyun ekleyerek sınırı aşmayı dene
BEGIN TRY
    DECLARE @i INT = 1;
    WHILE @i <= 1001
    BEGIN
        INSERT INTO tblKoleksiyon (UYE_ID, OYUN_ID)
        VALUES (1, 1);
        SET @i = @i + 1;
    END
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS HataMesaji;
END CATCH;





-- Kullanıcıya farklı rozet seviyeleri için oyun ekle
DELETE FROM tblKoleksiyon WHERE UYE_ID = 1;

-- 100 oyun ekle (Amatör Koleksiyoncu)
DECLARE @i INT = 1;
WHILE @i <= 100
BEGIN
    INSERT INTO tblKoleksiyon (UYE_ID, OYUN_ID)
    VALUES (1, 1);
    SET @i = @i + 1;
END
SELECT * FROM tblRozet;

-- 500 oyun ekle (Usta Koleksiyoncu)
WHILE @i <= 500
BEGIN
    INSERT INTO tblKoleksiyon (UYE_ID, OYUN_ID)
    VALUES (1, 1);
    SET @i = @i + 1;
END
SELECT * FROM tblRozet;

-- 1000 oyun ekle (Efsane Koleksiyoncu)
WHILE @i <= 1000
BEGIN
    INSERT INTO tblKoleksiyon (UYE_ID, OYUN_ID)
    VALUES (1, 1);
    SET @i = @i + 1;
END
SELECT * FROM tblRozet;

