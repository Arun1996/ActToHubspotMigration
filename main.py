from ActDataAccessLayer import getContactData, getNoteData, getTaskData, getMeetingData
from HubspotServiceLayer import migrateContacts, migrateEngagementNote, migrateEngagementTask, migrateEngagementMeetings

if __name__ == '__main__':
    ContactData = getContactData()
    migrateContacts(ContactData)

    NoteData = getNoteData()
    migrateEngagementNote(NoteData)

    TaskData = getTaskData()
    migrateEngagementTask(TaskData)

    MeetingData = getMeetingData()
    migrateEngagementMeetings(MeetingData)
# See PyCharm help at https://www.jetbrains.com/help/pycharm/
