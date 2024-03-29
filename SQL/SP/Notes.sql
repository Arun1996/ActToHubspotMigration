USE [AF_WebsiteMarketing]
GO
/****** Object:  StoredProcedure [dbo].[MIG_CreateMigNotes]    Script Date: 30/04/2021 13:31:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create or ALTER PROCEDURE [dbo].[MIG_CreateMigNotes]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		DECLARE @NOTEID uniqueidentifier, @NoteTimestamp nvarchar(20),@CREATEDATE nvarchar(20), @NOTETEXT varchar(max);
	   
	    DROP TABLE IF EXISTS dbo.MIG_EngagementNote;

		CREATE TABLE MIG_EngagementNote (
			ID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
		    NOTEID uniqueidentifier,
		    CONTACTID uniqueidentifier,
		    NOTETEXT nvarchar(max),
			NoteTimestamp nvarchar(20),
			vid int,
			CREATEDATE nvarchar(20),
			ownerId BIGINT,
			hsid nvarchar(max),
			response nvarchar(max)
		);
	   
	   DROP TABLE IF EXISTS #TempNote;
	   select 
			C.CONTACTID,
			N.NOTEID,
			ISNULL(H.HTMLFileText,N.NOTETEXT) AS NOTETEXT,
			DISPLAYDATE,
			N.CREATEDATE,
			U.ownerId,
			C.vid 
		INTO #TempNote
		from MIG_CONTACTS C
			inner join TBL_CONTACT_NOTE CN on CN.CONTACTID = C.CONTACTID
			inner join TBL_NOTE N on N.NOTEID = CN.NOTEID
			INNER join MIG_Users U ON N.MANAGEUSERID = U.userid
			left join HTMLFiles H on N.NOTEID = H.FileID
		--where vid <> 0

		DROP TABLE IF EXISTS #cte;
		select 
		PRIMARYCONTACTID,
		STUFF((select '; '+ s.FIRSTNAME +' '+ s.LASTNAME + ' - '+s.EMAIL 
					from MIG_CONTACTS s 
					where s.PRIMARYCONTACTID=p.PRIMARYCONTACTID FOR XML PATH('')), 1, 1, '') as res
			into #cte
		from MIG_CONTACTS P where P.PRIMARYCONTACTID is not null
		GROUP BY p.PRIMARYCONTACTID order by p.PRIMARYCONTACTID 

		DROP TABLE IF EXISTS #custNote;
		select 
			t.PRIMARYCONTACTID,
			CONCAT('<b>SECONDAY CONTACTS</b></br>',REPLACE(res,';','</br>')) as 'Note Text',
			dbo.MIG_ConvertToTimestamp(GETUTCDATE()) as NoteTimestamp,
			c.vid,
			NULL as ownerId,
			dbo.MIG_ConvertToTimestamp(GETUTCDATE()) as CREATEDATE
				into #custNote
		from #cte t
				inner join MIG_CONTACTS c on t.PRIMARYCONTACTID=c.CONTACTID
		where c.vid <> 0

		INSERT INTO dbo.MIG_EngagementNote(
						NOTEID,
						CONTACTID,
						NOTETEXT,
						NoteTimestamp,
						vid ,
						ownerId,
						CREATEDATE
					)
					SELECT
						NOTEID ,
						CONTACTID ,
						NOTETEXT,
						dbo.MIG_ConvertToTimestamp(DISPLAYDATE),
						vid ,
						ownerId,
						dbo.MIG_ConvertToTimestamp(CREATEDATE)
					FROM #TempNote 

					UNION
					select null,* from #custNote

				

			--WHILE EXISTS  (select top 1 NOTEID from #TempNote)
			--BEGIN
			--	BEGIN TRY 
			--		--set @NOTETEXT=NULL;
			--		select top 1 @NOTEID = NOTEID from #TempNote 
			--		select  @NoteTimestamp=dbo.MIG_ConvertToTimestamp(DISPLAYDATE), @CREATEDATE=dbo.MIG_ConvertToTimestamp(CREATEDATE) from #TempNote WHERE NOTEID=@NOTEID
			--		--select @NOTETEXT=ltrim(rtrim(dbo.MIG_ConvertRTFtoHTML(NOTETEXT))) from #TempNote where NOTETEXT like '{\rtf1\%' and NOTEID=@NOTEID

			--		INSERT INTO dbo.MIG_EngagementNote(
			--			NOTEID,
			--			CONTACTID,
			--			NOTETEXT,
			--			NoteTimestamp,
			--			vid ,
			--			ownerId,
			--			CREATEDATE
			--		)
			--		SELECT
			--			NOTEID ,
			--			CONTACTID ,
			--			NOTETEXT,
			--			@NoteTimestamp,
			--			vid ,
			--			ownerId,
			--			@CREATEDATE
			--		FROM #TempNote WHERE NOTEID=@NOTEID

			--		DELETE from #TempNote WHERE NOTEID=@NOTEID
			--	END TRY  
			--	BEGIN CATCH  
			--		 INSERT INTO ErrorLog(
			--			FailedID,
			--			TableName,
			--			ErrorProcedure,
			--			ErrorMessage
			--		 )
			--		 SELECT
			--			@NOTEID as ID,
			--			'TBL_NOTE' as TableName,
			--			ERROR_PROCEDURE() AS ErrorProcedure,
			--			ERROR_MESSAGE() AS ErrorMessage

			--		DELETE from #TempNote WHERE NOTEID=@NOTEID
			--	END CATCH
			--END
		select * from MIG_EngagementNote

		--select c.CONTACTID,N.NOTEID,H.HTMLFileText,CAST(CAST(Datediff(s, '1970-01-01', DISPLAYDATE) AS BIGINT)*1000 AS varchar)"NoteTimestamp",C.vid from ErrorLog el 
		--			inner join TBL_NOTE N on el.FailedID=n.NOTEID
		--			inner join HTMLFiles H on H.Fileid=n.NOTEID
		--			inner join TBL_CONTACT_NOTE CN on CN.NOTEID=N.NOTEID
		--			inner join MIG_CONTACTS c on CN.CONTACTID=c.CONTACTID
				--	inner join MIG_EngagementNote EN on EN.NOTEID = N.NOTEID
END				
