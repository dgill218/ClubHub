const runQuery = require('../db/index')
const eventRouter = require('express').Router()

// create new event 
eventRouter.post('/:clubId', async (request, response) => {
    const body = request.body
    const clubId = request.params.clubId
    if (!body.eventName || !body.eventDescription || !body.eventStartTime || !body.eventEndTime) {
        return response.status(401).send('please send valid event information')
    }
    const capacity = body.capacity === undefined ? null : body.capacity
    const registrationRequired = body.eventRegistrationRequired ? 1 : 0
    const results = await runQuery(`call createEvent(?, ?, ?, ?, ?, ?, ?)`,[body.eventName, body.eventDescription, body.eventStartTime, body.eventEndTime, registrationRequired, capacity, clubId])
    response.json(results[0][0])
})

// sample event: {"EventName": "Introduction to NoSQL", "EventDescription": "Learn how to make lightning fast queries in MongoDB at this event.", "StartTime": "2021-12-02 20:00:00", "EndTime": "2021-12-02 21:30:00", "RegistrationRequired": false}

// get all info about this event 
eventRouter.get('/:eventId/:userId', async (request, response) => {
    const eventId = request.params.eventId
    const userId = request.params.userId
    let event = await runQuery(`call getEventInfo(?, ?)`, [userId, eventId])
    event = event[0][0]
    event['StartTime'] = event['StartTime'].toLocaleString()
    event['EndTime'] = event['EndTime'].toLocaleString()
    response.json(event)
})

// modify event settings
eventRouter.put('/:eventId', async (request, response) => {
    const body = request.body
    const eventId = request.params.eventId
    if (!body.name || !body.description) {
        return response.status(401).send('please send valid event information')
    }
    const capacity = body.capacity === undefined ? null : body.capacity
    const registrationRequired = body.registrationRequired ? 1 : 0
    const results = await runQuery(`call setEventInfo(?, ?, ?, ?, ?)`, [body.name, body.description, registrationRequired, capacity, eventId])
    response.json(results[0][0])
})

// delete this event
eventRouter.delete('/:eventId', async (request, response) => {
    const eventId = request.params.eventId
    const results = await runQuery(`call deleteEvent(?)`, [eventId]) 
    response.json(results[0][0])
})

// attempt to register user for event
eventRouter.post('/:eventId/reservation/:userId', async (request, response) => {
    const eventId = request.params.eventId
    const userId = request.params.userId
    const results = await runQuery(`call registerToEvent(?, ?)`, [eventId, userId])
    if (results[0][0].error) {
        response.status(401).send(results[0][0].message)
    } else {
        response.json(results[0][0])
    }
})

// attempt to unregister user for event
eventRouter.delete('/:eventId/reservation/:userId', async (request, response) => {
    const eventId = request.params.eventId
    const userId = request.params.userId
    const results = await runQuery(`call unregisterFromEvent(?, ?)`, [eventId, userId])
    response.json(results[0][0])
})

module.exports = eventRouter


