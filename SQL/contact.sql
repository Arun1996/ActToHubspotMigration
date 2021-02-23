-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE MIG_CreateMigContacts
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DROP TABLE IF EXISTS dbo.MIG_CONTACTS;

	CREATE TABLE MIG_CONTACTS (
	    CONTACTID uniqueidentifier,
	    FIRSTNAME nvarchar(250),
	    LASTNAME nvarchar(250),
	    COMPANYNAME nvarchar(150),
		WEBSITE nvarchar(250),
		PHONE nvarchar(20),
		EMAIL nvarchar(50),
		ADDRESS nvarchar(250),
		CITY nvarchar(50),
		STATE nvarchar(50),
		POSTALCODE nvarchar(20),
		COUNTRYNAME nvarchar(50),
		vid int,
		response nvarchar(500)
	);
	
	INSERT INTO MIG_CONTACTS(
		FIRSTNAME,
		LASTNAME,
		COMPANYNAME,
		WEBSITE,
		PHONE,
		EMAIL,
		ADDRESS,
		CITY,
		STATE,
		POSTALCODE,
		COUNTRYNAME,
	    CONTACTID
		)
			
	select --top 10 
		ISNULL(C.FIRSTNAME,'') as FIRSTNAME,	
		ISNULL(C.LASTNAME,'')as LASTNAME,
		ISNULL(C.COMPANYNAME,'') as COMPANYNAME,
		ISNULL(rtrim(ltrim(c.CONTACTWEBADDRESS)),'') as website,
		ISNULL(NUMBERVALUE,'') as phone,
		ISNULL(ADDRESS,'') as Email,
		ISNULL(LINE1+' '+LINE2+' '+LINE3,'') as Address,
		ISNULL(CITY,'') as CITY,
		ISNULL(STATE,'') as STATE,
		ISNULL(POSTALCODE,'') as POSTALCODE,
		ISNULL(COUNTRYNAME,'') as COUNTRYNAME,
		C.CONTACTID
			
		from TBL_CONTACT C
				left join TBL_PHONE P on c.CONTACTID = P.CONTACTID and P.TYPEID in ('C3AE9586-6158-4D0D-9FAF-253CB0152F18')
				left join TBL_EMAIL E on C.CONTACTID = E.CONTACTID and E.TYPEID in ('9CE4FF61-F0B5-439F-81CC-857138422EC7')
				left join TBL_ADDRESS A on C.CONTACTID = A.CONTACTID and A.TYPEID in ('31BD07D5-4CB7-4038-9505-D2347AA530A1')
		where TYPENUM = 0;
		--order by 3 desc
	
	 select * from MIG_CONTACTS
END
GO
