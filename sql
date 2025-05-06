-- Jeśli kolumna nie istnieje, dodaj ją
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'User_Settings' 
               AND COLUMN_NAME = 'load_all_events_on_unselect')
BEGIN
    ALTER TABLE [dbo].[User_Settings]
    ADD load_all_events_on_unselect BIT NOT NULL DEFAULT 1
END

CREATE OR ALTER PROCEDURE [dbo].[SaveUserSettings]
    @username NVARCHAR(255),
    @theme NVARCHAR(50),
    @font_family NVARCHAR(100),
    @font_size INT,
    @load_all_events BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    -- Sprawdź, czy istnieje wpis dla danego użytkownika
    IF EXISTS (SELECT 1 FROM [dbo].[User_Settings] WHERE [Username] = @username)
    BEGIN
        -- Aktualizuj istniejący wpis
        UPDATE [dbo].[User_Settings]
        SET [theme] = @theme,
            [font_family] = @font_family,
            [font_size] = @font_size,
            [load_all_events_on_unselect] = @load_all_events,
            [last_update] = GETDATE()
        WHERE [Username] = @username
    END
    ELSE
    BEGIN
        -- Wstaw nowy wpis
        INSERT INTO [dbo].[User_Settings] ([Username], [theme], [font_family], [font_size], [load_all_events_on_unselect], [last_update])
        VALUES (@username, @theme, @font_family, @font_size, @load_all_events, GETDATE())
    END
END

CREATE OR ALTER PROCEDURE [dbo].[GetUserSettings]
    @username NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    -- Pobierz ustawienia dla danego użytkownika
    SELECT [theme], [font_family], [font_size], [load_all_events_on_unselect]
    FROM [dbo].[User_Settings]
    WHERE [Username] = @username
END

