console.log("Server is up and running")
const express = require("express")
const bodyParser = require("body-parser")
const cors = require('cors')
const morgan = require('morgan')
const {sequelize} = require('./models')
const config = require('./config/config')

const app = express()
app.use( morgan('combined') )
app.use( bodyParser.json() )
app.use( cors() )

console.log("adding routes")
require('./routes')(app)
console.log("added routes")
/*
sequelize.authenticate()
  .then(() => console.log('Database connected...'))
  .catch(err => console.log('Error: ' + err))
*/
console.log("What is the port it's aiming for? ::: ", config.port)
sequelize.sync()
	.then(()=>{
		app.listen(8081)
		console.log(`Database Server started on port ${config.port}`)
	})