USE [ZarzadzaniePraca]
GO
/****** Object:  StoredProcedure [dbo].[SaveUserSettings]    Script Date: 03.06.2025 01:43:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SaveUserSettings]
    @username NVARCHAR(255),
    @theme NVARCHAR(50),
    @font_family NVARCHAR(100),
    @font_size INT,
    @load_all_events BIT = 1,
    @visible_columns NVARCHAR(MAX) = NULL
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
            [visible_columns] = ISNULL(@visible_columns, [visible_columns]),
            [last_update] = GETDATE()
        WHERE [Username] = @username
    END
    ELSE
    BEGIN
        -- Wstaw nowy wpis
        INSERT INTO [dbo].[User_Settings] (
            [Username], 
            [theme], 
            [font_family], 
            [font_size], 
            [load_all_events_on_unselect], 
            [visible_columns],
            [last_update]
        )
        VALUES (
            @username, 
            @theme, 
            @font_family, 
            @font_size, 
            @load_all_events, 
            @visible_columns,
            GETDATE()
        )
    END
END

------------------------------
USE [ZarzadzaniePraca]
GO
/****** Object:  StoredProcedure [dbo].[GetUserSettings]    Script Date: 03.06.2025 01:44:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetUserSettings]
    @username NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    -- Pobierz ustawienia dla danego użytkownika
    SELECT [theme], [font_family], [font_size], [load_all_events_on_unselect], [visible_columns]
    FROM [dbo].[User_Settings]
    WHERE [Username] = @username
END
-------------------

