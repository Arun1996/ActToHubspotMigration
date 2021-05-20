import asyncio

from ActDataAccessLayer import getContactData, getNoteData, getTaskData, getMeetingData, getSecEmailData
from HubspotServiceLayer import migrateContacts, updateSecondaryEmail, migrateEngagementNote, migrateEngagementTask, migrateEngagementMeetings


def main():
    ContactData = getContactData()
    asyncio.run(migrateContacts(ContactData))

    secEmail = getSecEmailData()
    updateSecondaryEmail(secEmail)

    NoteData = getNoteData()
    asyncio.run(migrateEngagementNote(NoteData))

    TaskData = getTaskData()
    asyncio.run(migrateEngagementTask(TaskData))

    MeetingData = getMeetingData()
    asyncio.run(migrateEngagementMeetings(MeetingData))


if __name__ == '__main__':
    main()
