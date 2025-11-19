USE [ZarzadzaniePraca]
GO
/****** Object:  Trigger [dbo].[trg_Nadgodziny_PowiadomienieServiceBroker]    Script Date: 18.11.2025 23:14:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   TRIGGER [dbo].[trg_Nadgodziny_PowiadomienieServiceBroker]
ON [dbo].[p_T_ZZ_Nadgodziny]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Rok INT, @Miesiac INT;
    
    -- Pobierz Rok i Miesiąc (jedno zapytanie dla INSERT/UPDATE/DELETE)
    SELECT TOP 1 
        @Rok = COALESCE(i.Rok, d.Rok),
        @Miesiac = COALESCE(i.Miesiac, d.Miesiac)
    FROM inserted i
    FULL OUTER JOIN deleted d ON 1=1;  -- JOIN zawsze działa dla INSERT/UPDATE/DELETE
    
    -- Jeśli nie udało się ustalić roku/miesiąca, zakończ
    IF @Rok IS NULL OR @Miesiac IS NULL
        RETURN;
    
    -- Sprawdź, czy grafik jest opublikowany
    IF NOT EXISTS (
        SELECT 1 
        FROM [dbo].[p_T_ZZ_DatyPublikacjiGrafiku] 
        WHERE Rok = @Rok 
          AND Miesiac = @Miesiac 
          AND Status = 1
    )
    BEGIN
        -- Grafik nie jest opublikowany, nie wysyłaj powiadomienia
        RETURN;
    END
    
    -- Wyślij powiadomienie Service Broker
    DECLARE @dialog_handle UNIQUEIDENTIFIER;
    DECLARE @message_body XML;

    -- Stwórz wzbogaconą wiadomość XML z aliasem 'nadgodziny'
    SET @message_body = (
        SELECT 
            'nadgodziny' AS TableName,
            @Rok AS Year,
            @Miesiac AS Month,
            USER_NAME() AS Modifier
        FOR XML PATH('TeamFlowNotification'), ROOT('NotificationData')
    );

    -- Rozpocznij konwersację i wyślij wiadomość
    BEGIN DIALOG CONVERSATION @dialog_handle
        FROM SERVICE [//TeamFlowApp/Grafik/SerwisPowiadomien]
        TO SERVICE '//TeamFlowApp/Grafik/SerwisPowiadomien'
        ON CONTRACT [//TeamFlowApp/Grafik/KontraktPowiadomien]
        WITH ENCRYPTION = OFF;

    SEND ON CONVERSATION @dialog_handle
        MESSAGE TYPE [//TeamFlowApp/Grafik/PowiadomienieZmiany]
        (@message_body);

    --END CONVERSATION @dialog_handle;
END
USE [ZarzadzaniePraca]
GO
/****** Object:  Trigger [dbo].[trg_GrafikiPracy_PowiadomienieServiceBroker]    Script Date: 19.11.2025 09:04:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[trg_GrafikiPracy_PowiadomienieServiceBroker]
ON [dbo].[p_T_ZZ_GrafikiPracy]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Rok INT, @Miesiac INT;
    
    -- Pobierz Rok i Miesiąc (jedno zapytanie dla INSERT/UPDATE/DELETE)
    SELECT TOP 1 
        @Rok = COALESCE(i.Rok, d.Rok),
        @Miesiac = COALESCE(i.Miesiac, d.Miesiac)
    FROM inserted i
    FULL OUTER JOIN deleted d ON 1=1;  -- JOIN zawsze działa dla INSERT/UPDATE/DELETE
    
    -- Jeśli nie udało się ustalić roku/miesiąca, zakończ
    IF @Rok IS NULL OR @Miesiac IS NULL
        RETURN;
    
    -- Sprawdź, czy grafik jest opublikowany
    IF NOT EXISTS (
        SELECT 1 
        FROM [dbo].[p_T_ZZ_DatyPublikacjiGrafiku] 
        WHERE Rok = @Rok 
          AND Miesiac = @Miesiac 
          AND Status = 1
    )
    BEGIN
        -- Grafik nie jest opublikowany, nie wysyłaj powiadomienia
        RETURN;
    END
    
    -- Wyślij powiadomienie Service Broker
    DECLARE @dialog_handle UNIQUEIDENTIFIER;
    DECLARE @message_body XML;
    
    -- Stwórz wzbogaconą wiadomość XML z aliasem 'grafikipracy'
    SET @message_body = (
        SELECT 
            'grafikipracy' AS TableName,
            @Rok AS Year,
            @Miesiac AS Month,
            USER_NAME() AS Modifier
        FOR XML PATH('TeamFlowNotification'), ROOT('NotificationData')
    );

    -- Rozpocznij konwersację i wyślij wiadomość
    BEGIN DIALOG CONVERSATION @dialog_handle
        FROM SERVICE [//TeamFlowApp/Grafik/SerwisPowiadomien]
        TO SERVICE '//TeamFlowApp/Grafik/SerwisPowiadomien'
        ON CONTRACT [//TeamFlowApp/Grafik/KontraktPowiadomien]
        WITH ENCRYPTION = OFF;
    
    SEND ON CONVERSATION @dialog_handle
        MESSAGE TYPE [//TeamFlowApp/Grafik/PowiadomienieZmiany]
        (@message_body);
    
    --END CONVERSATION @dialog_handle;
END;
