const runQuery = require('../db/index')
const adminRouter = require('express').Router()

// get list of clubs this user administers
adminRouter.get('/:userId', async (request, response) => {
    const userId = request.params.userId
    const adminClubs = await runQuery(`CALL clubsAdministering(?)`, [userId])
    response.json(adminClubs[0])
})

// get all information about a club this user administers
adminRouter.get('/club/:clubId/:userId', async (request, response) => {
    const clubId = request.params.clubId
    const userId = request.params.userId
    let adminClub = await runQuery(`CALL adminClubInfo(?, ?)`, [userId, clubId])
    adminClub = adminClub[0][0]
    const adminClubAnnouncements = await runQuery(`CALL adminClubAnnouncements(?)`, [clubId])
    adminClub['announcements'] = adminClubAnnouncements[0]
    const adminClubEvents = await runQuery('CALL adminClubEvents(?)', [clubId])
    adminClub['events'] = adminClubEvents[0]
    const adminClubInterests = await runQuery(`CALL adminClubInterests(?)`, [clubId])
    adminClub['interests'] = adminClubInterests[0].map(interest => interest['InterestName'])
    const adminClubFollowers =  await runQuery(`CALL adminClubMembers(?)`, [clubId])
    adminClub['followers'] = adminClubFollowers[0].map(follower => follower['UserName'])
    response.json(adminClub)
})

// get all info about this event this user administers
adminRouter.get('/event/:eventId/:userId', async (request, response) => {
    const eventId = request.params.eventId
    const userId = request.params.userId
    let adminEvent = await runQuery(`CALL adminEventInfo(?, ?)`, [userId, eventId]) 
    adminEvent = adminEvent[0][0]
    adminEvent['StartTime'] = adminEvent['StartTime'].toLocaleString()
    adminEvent['EndTime'] = adminEvent['EndTime'].toLocaleString()
    const registeredUsers =  await runQuery(`CALL eventRegistered(?)`, [eventId])
    adminEvent['registered'] = registeredUsers[0].map(user => user['Username'])
    response.json(adminEvent)
})

module.exports = adminRouter