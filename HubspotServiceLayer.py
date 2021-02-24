import json
import requests

from ActDataAccessLayer import updateContactMig


def migrateContacts(records):
    endpoint = 'https://api.hubapi.com/contacts/v1/contact/?hapikey=bd8e66ae-7850-469f-b2d1-90a175b9b4d1'
    headers = {"Content-Type": "application/json"}
    for row in records:
        data = {"properties": list()}
        data['properties'].append({
            "value": row[1],
            "property": "firstname"
        })
        data['properties'].append({
            "value": row[2],
            "property": "lastname"
        })
        data['properties'].append({
            "value": row[6],
            "property": "email"
        })
        data['properties'].append({
            "value": row[4],
            "property": "website"
        })
        data['properties'].append({
            "value": row[3],
            "property": "company"
        })
        data['properties'].append({
            "value": row[5],
            "property": "phone"
        })
        data['properties'].append({
            "value": row[7],
            "property": "address"
        })
        data['properties'].append({
            "value": row[8],
            "property": "city"
        })
        data['properties'].append({
            "value": row[9],
            "property": "state"
        })
        data['properties'].append({
            "value": row[10],
            "property": "zip"
        })
        jsondata = json.dumps(data)
        r = requests.post(url=endpoint, data=jsondata, headers=headers)
        updateContactMig(row[0], r.text)
        print(data)
        print(r.text)


def migrateEngagementNote(records):
    url = "https://api.hubapi.com/engagements/v1/engagements"
    querystring = {"hapikey": "bd8e66ae-7850-469f-b2d1-90a175b9b4d1"}
    headers = {"Content-Type": "application/json"}

    for row in records:
        data = {"engagement": {"active": 'true', "type": "NOTE"},
                "associations": {"companyIds": list(), "dealIds": list(), "ownerIds": list()},
                "metadata": {}
                }
        data['metadata']['body'] = row[2]
        data['engagement']['timestamp'] = row[3]
        data['associations']['contactIds'] = [row[4]]
        payload = json.dumps(data)
        response = requests.request("POST", url, data=payload, headers=headers, params=querystring)
        print(data)
        print(response.text)


def migrateEngagementTask(records):
    url = "https://api.hubapi.com/engagements/v1/engagements"
    querystring = {"hapikey": "bd8e66ae-7850-469f-b2d1-90a175b9b4d1"}
    headers = {"Content-Type": "application/json"}

    for row in records:
        data = {"engagement": {"active": 'true', "type": "TASK"},
                "associations": {"companyIds": list(), "dealIds": list(), "ownerIds": list()},
                "metadata": {}
                }
        data['metadata']['subject'] = row[3]
        data['metadata']['taskType'] = row[2]
        data['engagement']['timestamp'] = row[5]
        data['engagement']['createdAt'] = row[9]
        data['associations']['contactIds'] = [row[8]]
        payload = json.dumps(data)
        response = requests.request("POST", url, data=payload, headers=headers, params=querystring)
        print(data)
        print(response.text)


def migrateEngagementMeetings(records):
    url = "https://api.hubapi.com/engagements/v1/engagements"
    querystring = {"hapikey": "bd8e66ae-7850-469f-b2d1-90a175b9b4d1"}
    headers = {"Content-Type": "application/json"}

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
        data['associations']['contactIds'] = [row[8]]
        payload = json.dumps(data)
        response = requests.request("POST", url, data=payload, headers=headers, params=querystring)
        print(data)
        print(response.text)
