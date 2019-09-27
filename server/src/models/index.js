const fs = require('fs')
const path = require('path')
const Sequelize = require('sequelize')
const config = require('../config/config')
const db = {}

const sequelize = new Sequelize(
	config.db.database,
	config.db.user,
	config.db.password,
	config.db.options
)

sequelize.authenticate()
  .then(() => console.log('Database connected...'))
  .catch(err => console.log('Error: ' + err))

console.log("Collect Models...")
fs
	.readdirSync(__dirname)
	.filter((file)=>{
		//console.log("Does this file qualify?",file)
		return file !== 'index.js'
	})
	.forEach((file)=>{
		console.log("??? did it see the file?")
		let filepath = path.join(__dirname, file)
		console.log("FILE PATH :::::::: ",filepath)
		//---------------
		//---------------
		const model = sequelize.import( filepath )
		//---------------
		//---------------	
		console.log("Model of: ", file )
		console.log(model)
		console.log("Added an API for this table: ", model.name)
		db[model.name] = model
	})

db.sequelize = sequelize
db.Sequelize = Sequelize

module.exports = db