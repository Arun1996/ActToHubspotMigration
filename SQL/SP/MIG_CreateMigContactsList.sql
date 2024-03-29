USE [AF_WebsiteMarketing]
GO
/****** Object:  StoredProcedure [dbo].[MIG_CreateMigContactsList]    Script Date: 04/05/2021 23:31:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author,,Name>
-- Create date: <Create Date,,>
-- Description: <Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[MIG_CreateMigContactsList]

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DROP TABLE IF EXISTS dbo.MIG_CONTACTSLIST;

    CREATE TABLE MIG_CONTACTSLIST(
        NAME nvarchar(250),
        DESCRIPTION nvarchar(250),
        GROUPID uniqueidentifier,
        listid int,
        response nvarchar(500)
    );

    INSERT INTO MIG_CONTACTSLIST(
        NAME,
        DESCRIPTION,
        GROUPID
        )
    select NAME, DESCRIPTION, GROUPID from TBL_GROUP;
    select * from MIG_CONTACTSLIST;
END
