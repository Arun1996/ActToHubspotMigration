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
CREATE OR ALTER PROCEDURE MIG_CustContacts
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DROP TABLE IF EXISTS #CustContactTemp;
    select
		c.CONTACTID,
		c.JOBTITLE,
		c.FIRSTNAME,
		c.LASTNAME,
		isnull(cl.COMPANYNAME,'') COMPANYNAME,
		c.WEBSITE,
		c.PHONE,
		c.MOBILE,
		c.EMAIL,
		c.PERSONALEMAIL,
		c.ADDRESS,
		c.CITY,
		c.STATE,
		c.POSTALCODE,
		c.COUNTRYNAME,
		c.REFERREDBY,
		c.AdditionalNotes,
		c.CATEGORY,
		c.DEPARTMENT,
		c.PRIMARYCONTACTID,
		c.ownerId,
		Paid = case when cl.Paid is not null then 'Paid' else '' end,
		Content = case when cl.Content is not null then 'Content' else '' end,
		Domains = case when cl.Domains is not null then 'Domains' else '' end,
		Hosting = case when cl.Hosting is not null then 'Hosting' else '' end,
		SEO = case when cl.SEO is not null then 'SEO' else '' end,
		SLA = case when cl.SLA is not null then 'SLA' else '' end,
		[WebDesign] = case when cl.[Hosting Zone] is not null then 'Web Design' else '' end,
		SocialMedia = case when cl.[Social Media] is not null then 'Social Media' else '' end,
		isnull([Hosting Zone],'') as HostingZone,
		c.VID,
		c.RESPONSE
			into #CustContactTemp
	from [Contact List] cl
				inner join MIG_CONTACTS c on c.CONTACTID=cl.CONTACTID
				left join emaildup d on cl.CONTACTID = d.CONTACTID and d.[delete] = 1
    where d.CONTACTID is null

	;with cte as(
	select cl.*,ROW_NUMBER() over(partition by cl.email order by cl.contactid) as dup from #CustContactTemp cl
)
select CONCAT(SUBSTRING(EMAIL,1,CHARINDEX('@',EMAIL)-1),'_dup',CAST(dup as int)-1,SUBSTRING(EMAIL,CHARINDEX('@',EMAIL),LEN(EMAIL)-CHARINDEX('@',EMAIL)+1)),* from cte where dup>1

--update cte set EMAIL=CONCAT(SUBSTRING(EMAIL,1,CHARINDEX('@',EMAIL)-1),'_dup','00',CAST(dup as int)-1,SUBSTRING(EMAIL,CHARINDEX('@',EMAIL),LEN(EMAIL)-CHARINDEX('@',EMAIL)+1))
--		where dup>1

select  * from #CustContactTemp where EMAIL = 'ben@morrisuk.co.uk'

END
GO
