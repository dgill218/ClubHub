const jwt = require('jsonwebtoken')
const bcrypt = require('bcrypt')
const runQuery = require('../db/index')
const loginRouter = require('express').Router()

loginRouter.post('/', async (request, response) => {
  const username = request.body.username
  const password = request.body.password
  if (!username || !password) {
    return response.status(401).send('please send valid username and password')
  }
  const results = await runQuery(`CALL getLoginInfo(?)`, [username])
  const user = results[0][0]
  if (!user) {
    return response.status(401).json('user does not exist')
  }
  const storedPasswordHash = user.PasswordHash
  const passwordCorrect = await bcrypt.compare(password, storedPasswordHash)
  if (!passwordCorrect) {
    return response.status(401).send('incorrect password')
  }
  
  const userForToken = {
    username,
    id: user.UserID
  }
  const token = jwt.sign(userForToken, 'secret')
  response.json({error: false, message: "login successful", token, username, userId: user.UserID})
})

module.exports = loginRouter
