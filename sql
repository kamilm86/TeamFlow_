-- Tabela do przechowywania globalnych ustawień aplikacji
CREATE TABLE dbo.AppSettings (
    SettingKey NVARCHAR(100) PRIMARY KEY,
    SettingValue NVARCHAR(255) NOT NULL,
    LastModified DATETIME DEFAULT GETDATE()
);

-- Wstawienie domyślnych wartości: aktualna wersja i flaga wymuszenia
INSERT INTO dbo.AppSettings (SettingKey, SettingValue) VALUES 
('current_version', '1.0.0'),
('force_update', 'false');

-- Procedura do aktualizacji ustawień
GO
CREATE PROCEDURE dbo.UpdateAppSetting
    @Key NVARCHAR(100),
    @Value NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.AppSettings WHERE SettingKey = @Key)
    BEGIN
        UPDATE dbo.AppSettings
        SET SettingValue = @Value, LastModified = GETDATE()
        WHERE SettingKey = @Key;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.AppSettings (SettingKey, SettingValue)
        VALUES (@Key, @Value);
    END
END
GO
-------------------------------------------------------------------------------------
USE [ZarzadzaniePraca]
GO

/****** Object:  Table [dbo].[user_settings]    Script Date: 30.06.2025 02:50:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[user_settings](
	[login_windows] [nvarchar](100) NOT NULL,
	[theme] [nvarchar](50) NULL,
	[font_family] [nvarchar](100) NULL,
	[font_size] [int] NULL,
	[last_update] [datetime] NULL,
	[load_all_events_on_unselect] [bit] NOT NULL,
	[visible_columns] [nvarchar](max) NULL,
	[ShowScheduleComment] [bit] NOT NULL,
	[import_grupa] [bit] NULL,
	[import_funkcja] [bit] NULL,
	[show_special_symbol] [bit] NULL,
	[show_location_symbol] [bit] NULL,
	[special_symbol_position] [nvarchar](11) NULL,
	[location_symbol_position] [nvarchar](11) NULL,
	[log_to_file] [bit] NULL,
	[log_to_console] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[login_windows] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[user_settings] ADD  DEFAULT (getdate()) FOR [last_update]
GO

ALTER TABLE [dbo].[user_settings] ADD  DEFAULT ((1)) FOR [load_all_events_on_unselect]
GO

ALTER TABLE [dbo].[user_settings] ADD  DEFAULT ((0)) FOR [ShowScheduleComment]
GO




------------------------------------------------

USE [ZarzadzaniePraca]
GO

/****** Object:  StoredProcedure [dbo].[GetUserSettings]    Script Date: 30.06.2025 02:51:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[GetUserSettings]
    @login_windows NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    -- Pobierz ustawienia dla danego użytkownika
    SELECT [theme], [font_family], [font_size], [load_all_events_on_unselect], [visible_columns],[ShowScheduleComment],import_grupa,import_funkcja,show_special_symbol,
  show_location_symbol,
  special_symbol_position,
  location_symbol_position,
  log_to_file,
  log_to_console
    FROM [dbo].[User_Settings]
    WHERE [login_windows] = @login_windows
END
GO



-------------------------------------------------

USE [ZarzadzaniePraca]
GO

/****** Object:  StoredProcedure [dbo].[SaveUserSettings]    Script Date: 30.06.2025 02:50:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- Modyfikacja istniejącej procedury składowanej
ALTER PROCEDURE [dbo].[SaveUserSettings]
    @login_windows NVARCHAR(255),
    @theme NVARCHAR(50),
    @font_family NVARCHAR(100),
    @font_size INT,
    @load_all_events BIT = 1,
    @visible_columns NVARCHAR(MAX) = NULL,
    -- NOWY PARAMETR
    @show_schedule_comment BIT = 0,
	@import_grupa BIT,
	@import_funkcja BIT,
	 @show_special_symbol BIT,
  @show_location_symbol BIT,
  @special_symbol_position NVARCHAR(11),
  @location_symbol_position NVARCHAR(11)

AS
BEGIN
    SET NOCOUNT ON;

    -- Sprawdź, czy istnieje wpis dla danego użytkownika
    IF EXISTS (SELECT 1 FROM [dbo].[User_Settings] WHERE [login_windows] = @login_windows)
    BEGIN
        -- Aktualizuj istniejący wpis
        UPDATE [dbo].[User_Settings]
        SET 
            [theme] = @theme,
            [font_family] = @font_family,
            [font_size] = @font_size,
            [load_all_events_on_unselect] = @load_all_events,
            [visible_columns] = ISNULL(@visible_columns, [visible_columns]),
            -- NOWA LINIA DO OBSŁUGI KOMENTARZA
            [ShowScheduleComment] = @show_schedule_comment,
			import_grupa = @import_grupa,
			import_funkcja = @import_funkcja,
		  show_special_symbol = @show_special_symbol,
  show_location_symbol = @show_location_symbol,
  special_symbol_position = @special_symbol_position,
  location_symbol_position = @location_symbol_position,
            [last_update] = GETDATE()
        WHERE 
            [login_windows] = @login_windows
    END
    ELSE
    BEGIN
        -- Wstaw nowy wpis
        INSERT INTO [dbo].[User_Settings] (
            [login_windows], 
            [theme], 
            [font_family], 
            [font_size], 
            [load_all_events_on_unselect], 
            [visible_columns],
            -- NOWA KOLUMNA NA LIŚCIE
            [ShowScheduleComment],
			import_grupa ,
			import_funkcja ,
	  show_special_symbol,
  show_location_symbol,
  special_symbol_position,
  location_symbol_position,
            [last_update]
        )
        VALUES (
            @login_windows, 
            @theme, 
            @font_family, 
            @font_size, 
            @load_all_events, 
            @visible_columns,
            -- NOWA WARTOŚĆ NA LIŚCIE
            @show_schedule_comment,
			@import_grupa,
			@import_funkcja,
		  @show_special_symbol,
  @show_location_symbol,
  @special_symbol_position,
  @location_symbol_position,
            GETDATE()
        )
    END
END
GO




-----------------------------------------------
USE [ZarzadzaniePraca]
GO

/****** Object:  UserDefinedFunction [dbo].[GetUserAppInfoWithParam]    Script Date: 09.06.2025 18:16:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


  CREATE FUNCTION [dbo].[GetUserAppInfoWithParam](@LoginWindows NVARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT 
        Id,
        NumerKadrowy,
        RolaNazwa,
        WidziPrzyszlyMiesiac = 0
    FROM [dbo].[p_T_DO_KontaUzytkownikow]
    WHERE NumerKadrowy = '000001' 
       OR Nazwisko = @LoginWindows
);
GO
--------------------------------------------------------------
USE [ZarzadzaniePraca]
GO

/****** Object:  UserDefinedFunction [dbo].[GetUserAppInfo]    Script Date: 09.06.2025 18:16:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 CREATE FUNCTION [dbo].[GetUserAppInfo](@LoginWindows NVARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT 
        Id,
        NumerKadrowy,
        RolaNazwa,
        WidziPrzyszlyMiesiac = 0
    FROM [dbo].[p_T_DO_KontaUzytkownikow]
    WHERE NumerKadrowy = '000001' 
       OR Nazwisko = @LoginWindows
);
GO
--------------------------------------------------------------
USE [ZarzadzaniePraca]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_GetScheduleData]    Script Date: 09.06.2025 18:16:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_GetScheduleData]
(
    @Year INT,
    @Month INT
)
RETURNS TABLE
AS
RETURN
(
    -- Tworzę tabelę tymczasową z wszystkimi dniami w miesiącu
    WITH CalendarDays AS (
        SELECT DATEADD(DAY, number, DATEFROMPARTS(@Year, @Month, 1)) AS Data
        FROM master.dbo.spt_values
        WHERE type = 'P' 
        AND number BETWEEN 0 AND DATEDIFF(DAY, 
                                        DATEFROMPARTS(@Year, @Month, 1), 
                                        EOMONTH(DATEFROMPARTS(@Year, @Month, 1)))
    ),
    -- Pobieram wszystkich użytkowników z konfiguracji zatrudnienia spełniających kryteria
    FilteredUsers AS (
        SELECT DISTINCT k.Uzytkownik, k.WydzialGrafik, k.PrzelozonyDane, k.UzytkownikDane, k.NumerKadrowy,k.RolaNazwa ,k.PodRolaNazwa, k.Etat, k.Język ,k.Korekta ,k.PrzelozonyImieNazwisko, k.DTN
        FROM p_t_do_KonfiguracjaZatrudnienie k
        WHERE k.Rok = @Year 
        AND k.Miesiac = @Month
        AND k.Flaga = 1

    )
    -- Tworzę cross join wszystkich dni z wszystkimi użytkownikami
    SELECT 
        u.WydzialGrafik, 
        u.PrzelozonyDane, 
		u.PrzelozonyImieNazwisko,
        u.UzytkownikDane, 
        u.Uzytkownik,
		u.NumerKadrowy,
        CONVERT(VARCHAR(10), d.Data, 120) AS Data, 
        g.Symbol,
        g.Id,
        --CASE WHEN s.Id IS NOT NULL THEN 1 ELSE 0 END AS Spotkania,
        --CASE WHEN sz.Id IS NOT NULL THEN 1 ELSE 0 END AS Szkolenia,
        --CASE WHEN n.Id IS NOT NULL THEN 1 ELSE 0 END AS Nadgodziny,
		u.RolaNazwa,
		u.PodRolaNazwa, 
		u.Etat, 
		u.Język,
		u.Korekta,
		u.DTN,
		's' LokalizacjaDomyslna,
		'Zmianowy' SystemCzasuPracy,
		g.DataModyfikacji


    FROM 
        CalendarDays d
    CROSS JOIN
        FilteredUsers u
    LEFT JOIN 
        p_v_zz_GrafikiPracy g ON g.Uzytkownik = u.Uzytkownik 
                            AND g.Data = d.Data
                            AND g.Rok = @Year 
                            AND g.Miesiac = @Month
    LEFT JOIN
        p_t_do_KonfiguracjaZatrudnienie k ON k.Uzytkownik = u.Uzytkownik 
                                       AND k.Rok = @Year 
                                       AND k.Miesiac = @Month
                                       AND k.Flaga = 1
)
GO
------------------------------------------------------------------
USE [ZarzadzaniePraca]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_GetScheduleAuditData]    Script Date: 09.06.2025 18:17:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- Tworzenie nowej funkcji tabelarycznej
CREATE FUNCTION [dbo].[fn_GetScheduleAuditData]
(
    @year INT,
    @month INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        [Uzytkownik],
        YEAR([Data]) AS Rok,
        MONTH([Data]) AS Miesiac,
        [Data],
        [Symbol],
        [DataModyfikacji],
        [Modyfikujacy],
        [OperationType] AS TypModyfikacji
    FROM 
        [dbo].[p_T_ZZ_GrafikiPracy_Audit]
    WHERE 
        YEAR([Data]) = @year AND MONTH([Data]) = @month
)
GO
--------------------------------------------------------
USE [ZarzadzaniePraca]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_GetForecastData]    Script Date: 09.06.2025 18:17:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[fn_GetForecastData]
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
--------------------------------------------------------------------------
USE [ZarzadzaniePraca]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_GetEventsData]    Script Date: 09.06.2025 18:18:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[fn_GetEventsData]
(
    @Year INT,
    @Month INT
)
RETURNS TABLE
AS
RETURN
(
    -- Spotkania
    SELECT 'Spotkanie' AS EventType, 
           Id, Temat, Nazwa, Uzytkownik, Data, DataOd, DataDo, StatusNazwa, DataModyfikacji
    FROM p_v_zz_Spotkania WITH (NOLOCK)
    WHERE Rok = @Year AND Miesiac = @Month AND Status = 1
    
    UNION ALL
    
    -- Szkolenia
    SELECT 'Szkolenie' AS EventType,
           Id, Temat, Nazwa, Uzytkownik, Data, DataOd, DataDo, StatusNazwa, DataModyfikacji
    FROM p_v_zz_Szkolenia WITH (NOLOCK)
    WHERE Rok = @Year AND Miesiac = @Month AND Status = 1
    
    UNION ALL
    
    -- Nadgodziny
    SELECT 'Nadgodziny' AS EventType,
           Id, 'Nadgodziny' AS Temat, 'Nadgodziny' AS Nazwa, 
           Uzytkownik, Data, DataOd, DataDo, 'Wstawione' AS StatusNazwa, DataModyfikacji
    FROM p_t_zz_Nadgodziny WITH (NOLOCK)
    WHERE Rok = @Year AND Miesiac = @Month AND [StatusRozliczenia] = 1
);
GO


