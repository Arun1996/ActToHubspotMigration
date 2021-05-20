import json
import aiohttp
from ApiRequestLayer import fetch_all, update
from loggerModule import get_logger


class reqObj:
    def __init__(self, id, payload):
        self.id = id
        self.payload = payload


logger = get_logger('HubspotService')


async def migrateContacts(records):
    logger.info('Started contact migration')

    endpoint = 'https://api.hubapi.com/contacts/v1/contact'
    reqestList = []
    for row in records:
        data = {"properties": list()}
        data['properties'].append({
            "value": row[2],
            "property": "firstname"
        })
        data['properties'].append({
            "value": row[3],
            "property": "lastname"
        })
        data['properties'].append({
            "value": row[8],
            "property": "email"
        })
        data['properties'].append({
            "value": row[5],
            "property": "website"
        })
        data['properties'].append({
            "value": row[4],
            "property": "company"
        })
        data['properties'].append({
            "value": row[6],
            "property": "phone"
        })
        data['properties'].append({
            "value": row[10],
            "property": "address"
        })
        data['properties'].append({
            "value": row[11],
            "property": "city"
        })
        data['properties'].append({
            "value": row[12],
            "property": "state"
        })
        data['properties'].append({
            "value": row[13],
            "property": "zip"
        })
        data['properties'].append({
            "value": row[14],
            "property": "country"
        })
        data['properties'].append({
            "value": row[1],
            "property": "jobtitle"
        })
        data['properties'].append({
            "value": row[7],
            "property": "mobilephone"
        })
        # data['properties'].append({
        #     "value": row[9],
        #     "property": "hs_additional_emails"
        # })

        data['properties'].append({
            "value": row[17],
            "property": "id_status"
        })
        data['properties'].append({
            "value": row[16],
            "property": "additional_notes"
        })
        data['properties'].append({
            "value": row[15],
            "property": "referred_by"
        })
        data['properties'].append({
            "value": row[18],
            "property": "department"
        })
        data['properties'].append({
            "value": row[20],
            "property": "hubspot_owner_id"
        })
        data['properties'].append({
            "value": row[29],
            "property": "hosting_zone"
        })
        service_type = ''
        if row[21] == 'Paid':
            service_type = 'Paid'
        if row[22] == 'Content':
            if service_type == '':
                service_type = 'Content'
            else:
                service_type = service_type + ';' + 'Content'

        if row[23] == 'Domains':
            if service_type == '':
                service_type = 'Domains'
            else:
                service_type = service_type + ';' + 'Domains'

        if row[24] == 'Hosting':
            if service_type == '':
                service_type = 'Hosting'
            else:
                service_type = service_type + ';' + 'Hosting'

        if row[25] == 'SEO':
            if service_type == '':
                service_type = 'SEO'
            else:
                service_type = service_type + ';' + 'SEO'

        if row[26] == 'SLA':
            if service_type == '':
                service_type = 'SLA'
            else:
                service_type = service_type + ';' + 'SLA'

        if row[27] == 'WebDesign':
            if service_type == '':
                service_type = 'Web Design'
            else:
                service_type = service_type + ';' + 'Web Design'

        if row[28] == 'SocialMedia':
            if service_type == '':
                service_type = 'Social Media'
            else:
                service_type = service_type + ';' + 'Social Media'

        data['properties'].append({
            "value": service_type,
            "property": "service_type"
        })
        jsondata = json.dumps(data)
        reqestList.append(reqObj(row[0], jsondata))

    async with aiohttp.ClientSession() as session:
        res = await fetch_all(session, endpoint, reqestList, 10, 'Contacts')

    # for row in res:
    #     updateContactMig(row['id'], row['result'])

    logger.info('Ended contact migration')


def updateSecondaryEmail(records):
    logger.info('Started Secondary Email migration')

    for row in records:
        endpoint = f'https://api.hubapi.com/contacts/v1/secondary-email/{row[3]}/email/{row[2]}'
        update(endpoint)

    logger.info('Ended Secondary Email migration')


async def migrateEngagementNote(records):
    logger.info('Started Note migration')

    endpoint = "https://api.hubapi.com/engagements/v1/engagements"
    reqestList = []
    for row in records:
        data = {"engagement": {"active": 'true', "type": "NOTE"},
                "associations": {"companyIds": list(), "dealIds": list(), "ownerIds": list()},
                "metadata": {}
                }
        data['metadata']['body'] = row[3]
        data['engagement']['timestamp'] = row[4]
        data['engagement']['ownerId'] = row[7]
        data['associations']['contactIds'] = [row[5]]
        data['associations']['ownerIds'] = [row[7]]
        payload = json.dumps(data)
        reqestList.append(reqObj(row[0], payload))

    async with aiohttp.ClientSession() as session:
        res = await fetch_all(session, endpoint, reqestList, 10, 'EngagementNote')

    # for r in res:
    #     updateEngagementMig(r['id'], r['result'], "MIG_EngagementNote")

    logger.info('Ended Note migration')


async def migrateEngagementTask(records):
    logger.info('Started Task migration')

    endpoint = "https://api.hubapi.com/engagements/v1/engagements"
    reqestList = []
    for row in records:
        data = {"engagement": {"active": 'true', "type": "TASK"},
                "associations": {"companyIds": list(), "dealIds": list(), "ownerIds": list()},
                "metadata": {}
                }
        data['metadata']['subject'] = row[3]
        data['metadata']['taskType'] = row[2]
        data['metadata']['status'] = row[10]
        data['metadata']['body'] = row[14]
        data['metadata']['reminders'] = [row[12]]
        data['metadata']['priority'] = row[13]

        data['engagement']['timestamp'] = row[4]
        data['engagement']['ownerId'] = row[11]
        data['engagement']['createdAt'] = row[9]
        data['associations']['contactIds'] = [row[8]]
        data['associations']['ownerIds'] = [row[11]]
        payload = json.dumps(data)
        reqestList.append(reqObj(row[0], payload))

    async with aiohttp.ClientSession() as session:
        res = await fetch_all(session, endpoint, reqestList, 10, 'EngagementTask')

    # for r in res:
    #     updateEngagementMig(r['id'], r['result'], "EngagementTask")

    logger.info('Ended Task migration')


async def migrateEngagementMeetings(records):
    logger.info('Started Meeting migration')

    endpoint = "https://api.hubapi.com/engagements/v1/engagements"
    reqestList = []

    for row in records:
        data = {"engagement": {"active": 'true', "type": "MEETING"},
                "associations": {"companyIds": list(), "dealIds": list(), "ownerIds": list()},
                "metadata": {}
                }
        data['metadata']['title'] = row[3]
        data['metadata']['startTime'] = row[4]
        data['metadata']['endTime'] = row[5]
        data['engagement']['timestamp'] = row[4]
        data['engagement']['createdAt'] = row[9]
        data['engagement']['ownerId'] = row[10]
        data['associations']['contactIds'] = [row[8]]
        data['associations']['ownerIds'] = [row[10]]
        payload = json.dumps(data)
        reqestList.append(reqObj(row[0], payload))

    async with aiohttp.ClientSession() as session:
        res = await fetch_all(session, endpoint, reqestList, 10, 'EngagementMeeting')

    # for r in res:
    #     updateEngagementMig(r['id'], r['result'], "EngagementMeeting")

    logger.info('Ended Meeting migration')
