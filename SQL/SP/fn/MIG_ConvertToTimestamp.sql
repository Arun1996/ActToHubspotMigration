USE [AF_WebsiteMarketing]
GO
/****** Object:  UserDefinedFunction [dbo].[MIG_ConvertToTimestamp]    Script Date: 04/05/2021 23:36:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE or ALTER FUNCTION [dbo].[MIG_ConvertToTimestamp]
(
	-- Add the parameters for the function here
	@DateTime nvarchar(max)
)
RETURNS nvarchar(max)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Timestamp nvarchar(max);
	select @Timestamp = CAST(CAST(Datediff_big(s, '1970-01-01', @DateTime) AS BIGINT)*1000 AS varchar)
	return @Timestamp

END
