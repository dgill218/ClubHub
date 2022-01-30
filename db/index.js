require('dotenv').config('../.env')
const mysql = require('mysql');

let connection = null

const runQuery = (sqlString, values) => {
    if (!connection) {
        connection = mysql.createConnection({
            host     : 'localhost',
            user     : 'root',
            password : 'Baseball16!!',
            database : 'ClubHub'
          })
        connection.connect();
    }
    return new Promise((resolve, reject) => {
        connection.query(sqlString, values, (error, results) => {
            if (error) {
                reject(error)
            }
            return resolve(results)
        })
    })
}

module.exports = runQuery

//connection.end();