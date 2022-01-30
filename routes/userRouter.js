const express = require('express')
const bcrypt = require('bcrypt')
const runQuery = require('../db/index')

const userRouter = express.Router()

// creates a user
userRouter.post('/', async (request, response) => {
    const username = request.body.username
    const password = request.body.password
    if (!username || !password) {
        return response.status(401).send('please send valid username and password')
    }
    const saltRounds = 10
    const passwordHash = await bcrypt.hash(password, saltRounds)
    const results = await runQuery(`CALL createUser(?, ?)`, [username, passwordHash])
    if (results[0][0].error) {
        response.status(401).send(results[0][0].message)
    } else {
        response.json(results[0][0])
    }
})

// gets basic info about user (login info, interests)
userRouter.get('/:userId', async (request, response) => {
    const userId = request.params.userId
    const usernameQuery = await runQuery(`CALL getUsername(?)`, [userId])
    const interestsQuery = await runQuery(`CALL getInterest(?)`, [userId])
    const username = usernameQuery[0][0].UserName
    const interests = interestsQuery[0].map(dict => dict["interest"])
    response.json({userId, username, interests})
})

// allow username to be changed
userRouter.put('/:userId', async (request, response) => {
    const userId = request.params.userId
    const newUsername = request.body.username
    if (!newUsername) {
        return response.status(401).send('please enter valid username')
    }
    const results = await runQuery(`CALL updateUsername(?, ?)`, [newUsername, userId])
    if (results[0][0].error) {
        response.status(401).send(results[0][0].message)
    } else {
        response.json(results[0][0])
    }
})

// deletes user from data base
userRouter.delete('/:userId', async (request, response) => {
    const userId = request.params.userId
    // use procedure here to remove all references from db
    const results = await runQuery(`CALL deleteUser(?)`, [userId])
    response.json(results[0][0])
})

// modifies user interests
userRouter.put('/interests/:userId/', async (request, response) => {
    const userId = request.params.userId
    const interest = request.body.interest
    const toAdd = request.body.toAdd
    let results;
    if (toAdd) {
        results = await runQuery(`CALL addUserInterests(?, ?)`, [interest, userId])
    } else {
        results = await runQuery(`CALL deleteUserInterests(?, ?)`, [interest, userId])
    }
    response.json(results[0][0])
})

// gets announcements sent to a user
userRouter.get('/announcements/:userId', async (request, response) => {
    const userId = request.params.userId
    let announcements = await runQuery(`CALL userAnnouncements(?)`, [userId])
    announcements = announcements[0]
    for (let i = 0; i < announcements.length; i++) {
        announcements[i]["AnnouncementTime"] = announcements[i]["AnnouncementTime"].toLocaleString()
    }
    response.json(announcements)
})

// gets list of clubs that a user follows
userRouter.get('/clubs/:userId', async (request, response) => {
    const userId = request.params.userId
    const clubInfo = await runQuery(`CALL userClubsFollowing(?)`, [userId])
    response.json(clubInfo[0])
})

// get list of upcoming events for user
userRouter.get('/events/:userId', async (request, response) => {
    const userId = request.params.userId
    let eventInfo = await runQuery(`CALL userUpcomingEvents(?)`, [userId])
    eventInfo = eventInfo[0]
    for (let i = 0; i < eventInfo.length; i++) {
        eventInfo[i]['StartTime'] = eventInfo[i]['StartTime'].toLocaleString()
        eventInfo[i]['EndTime'] = eventInfo[i]['EndTime'].toLocaleString()
    }
    response.json(eventInfo)
})

module.exports = userRouter
