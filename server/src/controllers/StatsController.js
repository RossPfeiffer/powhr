const {BuyPrice} = require('../models')

const web3 = require('web3')

module.exports= {
	async pullInitialStats (req,res){
		try{
			res.send( "Connected to back-end" )
		}catch(err){
			res.status(400).send({
				error:'Email is already in use. try a new email ________$$$$'
			})
		}
	},
	async updateBackendStats (req,res){
		console.log("Started Updating Back-end stats")
		console.log("----\n----\n----\n----\n----\n----\n----\n----\n",BuyPrice)
		//const user = await 
		let promise = await BuyPrice.create( {price:89, time:989} )
		//console.log(promise)
		console.log("Finished Updating Back-end stats")
		res.send( "New ENtry?" )
	}
}