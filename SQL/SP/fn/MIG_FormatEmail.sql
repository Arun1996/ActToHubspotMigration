USE [AF_WebsiteMarketing]
GO
/****** Object:  UserDefinedFunction [dbo].[MIG_FormatEmail]    Script Date: 04/05/2021 23:34:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE or ALTER FUNCTION [dbo].[MIG_FormatEmail] 
(
	-- Add the parameters for the function here
	@Email nvarchar(max)
)
RETURNS nvarchar(max)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @FormatedEmail NVARCHAR(MAX)

	-- Add the T-SQL statements to compute the return value here
	SELECT @FormatedEmail=replace(@Email, ' ', '')
	SELECT @FormatedEmail=replace(@Email, '@@', '@')
	SELECT @FormatedEmail=replace(@Email, ';', '')
	SELECT @FormatedEmail=replace(@FormatedEmail, '''', '')
	SELECT @FormatedEmail=replace(@FormatedEmail, '"', '')
	SELECT @FormatedEmail=SUBSTRING(@FormatedEmail,CHARINDEX('<', @FormatedEmail)+1,CHARINDEX('>',@FormatedEmail)-CHARINDEX('<', @FormatedEmail)-1) WHERE @FormatedEmail LIKE '%<%' and  @FormatedEmail LIKE '%>%'
	SELECT @FormatedEmail='' WHERE @FormatedEmail NOT LIKE '%_@__%.__%'


	-- Return the result of the function
	RETURN @FormatedEmail

END
