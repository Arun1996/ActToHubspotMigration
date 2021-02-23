import json
import requests


def migrateContacts(records):
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
    endpoint = 'https://api.hubapi.com/contacts/v1/contact/?hapikey=bd8e66ae-7850-469f-b2d1-90a175b9b4d1'
    headers = {"Content-Type": "application/json"}
    for row in records:
        data = {"properties": list()}
        data['properties'].append({
            "value": row[0],
            "property": "firstname"
        })
        data['properties'].append({
            "value": row[1],
            "property": "lastname"
        })
        data['properties'].append({
            "value": row[5],
            "property": "email"
        })
        data['properties'].append({
            "value": row[3],
            "property": "website"
        })
        data['properties'].append({
            "value": row[2],
            "property": "company"
        })
        data['properties'].append({
            "value": row[4],
            "property": "phone"
        })
        data['properties'].append({
            "value": row[6],
            "property": "address"
        })
        data['properties'].append({
            "value": row[7],
            "property": "city"
        })
        data['properties'].append({
            "value": row[8],
            "property": "state"
        })
        data['properties'].append({
            "value": row[9],
            "property": "zip"
        })
        jsondata = json.dumps(data)
        r = requests.post(url=endpoint, data=jsondata, headers=headers)
        print(data)
        print(r.text)
