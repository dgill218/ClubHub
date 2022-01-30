const express = require('express')
const app = express()
const cors = require('cors')
const loginRouter = require('./routes/loginRouter')
const userRouter = require('./routes/userRouter')
const clubRouter = require('./routes/clubRouter')
const eventRouter = require('./routes/eventRouter')
const adminRouter = require('./routes/adminRouter')

app.use(cors())
app.use(express.json())
app.use(express.static('build'))

app.use('/api/login', loginRouter)
app.use('/api/user', userRouter)
app.use('/api/club', clubRouter)
app.use('/api/event', eventRouter)
app.use('/api/admin', adminRouter)

module.exports = app
