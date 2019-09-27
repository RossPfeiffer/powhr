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

sequelize.sync()
	.then(()=>{

		app.listen(process.env.PORT || 8081)
		console.log(`SErver started on port ${config.port}`)
	})