fn_getcorrectlocation = dbo.fn_GetCorrectLocationForDay
USE [ZarzadzaniePraca]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetCorrectLocationForDay]    Script Date: 17.09.2025 17:53:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_GetCorrectLocationForDay] (
    @UserId INT,
    @TargetDate DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        -- COALESCE zwraca pierwszy argument, który nie jest NULL
        COALESCE(
            -- 1. Spróbuj pobrać lokalizację z symbolu w grafiku na ten dzień
            (
                SELECT TOP 1
                    CASE 
                        WHEN CHARINDEX(';', g.Symbol) > 0 AND LEFT(g.Symbol, 1) IN ('h', 's', 'p') 
                        THEN LEFT(g.Symbol, 1) 
                        ELSE NULL 
                    END
                FROM [dbo].[p_T_ZZ_GrafikiPracy] g 
                WHERE g.Uzytkownik = @UserId AND g.Data = @TargetDate
            ),
            
            -- 2. Jeśli brak, spróbuj pobrać lokalizację z wyjątku
            (
                SELECT TOP 1
                    CASE le.Lokalizacja 
                        WHEN 1 THEN 'h' 
                        WHEN 2 THEN 'p' 
                        WHEN 3 THEN 's' 
                        ELSE NULL 
                    END
                FROM p_t_zz_lokalizacjewyjatki le
                WHERE le.Uzytkownik = @UserId 
                  AND @TargetDate BETWEEN le.DataOd AND le.DataDo
            ),

            -- 3. Jeśli brak, weź lokalizację domyślną użytkownika
            's' --LokalizacjaDomyslna
        ) AS FinalLocation
    FROM [dbo].[p_T_DO_KonfiguracjaZatrudnienie] g -- Potrzebna tabela, żeby funkcja zawsze coś zwróciła
    WHERE g.[Uzytkownik] = @UserId AND g.Rok = YEAR(@TargetDate) AND g.Miesiac = MONTH(@TargetDate)
);
