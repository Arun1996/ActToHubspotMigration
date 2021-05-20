import json
import pyodbc

from loggerModule import get_logger

with open('config.json', 'r') as file:
    data = file.read()
config = json.loads(data)
db = config['database']

conn = pyodbc.connect(driver='{SQL Server}',
                      server=db['server_name'],
                      database=db['database_name'],
                      trusted_Connection='yes')

logger = get_logger('ActDataAccess')


async def updateResponse(id, response, objname):
    try:
        res = json.loads(response)
        if objname == 'Contacts':
            vid = 0
            if 'vid' in res:
                vid = int(res["vid"])
            cursor = conn.cursor()
            cursor.execute("UPDATE MIG_CONTACTS SET RESPONSE = ?,VID = ? WHERE CONTACTID = ?", response, vid,
                           id)
            cursor.commit()
            cursor.close()
        elif 'Engagement' in objname:
            hsid = '0'
            if 'engagement' in res:
                eng = res["engagement"]
                hsid = eng["id"]
            cursor = conn.cursor()

            if objname == "EngagementMeeting":
                cursor.execute("UPDATE dbo.EngagementMeeting SET RESPONSE = ?,ID = ? WHERE ACTIVITYID = ?", response,
                               hsid,
                               id)
            if objname == "EngagementTask":
                cursor.execute("UPDATE dbo.EngagementTask SET RESPONSE = ?,ID = ? WHERE ACTIVITYID = ?", response, hsid,
                               id)
            if objname == "EngagementNote":
                cursor.execute("UPDATE dbo.MIG_EngagementNote SET RESPONSE = ?,hsid = ? WHERE ID = ?", response, hsid,
                               id)
            cursor.commit()
            cursor.close()

    except Exception as exp:
        logger.error(exp)
        logger.error(response)


def getContactData():
    logger.info('Contact data fetch started')

    cursor = conn.cursor()
    cursor.execute("exec MIG_CreateMigContacts")
    records = cursor.fetchall()
    cursor.commit()
    cursor.close()
    logger.info(f"Total rows are: {str(len(records))}")
    logger.info('Contact data fetch ended')
    return records
    # print("Total rows are:  ", len(records))
    # print("Printing each row")
    # for row in records:
    #     print("FistName: ", row[0])
    #     print("LastName: ", row[1])
    #     print("Company: ", row[2])
    #     print("Website: ", row[3])
    #     print("Phone: ", row[4])
    #     print("Email: ", row[5])
    #     print("Address: ", row[6])
    #     print("City: ", row[7])
    #     print("State: ", row[8])
    #     print("PostCode: ", row[9])
    #     print("Country Name: ", row[10])
    #     print("\n")
    # cursor.execute(sql)
    # records = cursor.fetchall()
    # cursor.close()
    # return records
    # cursor.commit()
    # cursor.close()
    # cursor.execute('select top 10 * from [dbo].[TBL_CONTACT]')
    # for row in cursor:
    #     print(row)


def getNoteData():
    logger.info('Note data fetch started')
    cursor = conn.cursor()
    cursor.execute("exec MIG_CreateMigNotes")
    records = cursor.fetchall()
    cursor.commit()
    cursor.close()
    logger.info(f"Total rows are: {str(len(records))}")
    logger.info('Note data fetch ended')
    return records


def getTaskData():
    logger.info('Task data fetch started')
    cursor = conn.cursor()
    cursor.execute("exec MIG_EngagementTask")
    records = cursor.fetchall()
    cursor.commit()
    cursor.close()
    logger.info(f"Total rows are: {str(len(records))}")
    logger.info('Task data fetch ended')
    return records


def getMeetingData():
    # with open('SQL/meetings.sql', 'r') as f:
    #     sql = f.read()
    # cursor = conn.cursor()
    # cursor.execute(sql)
    # records = cursor.fetchall()
    # cursor.commit()
    # cursor.close()
    # print("Total rows are:  ", len(records))
    # return records
    logger.info('Meeting data fetch started')
    cursor = conn.cursor()
    cursor.execute("exec MIG_EngagementMeeting")
    records = cursor.fetchall()
    cursor.commit()
    cursor.close()
    logger.info(f"Total rows are: {str(len(records))}")
    logger.info('Meeting data fetch ended')
    return records

def getSecEmailData():
    logger.info('Secondary Email fetch started')
    with open('SQL/secondaryemail.sql', 'r') as f:
        sql = f.read()
    cursor = conn.cursor()
    cursor.execute(sql)
    records = cursor.fetchall()
    cursor.commit()
    cursor.close()
    logger.info(f"Total rows are: {str(len(records))}")
    logger.info('Secondary Email fetch ended')
    return records
