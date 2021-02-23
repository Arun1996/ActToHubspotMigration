from ActDataAccessLayer import getData
from HubspotServiceLayer import migrateContacts

if __name__ == '__main__':
    records = getData()
    # migrateContacts(records)

# See PyCharm help at https://www.jetbrains.com/help/pycharm/
