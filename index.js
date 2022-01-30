const app = require('./app')
const http = require('http')

const server = http.createServer(app)
server.listen(8001, () => {
    console.log('Listening at port 8001')
})
