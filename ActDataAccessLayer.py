import json
import pyodbc

with open('config.json', 'r') as file:
    data = file.read()
config = json.loads(data)
db = config['database']


def getData():
    conn = pyodbc.connect(driver='{SQL Server}',
                          server=db['server_name'],
                          database=db['database_name'],
                          trusted_Connection='yes')
    cursor = conn.cursor()
    cursor.execute("exec MIG_CreateMigContacts")
    records = cursor.fetchall()
    cursor.commit()
    cursor.close()
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
