import Vue from 'vue'
import Vuex from 'vuex'
import state from './state'
import eth from '../util/eth'
import _powhrInterface from './powhrInterface'
import powhrAddress from './powhrAddress'
import _tokenInterface from './tokenInterface'
import tokenAddress from './tokenAddress'
import _colorInterface from './colorInterface'
import colorAddress from './colorAddress'
import Web3 from 'web3'
import hodlConvert from 'convert-seconds';


var web3, BN;

var powhrAPI, tokenAPI, resolveContract, tokenContract, colorAPI, colorContract, relativeAddress

var Big = require('big.js')
var asdf = 0;

function componentToHex(c) {
  var hex = c.toString(16);
  return hex.length == 1 ? "0" + hex : hex;
}

function rgbToHex(r, g, b) {
  return "#" + componentToHex(r) + componentToHex(g) + componentToHex(b);
}

//alert(rgbToHex(0, 51, 255)); // #0033ff


Vue.use(Vuex)
export const store = new Vuex.Store({
  strict: true,
  state,
  mutations: {
    walletLockToggle (state, unlocked) {
      //console.log("----->>>>>>",web3.eth.givenProvider.selectedAddress)
      //web3.eth.getAccounts(accounts => console.log("ACCOUNTs",accounts) )
      if(unlocked && web3.eth.givenProvider.selectedAddress){
        console.log("so you've got the provider?",web3.eth.givenProvider)
        console.log("so you've got the selectedAddress?",web3.eth.givenProvider.selectedAddress)
        state.currentAddress = web3.eth.givenProvider.selectedAddress
        console.log("current address:", web3.eth.givenProvider.selectedAddress)
        state.walletUnlocked = true
        console.log("user has given access", state.currentAddress)
      }else{
        state.walletUnlocked = false
        state.currentAddress = "0x0000000000000000000000000000000000000000"
        console.log("wallet is locked. no access")
      }
      resolveContract = _powhrInterface.init(web3)
      colorContract = _colorInterface.init(web3)
      tokenContract = _tokenInterface.init(web3)
      powhrAPI = resolveContract.methods
      tokenAPI = tokenContract.methods
      colorAPI = colorContract.methods

      window._events = resolveContract;
      _events.getPastEvents("allEvents",{fromBlock:5742328}).then(function(r){console.log(r)})
    },
    update_currentAddress(state,value){state.currentAddress = value},
    update_resolveTokenAddress(state,value){state.resolveAddress = value},
    update_ethToSpend(state,value){state.ethToSpend = value},
    update_bondsToSell(state,value){state.bondsToSell = value},
    update_resolvesToStake(state,value){state.resolvesToStake = value},
    update_resolvesToPull(state,value){state.resolvesToPull = value},
    update_earningsToPull(state,value){state.earningsToPull = value},
    update_earningsToReinvest(state,value){state.earningsToReinvest = value},
    update_totalBondSupply(state,value){state.totalBondSupply = value},
    update_poolFunds(state,value){state.poolFunds = value},
    update_totalStakedResolves(state,value){state.totalStakedResolves = value},
    update_ethInReserve(state,value){state.ethInReserve = value},
    update_resolveFee(state,value){state.resolveFee = value},
    update_buyPrice(state,value){state.buyPrice = value},
    update_sellPrice(state,value){state.sellPrice = value},
    update_yourBonds(state,value){state.yourBonds = value},
    update_yourBondValue(state,value){state.yourBondValue = value},
    update_yourResolves(state,value){state.yourResolves = value},
    update_yourStakedResolves(state,value){state.yourStakedResolves = value},
    update_yourEarnings(state,value){state.yourEarnings = value},
    update_estimatedBonds(state,value){state.estimatedBonds = value},
    update_avgHodlRelease(state,value){state.avgHodlRelease = value},
    update_collectiveCurrentHodl(state,value){state.collectiveCurrentHodl = value},
    update_yourHodl(state,value){state.yourHodl = value},
    update_estimatedReturns(state,data){
      state.estimatedEth = data.eth
      state.estimatedResolves = data.resolves
    },
    update_developerAddress(state,value){state.developerAddress = value},
    update_ethToDonate(state,value){state.ethToDonate = value},
    update_yourEth4Launch(state,value){state.yourEth4Launch = value},
    update_totalEth4Launch(state,value){state.totalEth4Launch = value},
    update_totalEthDonated(state,value){state.totalEthDonated = value},
    update_contractToPropose(state,value){state.contractToPropose = value},
    update_bondColor(state,value){state.bondColor = value},
    update_resolveColor(state,value){state.resolveColor = value;},
    update_buyColor(state,value){state.buyColor = value},
    rpcActivate(state){console.log("LIVE UPDATES COMING IN")
      state.rpcActive = true},
    update_yourSuggestedMR(state,value){state.yourSuggestedMR = value;},
    update_yourCandidate(state,value){state.yourCandidate = value;},
    update_masternodeRequirement(state,value){state.masternodeRequirement = value;},
    update_communityResolve(state,value){state.communityResolve = value;},
    update_inputMR(state,value){state.inputMR = value;},
    update_inputCR(state,value){state.inputCR = value;},
  },
  actions: {
    connectToMetaMask: async ({commit, dispatch,state}) => {
        let metamask = false
        let provider

        try{
          await ethereum.enable().then(function(){
            provider = window.web3.currentProvider;
            metamask = true;
            web3 = new Web3(provider);
            console.log("_init",metamask)
            console.log("_____so you've got the provider?", web3.eth.givenProvider)
            console.log("_____selected address?", web3.eth.givenProvider.selectedAddress)
            var addressChecker = setInterval(function(){
              if(web3.eth.givenProvider.selectedAddress){
                clearInterval(addressChecker)
                commit('walletLockToggle', metamask)
                if(state.mode=="color"){
                  console.log("dispatch for proxy address")
                  dispatch("getProxyAddress")
                }else{
                  relativeAddress = state.currentAddress;
                  commit('rpcActivate')
                } 
              }
            },500)
          })
        }catch(err){
          console.log(">>>>>>>>>>>>>MM error",err)
          if (typeof web3 !== 'undefined') {
              console.log('web3 defined')
              web3 = new Web3(web3.currentProvider)
              metamask = true
          }else if(window.web3 && window.web3.currentProvider){
              console.log('provider exists')
              provider = window.web3.currentProvider
              metamask = true;
              web3 = new Web3(provider)
          }else{
              console.log('infura')
              //HTTP://127.0.0.1:7545
              //provider = new Web3.providers.HttpProvider("http://127.0.0.1:7545")
              provider = new Web3.providers.HttpProvider("https://ropsten.infura.io/v3/56102f35cb314362a455c7cf6958961e");
              web3 = new Web3(provider)
          }
          console.log("...init",metamask)
          commit('walletLockToggle', metamask)
          if(state.mode=="color"){
            console.log("dispatch for proxy address")
            dispatch("getProxyAddress")
          }else{
            relativeAddress = state.currentAddress;
            commit('rpcActivate')
          }
        }
    },
    getProxyAddress: ({commit, dispatch, state})=>{
      colorAPI.proxyAddress(state.currentAddress).call().then( (proxyAddress)=>{
        console.log("Proxy Address")
        console.log(proxyAddress)
        relativeAddress = proxyAddress;
        commit('rpcActivate')
      })
    },
    updateCycle: async({commit,dispatch,state})=>{
      setInterval(function(){
        if(state.currentAddress != web3.eth.givenProvider.selectedAddress){
          commit('update_currentAddress',web3.eth.givenProvider.selectedAddress)          
          commit("update_resolveColor", rgbToHex(255,255,255) )
          commit("update_bondColor", rgbToHex(255,255,255) )
        }
        if(state.rpcActive) {
          powhrAPI.reserve().call().then( (r)=>{
            commit("update_ethInReserve", eth.convertWeiToEth( eth.int(r) )
            .toFixed(5).toString())
          })
          powhrAPI.pricing(1e12+"").call().then( (r)=>{
            commit( "update_buyPrice", (r[0]/1e18).toFixed(9) )
            commit( "update_sellPrice", (r[1]/1e18).toFixed(9) )
            asdf = eth.int(r[2])/1e10
            commit("update_resolveFee",  ( asdf ).toFixed(2)+"%" )
          })/**/


          if(state.mode!="color"){
            powhrAPI.totalSupply().call().then( (r)=>{
              let bigR = Big(r.toString())
              bigR = bigR.div(1e12)
              let bonds = bigR.toFixed(2)
              commit("update_totalBondSupply", bonds)
            }).catch( err )   
          }else{
            colorAPI.getData("0x0000000000000000000000000000000000000000","-1").call().then( (r)=>{
              let bonds = Big(r[3].toString()).div(1e12).toFixed(2)
              let MR = Big(r[5].toString()).div(1e12).toFixed(2)
              let CR = r[2]
              commit("update_totalBondSupply", bonds)
              commit("update_masternodeRequirement", MR)
              commit("update_communityResolve", CR)
            }).catch( err )
          }

          colorAPI.getData(state.currentAddress,"0").call().then( (r)=>{
            let MR = Big(r[5].toString()).div(1e12).toFixed(4)
            let CR = r[2]
            commit("update_yourSuggestedMR", MR)
            commit("update_yourCandidate", CR)
          }).catch( err )
          /*powhrAPI.poolFunds().call().then( (r)=>{
            let bigR = Big(r.toString())
            bigR = bigR.div(1e18)
            let funds = bigR.toFixed(4)
            commit("update_poolFunds", funds)
          })
          powhrAPI.reserve().call().then( (r)=>{
            console.log("++++++",r)
          })*/
          powhrAPI.sellSum().call().then( (ss)=>{
            if (ss>0){
              powhrAPI.avgHodl().call().then( (r)=>{
                let x = 0
                try{
                  let bigR = Big(r.toString())
                  bigR = bigR.div(60)
                  x = bigR.toFixed(2)
                }catch(err){}
                commit("update_avgHodlRelease", x.toString()+" Minutes")
              })
            }else{commit("update_avgHodlRelease", "N/A")}
          })
          
          
          powhrAPI.resolveWeight(relativeAddress).call().then( (r)=>{
            let bigR = Big(r.toString())
            bigR = bigR.div(1e18)
            let resolves = bigR.toFixed(9)
            commit("update_yourStakedResolves", resolves )
          })/**/
          

          if(state.mode=="color"){
            colorAPI.proxyAddress(state.currentAddress).call().then( (r)=>{
              relativeAddress = r
            })

            colorAPI.RGB_resolveRatio(state.currentAddress).call().then( (r)=>{
              let red = parseInt((parseInt(r[0]) / 1e18)*255)
              let green = parseInt((parseInt(r[1]) / 1e18)*255)
              let blue = parseInt((parseInt(r[2]) / 1e18)*255)
              //console.log("resolves: ",parseFloat(state.yourResolves) ,"---- RGB", red,green,blue)
              if(parseFloat(state.yourResolves)>0){
                console.log("resolves: ",parseFloat(state.yourResolves) ,"---- RGB", red,green,blue)
                commit("update_resolveColor", rgbToHex(red,green,blue) )
            }
            })
            colorAPI.RGB_bondRatio(state.currentAddress).call().then( (r)=>{
              let red = parseInt((parseInt(r[0]) / 1e12)*255)
              let green = parseInt((parseInt(r[1]) / 1e12)*255)
              let blue = parseInt((parseInt(r[2]) / 1e12)*255)
              //console.log(red,green,blue)
              
              if(parseFloat(state.yourBonds)>0)
              commit("update_bondColor", rgbToHex(red,green,blue) )
            })/**/
            colorAPI.RGB_bondRatio(state.currentAddress).call().then( (r)=>{

            })  
            /*colorAPI.RGB_bondRatio(state.currentAddress).call().then( (r)=>{
              let bigR = Big(r.toString())
              bigR = bigR.div(1e18)
              let numeric = bigR.toFixed(6)
              console.log("bond RGB",r)
              //commit("update_yourEarnings", numeric )
            })*/
          }
          
          
          powhrAPI.dissolvingResolves().call().then( (r)=>{
            let bigR = Big(r.toString())
            bigR = bigR.div(1e18)
            let resolves = bigR.toFixed(4)
            commit("update_totalStakedResolves", resolves )
          })/**/
          
          //console.log("relativeAddress",relativeAddress)
          if(relativeAddress != "0x0000000000000000000000000000000000000000"){
            powhrAPI.balanceOf(relativeAddress).call().then( (r)=>{
              let bigR = Big(r.toString())
              bigR = bigR.div(1e12)
              let bonds = bigR.toFixed(2)
              commit("update_yourBonds", bonds )
              powhrAPI.getEtherForBonds( r ).call().then( (rr)=>{
                commit("update_yourBondValue",eth.convertWeiToEth( eth.int( rr*(1-asdf/100) ) )                
                .toFixed(5).toString())
              })/**/
            })

            tokenAPI.balanceOf(relativeAddress).call().then( (r)=>{
              let bigR = Big(r.toString())
              bigR = bigR.div(1e18)
              let resolves = bigR.toFixed(9)
              commit("update_yourResolves", resolves)
            })

            powhrAPI.avgFactor_buyInTimeSum(relativeAddress).call().then( (r)=>{
              powhrAPI.avgFactor_ethSpent(relativeAddress).call().then( (r2)=>{
                powhrAPI.NOW().call().then( (r3)=>{
                  if(r2 > 0){
                    let seconds = (r3-(r/0x10000000000000000)/r2);
                    let hodl = hodlConvert(seconds)
                    //console.log("Your Hodl",hodl.hours + ' H ' +hodl.minutes + ' M' )
                    commit("update_yourHodl", hodl.hours + ' H ' +hodl.minutes + ' M' )
                  }else{
                    commit("update_yourHodl",'N/A' )
                  }
                })
              })
            })

            powhrAPI.resolveEarnings(relativeAddress).call().then( (r)=>{
              let bigR = Big(r.toString())
              bigR = bigR.div(1e18)
              let numeric = bigR.toFixed(6)
              commit("update_yourEarnings", numeric )
            })
          }/**/
        }
      },1000)
    },
    buyBonds: ({commit, dispatch, state})=>{
      let address, API;
      function hexToRgb(hex) {
        var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
        return result ? {
          r: parseInt(result[1], 16),
          g: parseInt(result[2], 16),
          b: parseInt(result[3], 16)
        } : null;
      }
      let rgb = hexToRgb(state.buyColor)

      if( state.mode=="color" ){
        let bigR = parseInt(Big(1e12).mul(rgb.r).div(255)).toString()
        let bigG = parseInt(Big(1e12).mul(rgb.g).div(255)).toString()
        let bigB = parseInt(Big(1e12).mul(rgb.b).div(255)).toString()
        console.log("____ COLORS RBG ____")
        console.log(bigR,bigG,bigB)
        API = colorAPI.buy(state.currentAddress,bigR,bigG,bigB,"0x0000000000000000000000000000000000000000")
        address = colorAddress
      }else{
        API = powhrAPI.fund()
        address = powhrAddress
      }
      web3.eth.sendTransaction({
        from: state.currentAddress,
        to: address,
        value: weiForm(state.ethToSpend),
        data: API.encodeABI()
      },(e,hash)=>{
        err(e)
      });
    },
    sellBonds: ({commit, dispatch, state})=>{
      let address, API;
      if(state.mode=="color"){
        API = colorAPI.publix("0", weiForm( parseFloat(state.bondsToSell)/1e6+"" ) )
        address = colorAddress
      }else{
        API = powhrAPI.sellBonds( weiForm( parseFloat(state.bondsToSell)/1e6+"" ) )
        address = powhrAddress
      }
      web3.eth.sendTransaction({
        from: state.currentAddress,
        to: address,
        data: API.encodeABI()
      },(e,hash)=>{
        err(e)
      });/*
      let bondsToSell = new Big( state.bondsToSell );
      console.log("Bonds being sold::", bondsToSell.toString() )
      bondsToSell = bondsToSell.times(1e18)
      console.log("Bonds being sold--", bondsToSell.toString() )
      powhrAPI.sellBonds(bondsToSell, function(){console.log("Clear Inputs and estimates")})*/
    },
    estimateBonds: ({commit, dispatch, state})=>{
      let number = parseFloat(state.ethToSpend)
      console.log("The User Input:")
      console.log(number)
      

      if (Number.isNaN(number)) number = 0
      if (number > 0){
        let ETS = parseFloat(state.ethToSpend);
        if(state.mode=="color"){
            ETS *= 0.9
        }
        let x = ETS * ( 1 - asdf/100 ) +''
        powhrAPI.getBondsForEther( weiForm( x ) ).call().then( (r)=>{
          console.log("What the contract gives back")
          console.log(r)
          let bigR = Big( r.toString() )
          bigR = bigR.div(1e18/1e6)
          let bonds = bigR.toFixed(2)
          commit("update_estimatedBonds", bonds)
        })
      }
    },
    estimateReturns:({commit, dispatch, state})=>{
      let humanReadableNumber = (parseFloat(state.bondsToSell)/1e6)+""
      console.log(humanReadableNumber)
      if( parseFloat(humanReadableNumber)!==0 ){
        powhrAPI.getReturnsForBonds(relativeAddress, weiForm(humanReadableNumber) ).call().then( (r)=>{
          console.log("RRR")
          console.log(r)
          let bigE = Big( r[0].toString() )
          bigE = bigE.div(1e18)
          bigE = bigE.div( 1/(1 - asdf/100)  )
          let eth = bigE.toFixed(9)

          let bigR = Big( r[1].toString() )
          bigR = bigR.div(1e18)
          let resolves = bigR.toFixed(9)
          commit("update_estimatedReturns", {eth,resolves}) 
          console.log("THIS STILL NEEDS THE FEE CALC'D IN",eth)
        })
      }
    },
    stakeResolves: async({commit, dispatch, state})=>{
      let address, API;
      if(state.mode=="color"){
        API = colorAPI.publix("1", weiForm(state.resolvesToStake) )
        address = colorAddress
      }else{
        API = tokenAPI.transfer(powhrAddress, weiForm(state.resolvesToStake) )
        address = tokenAddress
      }
      web3.eth.sendTransaction({
        from: state.currentAddress,
        to: address,
        data: API.encodeABI()
      },(e,hash)=>{
        err(e)
      });
    },
    pullResolves: async({commit, dispatch, state})=>{
      let address, API;
      if(state.mode=="color"){
        API = colorAPI.publix("2", weiForm(state.resolvesToPull) )
        address = colorAddress
      }else{
        API = powhrAPI.pullResolves( weiForm(state.resolvesToPull) )
        address = powhrAddress
      }
      web3.eth.sendTransaction({
        from: state.currentAddress,
        to: address,
        data: API.encodeABI()
      },(e,hash)=>{
        err(e)
      });
    },
    withdrawEarnings: async({commit, dispatch, state})=>{
      let address, API;
      if(state.mode=="color"){
        API = colorAPI.publix("4",weiForm(state.earningsToPull))
        address = colorAddress
      }else{
        API = powhrAPI.withdraw( weiForm(state.earningsToPull) )
        address = powhrAddress
      }
      web3.eth.sendTransaction({
        from: state.currentAddress,
        to: address,
        data: API.encodeABI()
      },(e,hash)=>{
        err(e)
      });
    },
    reinvestEarnings: async({commit, dispatch, state})=>{
      let address, API;
      if(state.mode=="color"){
        API = colorAPI.publix("3",weiForm(state.earningsToReinvest))
        address = colorAddress
      }else{
        API = powhrAPI.reinvestEarnings( weiForm(state.earningsToReinvest) )
        address = powhrAddress
      }
      web3.eth.sendTransaction({
        from: state.currentAddress,
        to: address,
        data: API.encodeABI()
      },(e,hash)=>{
        err(e)
      });
    },
    voteForCR: async({commit, dispatch, state})=>{
      web3.eth.sendTransaction({
        from: state.currentAddress,
        to: colorAddress,
        data: colorAPI.setVotingForCR( state.inputCR ).encodeABI()
      },(e,hash)=>{
        err(e)
      });
    },
    voteForMR: async({commit, dispatch, state})=>{
      web3.eth.sendTransaction({
        from: state.currentAddress,
        to: colorAddress,
        data: colorAPI.publix( 5, weiForm(state.inputMR) ).encodeABI()
      },(e,hash)=>{
        err(e)
      });
    }
  }
})


function err(e){
  console.log(e)
}

function numeric(x){
  console.log("x",x)
  let toWei = web3.utils.toWei( x )
  let BN = web3.utils.toBN( toWei )
  return web3.utils.toHex( BN )
}
function weiForm(x){
  return web3.utils.toHex( web3.utils.toWei(x, "ether") )
}
function filler(){
  var accounts = [
    {public:"0XB3AB31D37270B5A6FB5F7076650246B5153A08D0",
    private:"4613cec1c2ab9e47cd564966c59d851caaae07348fc244282e792e758ea658a5"},
    {public:"0X3A234FB5562E7EDC80D0724759D3CEBCF957A653",
    private:"7e7af0dd4e4bdc3fe18fc178380ddea0fb429f08059ecc39a001d2850c72da82"},
    {public:"0X169A7D0085C16020EB6F1CC31CB08A3DE9BF4668",
    private:"42491aa771b6b42dda0f94f9a79acf548a399f534b23561c54c3684c10f8167a"},
  ]
  var rawTx = {
    from: accounts[0].public,
    to: powhrAddress,
    value: web3.utils.toHex( web3.utils.toWei("0.2", "ether") ),//numeric(state.ethToSpend),
    data: powhrAPI.fund().encodeABI(),
    "gas": 200000,
    "chainId": 5777
  } 


  web3.eth.accounts.signTransaction({
    to: "0XB3AB31D37270B5A6FB5F7076650246B5153A08D0",
    value: "1000000000000",//web3.utils.toHex( web3.utils.toWei("5", "ether") ),
    gas: 2000000
  }, '42491aa771b6b42dda0f94f9a79acf548a399f534b23561c54c3684c10f8167a')
  .then(signedTx => {
    console.log("signedTx_____",signedTx)
    console.log("rawTx___-___",signedTx.rawTransaction)
    web3.eth.sendSignedTransaction(signedTx.rawTransaction)
  })
  //.then(receipt => console.log("Transaction receipt: ", receipt))

  //console.log("Trying to send Transaction")
  /*
  web3.eth.accounts.signTransaction(rawTx, accounts[0].private)
  .catch(err => console.error(err));*/
  //.then(signedTx => web3.eth.sendSignedTransaction(signedTx.rawTransaction) )
  //.then(receipt => console.log("Transaction receipt: ", receipt))
  
  /*
  web3.eth.accounts.signTransaction(rawTx, accounts[0].private)
  .then(signedTx => web3.eth.sendSignedTransaction(signedTx.rawTransaction) )
  .then(receipt => console.log("Transaction receipt: ", receipt))
  .catch(err => console.error(err));
  */
  web3.eth.getBalance(accounts[0].public).then(x=>{
    console.log("account balance",x)
  });
}