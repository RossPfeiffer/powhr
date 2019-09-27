
//var eth =require('../util/eth')
var _powhrInterface =require( '../store/powhrInterface')
var powhrAddress  =require('../store/powhrAddress')
var _tokenInterface  =require('../store/tokenInterface')
var tokenAddress  =require( '../store/tokenAddress')

var Web3 = require('web3')

var provider = new Web3.providers.HttpProvider("HTTP://127.0.0.1:7545");
var web3 = new Web3(provider)



  var resolveContract = _powhrInterface.init(web3)
  var tokenContract = _tokenInterface.init(web3)
  var powhrAPI = resolveContract.methods
  var tokenAPI = tokenContract.methods

var accounts = [
	{public:"0XB3AB31D37270B5A6FB5F7076650246B5153A08D0",
	private:"4613cec1c2ab9e47cd564966c59d851caaae07348fc244282e792e758ea658a5"},
	{public:"0X3A234FB5562E7EDC80D0724759D3CEBCF957A653",
	private:"7e7af0dd4e4bdc3fe18fc178380ddea0fb429f08059ecc39a001d2850c72da82"},
	{public:"0X169A7D0085C16020EB6F1CC31CB08A3DE9BF4668",
	private:"42491aa771b6b42dda0f94f9a79acf548a399f534b23561c54c3684c10f8167a"},
]
var rawTransaction = {
  "from": accounts[0].public,
  "to": accounts[1].public,
  "value": web3.utils.toHex( web3.utils.toWei("5", "ether") ),
  "gas": 200000,
  "chainId": 5777
}
var rawTx = {
	from: state.currentAddress,
	to: powhrAddress,
	value: numeric(state.ethToSpend),
	data: powhrAPI.fund().encodeABI()
}
/*web3.eth.accounts.signTransaction(rawTransaction, accounts[0].private )
	.then(signedTx => web3.eth.sendSignedTransaction(signedTx.rawTransaction))
	.then(receipt => console.log("Transaction receipt: ", receipt))
	.catch(err => console.error(err));
*/
web3.eth.sendTransaction(rawTx)
	.then(receipt => console.log("Transaction receipt: ", receipt))

web3.eth.getBalance(accounts[0].public).then(console.log);
