USE [AF_WebsiteMarketing]
GO
/****** Object:  StoredProcedure [dbo].[MIG_EngagementMeeting]    Script Date: 04/05/2021 23:32:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create or ALTER PROCEDURE [dbo].[MIG_EngagementMeeting]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		DECLARE @ACTIVITYID uniqueidentifier, @STARTTIME nvarchar(20),@ENDTIME nvarchar(20),@CREATEDATE nvarchar(20)
	   
	    DROP TABLE IF EXISTS dbo.EngagementMeeting;

		CREATE TABLE EngagementMeeting (
		    ACTIVITYID uniqueidentifier,
		    CONTACTID uniqueidentifier,
		    ACTIVITY_TYPE nvarchar(10),
		    REGARDING nvarchar(max),
			STARTTIME nvarchar(20),
			ENDTIME nvarchar(20),
			DURATION int,
			DETAILS nvarchar(max),
			vid int,
			CREATEDATE nvarchar(20),
			ownerId BIGINT,
			id nvarchar(max),
			response nvarchar(max)
		);
	   
	   DROP TABLE IF EXISTS #TempTask;
	   select a.ACTIVITYID,
	   c.CONTACTID,
	   'MEETING' as ACTIVITY_TYPE,
	   a.REGARDING,
	   STARTTIME,
	   ENDTIME,
	   a.DURATION,
	   a.DETAILS,
	   c.vid,
	   CU.ownerId,
	   CREATEDATE
			into #TempTask
		from TBL_ACTIVITY a
			inner join ACTIVITY_TYPE at on a.ACTIVITYTYPEID = at.ACTIVITYTYPEID
			inner join TBL_CONTACT_ACTIVITY ca on ca.ACTIVITYID=a.ACTIVITYID
			inner join MIG_CONTACTS c on ca.CONTACTID = c.CONTACTID
			LEFT join MIG_Users CU ON A.ORGANIZEUSERID = CU.userid
		where ACTIVITY_TYPE in ('Appointment','Meeting') and ISDELETED = 0  and vid <> 0 

			WHILE EXISTS  (select top 1 ACTIVITYID from #TempTask)
			BEGIN
				BEGIN TRY 
					select top 1 @ACTIVITYID = ACTIVITYID from #TempTask 
					select @STARTTIME=dbo.MIG_ConvertToTimestamp(STARTTIME), @ENDTIME=dbo.MIG_ConvertToTimestamp(ENDTIME), @CREATEDATE=dbo.MIG_ConvertToTimestamp(CREATEDATE) from #TempTask WHERE ACTIVITYID=@ACTIVITYID
					INSERT INTO dbo.EngagementMeeting(
						ACTIVITYID ,
						CONTACTID ,
						ACTIVITY_TYPE,
						REGARDING,
						STARTTIME,
						ENDTIME,
						DURATION,
						DETAILS,
						vid ,
						ownerId,
						CREATEDATE
					)
					SELECT
						ACTIVITYID ,
						CONTACTID ,
						ACTIVITY_TYPE,
						REGARDING,
						@STARTTIME,
						@ENDTIME,
						DURATION,
						DETAILS,
						vid ,
						ownerId,
						@CREATEDATE
					FROM #TempTask WHERE ACTIVITYID=@ACTIVITYID 

					DELETE from #TempTask WHERE ACTIVITYID=@ACTIVITYID 

					END TRY  
					BEGIN CATCH  
						 INSERT INTO ErrorLog(
							FailedID,
							TableName,
							ErrorProcedure,
							ErrorMessage
						 )
						 SELECT
							@ACTIVITYID as ID,
							'TBL_Activity' as TableName,
							ERROR_PROCEDURE() AS ErrorProcedure,
							ERROR_MESSAGE() AS ErrorMessage
					DELETE from #TempTask WHERE ACTIVITYID=@ACTIVITYID 
					END CATCH
			END
		select * from EngagementMeeting
END
