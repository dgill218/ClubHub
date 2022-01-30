const express = require('express')
const runQuery = require('../db')

const clubRouter = express.Router()

// get all club names that match filter conditions
// TODO: implement searching by interest and location
clubRouter.get('/', async (request, response) => {
    const searchField = request.query.searchField ? `%${request.query.searchField}%` : "%"
    const matchingClubs = await runQuery('CALL searchClub(?)', [searchField])
    response.json(matchingClubs[0])
})

// create new club
clubRouter.post('/:userId', async (request, response) => {
    const body = request.body
    if (!body.city || !body.state || !body.street || !body.zip || !body.name) {
        return response.status(401).send('please send valid club information')
    }
    const userId = request.params.userId
    const results = await runQuery(`call createClub(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`, [body.city, body.state, body.locationName ?? null, body.street, body.buildingNo ?? null, body.zip,
        body.name, body.description ?? null, body.website ?? null, body.email ?? null, userId])
    if (results[0][0].error) {
        response.status(401).send(results[0][0].message)
    } else {
        response.json(results[0][0])
    }
})

// sample club: { "city": "Providence", "state": "Rhode Island", "locationName": "CCRI", "street": "2 Reading Road", "zip": "02115", "name": "Reading Club", "description": "Come Here to Read", "website": "reading.gov","email":"reading@ccri.gov" }

// delete a club (only allow if token matches admin id)
clubRouter.delete('/:clubId', async (request, response) => {
    const clubId = request.params.clubId
    const results = await runQuery(`call deleteClub(?)`, [clubId])
    response.json(results[0][0])
})

// modify club settings (only allow if token matches admin id)
clubRouter.put('/:clubId', async (request, response) => {
    const body = request.body
    const clubId = request.params.clubId
    if (!body.name) {
        return response.status(401).send('please send valid club name')
    }
    const results = await runQuery(`call modifyClub(?, ?, ?, ?, ?)`, [body.name, body.description, body.website, body.email, clubId])
    if (results[0][0].error) {
        response.status(401).send(results[0][0].message)
    } else {
        response.json(results[0][0])
    }
})

// modifies club interests
clubRouter.put('/interests/:clubId/', async (request, response) => {
    const clubId = request.params.clubId
    const interest = request.body.interest
    const toAdd = request.body.toAdd
    let results;
    if (toAdd) {
        results = await runQuery(`call addClubInterest(?, ?)`, [interest, clubId])
    } else {
        results = await runQuery(`call deleteClubInterest(?, ?)`, [interest, clubId])
    }
    response.json(results[0][0])
})

// get all information about a club
clubRouter.get('/:clubId/:userId', async (request, response) => {
    const clubId = request.params.clubId
    const userId = request.params.userId
    let clubData = await runQuery(`call getAllClubInfo(?, ?)`, [userId, clubId])
    clubData = clubData[0][0]
    let eventData = await runQuery(`call getEventsForClub(?)`, [clubId])
    clubData['events'] = eventData[0]
    response.json(clubData)
})

// add user to club members
clubRouter.post('/:clubId/members/:userId', async (request, response) => {
    const clubId = request.params.clubId
    const userId = request.params.userId
    const results = await runQuery(`call followClub(?, ?)`, [userId, clubId])
    response.json(results[0][0])
})

// remove user from club members
clubRouter.delete('/:clubId/members/:userId', async (request, response) => {
    const clubId = request.params.clubId
    const userId = request.params.userId
    const results = await runQuery(`call unfollowClub(?, ?)`, [userId, clubId])
    response.json(results[0][0])
})

// add annoucement for club (only allow if token matches admin id)
clubRouter.post('/:clubId/announcements', async (request, response) => {
    const annoucementText = request.body.announcementText ?? ""
    const clubId = request.params.clubId
    //await runQuery(`INSERT INTO Announcement (AnnouncementText, ClubAnnouncer) VALUES (?, ?)`, [annoucementText, clubId])
    const results = await runQuery(`call addAnnouncement(?, ?)`, [annoucementText, clubId])
    response.json(results[0][0])
})

// modify annoucement for club (only allow if token matches admin id)
clubRouter.put('/:clubId/announcements/:announcementId', async (request, response) => {
    const annoucementText = request.body.announcementText ?? ""
    const announcementId = request.params.announcementId
    //await runQuery(`UPDATE Announcement SET AnnouncementText = ? WHERE AnnouncementID = ?`, [annoucementText, announcementId])
    const results = await runQuery(`call editAnnouncement(?, ?)`, [annoucementText, announcementId])
    response.json(results[0][0])
})

// delete annoucement for club (only allow if token matches admin id)
clubRouter.delete('/:clubId/announcements/:announcementId', async (request, response) => {
    const announcementId = request.params.announcementId
    //await runQuery(`DELETE FROM Announcement WHERE AnnouncementID = ?`, [announcementId])
    const results = await runQuery(`call deleteAnnouncement(?)`, [announcementId])
    response.json(results[0][0])
})

module.exports = clubRouter
