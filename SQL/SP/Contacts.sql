USE [AF_WebsiteMarketing]
GO
/****** Object:  StoredProcedure [dbo].[MIG_CreateMigContacts]    Script Date: 30/04/2021 17:09:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[MIG_CreateMigContacts]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	  
	  DROP TABLE IF EXISTS dbo.ErrorLog;
	  CREATE TABLE ErrorLog
		(
		  ID int IDENTITY(1,1) PRIMARY KEY,
		  FailedID NVARCHAR(MAX),
		  TableName NVARCHAR(MAX),
		  ErrorProcedure NVARCHAR(MAX),
		  ErrorMessage NVARCHAR(MAX)
		)

	DROP TABLE IF EXISTS #PhoneNumbers;
	select 
		C.CONTACTID,
		CASE
			WHEN P.NUMBERDISPLAY IS NOT NULL THEN CONCAT('(+',P.COUNTRYCODE,') ',P.NUMBERDISPLAY)
			ELSE ''
		END AS PHONE,
		CASE
			WHEN M.NUMBERDISPLAY IS NOT NULL THEN CONCAT('(+',M.COUNTRYCODE,') ',M.NUMBERDISPLAY)
			ELSE ''
		END AS Mobile
			into #PhoneNumbers
	from TBL_CONTACT C
				left join TBL_PHONE P on c.CONTACTID = P.CONTACTID and P.TYPEID in ('C3AE9586-6158-4D0D-9FAF-253CB0152F18')
				left join TBL_PHONE M on c.CONTACTID = M.CONTACTID and M.TYPEID in ('511DF006-2CDB-40B5-8D1A-B313C873DD1C')
	
	DROP TABLE IF EXISTS #EmailIds;
	select 
		C.CONTACTID,
		ISNULL(E.ADDRESS,PE.ADDRESS) Email,
		PE.ADDRESS 'Personal Email'
			into #EmailIds
	from TBL_CONTACT C
				left join TBL_EMAIL E on c.CONTACTID = E.CONTACTID and E.TYPEID in ('9CE4FF61-F0B5-439F-81CC-857138422EC7')
				left join TBL_EMAIL PE on c.CONTACTID = PE.CONTACTID and PE.TYPEID in ('8809A43E-C9DA-4902-B8A6-10CD9D255D9C')


	DROP TABLE IF EXISTS #TempContacts;
	select 
		ISNULL(C.JOBTITLE,'') as JOBTITLE,
		ISNULL(C.FIRSTNAME,'') as FIRSTNAME,
		ISNULL(C.MIDDLENAME,'')as MIDDLENAME,
		ISNULL(C.LASTNAME,'')as LASTNAME,
		ISNULL(C.COMPANYNAME,'') as COMPANYNAME,
		ISNULL(rtrim(ltrim(c.CONTACTWEBADDRESS)),'') as website,
		ISNULL(p.PHONE,'') as phone,
		ISNULL(p.Mobile,'') as Mobile,
		ISNULL([dbo].[MIG_FormatEmail](E.Email),'') as Email,
		ISNULL([dbo].[MIG_FormatEmail](E.[Personal Email]),'') as PersonalEmail,
		ISNULL(LINE1+' '+LINE2+' '+LINE3,'') as Address,
		ISNULL(CITY,'') as CITY,
		ISNULL(STATE,'') as STATE,
		ISNULL(POSTALCODE,'') as POSTALCODE,
		ISNULL(COUNTRYNAME,'') as COUNTRYNAME,
		ISNULL(C.REFERREDBY,'') as REFERREDBY,
		ISNULL(C.CUST_AdditionalNotes_111506108,'') as AdditionalNotes,
		ISNULL(C.CATEGORY,'') as CATEGORY,
		ISNULL(DEPARTMENT,'') as DEPARTMENT,
		C.CONTACTID,
		ownerId
			into #TempContacts
		from TBL_CONTACT C
				inner join MIG_Users u on c.MANAGEUSERID = u.userid
				left join #PhoneNumbers P on c.CONTACTID = P.CONTACTID 
				left join #EmailIds E on C.CONTACTID = E.CONTACTID
				left join TBL_ADDRESS A on C.CONTACTID = A.CONTACTID and A.TYPEID in ('31BD07D5-4CB7-4038-9505-D2347AA530A1')
		--where TYPENUM in(0,1)
	
	DROP TABLE IF EXISTS dbo.MIG_CONTACTS;

	CREATE TABLE MIG_CONTACTS (
	    CONTACTID uniqueidentifier,
		JOBTITLE nvarchar(MAX),
	    FIRSTNAME nvarchar(MAX),
	    LASTNAME nvarchar(MAX),
	    COMPANYNAME nvarchar(MAX),
		WEBSITE nvarchar(MAX),
		PHONE nvarchar(MAX),
		MOBILE nvarchar(MAX),
		EMAIL nvarchar(MAX),
		PERSONALEMAIL nvarchar(MAX),
		ADDRESS nvarchar(MAX),
		CITY nvarchar(MAX),
		STATE nvarchar(MAX),
		POSTALCODE nvarchar(MAX),
		COUNTRYNAME nvarchar(MAX),
		REFERREDBY nvarchar(MAX),
		AdditionalNotes nvarchar(MAX),
		CATEGORY nvarchar(MAX),
		DEPARTMENT nvarchar(MAX),
		PRIMARYCONTACTID uniqueidentifier,
		ownerId BIGINT,
		VID int,
		RESPONSE nvarchar(MAX)
	);
	
	INSERT INTO MIG_CONTACTS(
		JOBTITLE,
		FIRSTNAME,
		LASTNAME,
		COMPANYNAME,
		WEBSITE,
		PHONE,
		MOBILE,
		EMAIL,
		PERSONALEMAIL,
		ADDRESS,
		CITY,
		STATE,
		POSTALCODE,
		COUNTRYNAME,
		REFERREDBY,
		AdditionalNotes,
		CATEGORY,
		DEPARTMENT,
		PRIMARYCONTACTID,
	    CONTACTID,
		ownerId
		)
			
	select
		JOBTITLE,
		FIRSTNAME,
		LASTNAME,
		COMPANYNAME,
		WEBSITE,
		PHONE,
		MOBILE,
		EMAIL,
		PERSONALEMAIL,
		ADDRESS,
		CITY,
		STATE,
		POSTALCODE,
		COUNTRYNAME,
		REFERREDBY,
		AdditionalNotes,
		CATEGORY,
		DEPARTMENT,
		S.CONTACTID,
	    C.CONTACTID,
		ownerId	
		from #TempContacts C 
				left join TBL_SECONDARY S ON C.CONTACTID=S.SECONDARYID
		
		DROP TABLE IF EXISTS #tempContact;
		SELECT * INTO #tempContact FROM MIG_CONTACTS WHERE Email LIKE ''

		DECLARE @Row int,@CONTACTID uniqueidentifier;
		SET  @Row = 0
		WHILE EXISTS  (select top 1 CONTACTID from #tempContact)
		BEGIN
			select top 1 @CONTACTID=CONTACTID from #tempContact

			UPDATE MIG_CONTACTS 
				SET Email = CONCAT('dummyemail',@Row,'@somedomain.com')
			WHERE CONTACTID = @CONTACTID

			SET @Row = @Row + 1

			DELETE FROM #tempContact WHERE CONTACTID = @CONTACTID
		END
	
	 select --top 200 
	 * from MIG_CONTACTS --4745
END
