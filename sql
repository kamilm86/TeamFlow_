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

USE [ZarzadzaniePraca]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_GetScheduleData]    Script Date: 07.06.2025 17:30:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[fn_GetForecastData]
(
    @Year INT,
    @Month INT
)
RETURNS TABLE
AS
RETURN
(
    
    -- Pobieram prognozę interwałową

        SELECT 
    YEAR(DataOd) AS Rok,
    MONTH(DataOd) AS Miesiac,
    CAST(DataOd AS DATE) AS Data,
    DataOd, 
    DataDo,
    CASE 
        WHEN Grupa = 0 THEN 'MASS+WELCOMER+GOLD' 
        WHEN Grupa = 1 THEN 'NUMEN+FIRMA' 
        WHEN Grupa = 2 THEN 'CZAT' 
        WHEN Grupa = 3 THEN 'WELCOMER' 
        WHEN Grupa = 4 THEN 'GOLD' 
        WHEN Grupa = 5 THEN 'NUMEN+FIRMA_VOICE' 
        WHEN Grupa = 6 THEN 'WELCOMER' 
        WHEN Grupa = 7 THEN 'TOTAL' -- Poprawiony błąd składniowy
        ELSE NULL
    END AS GrupaNazwa,
    Ilosc AS Prognoza
FROM p_t_ZZ_PrognozaRBH 
WHERE YEAR(DataOd) = @Year 
    AND MONTH(DataOd) = @Month

	)
GO


----------------------------------------------



