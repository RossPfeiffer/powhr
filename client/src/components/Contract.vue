<template>
  <div id="contract">
    <nav-menu></nav-menu>
    <div id="exchange-page">
      <header id="heeedddd">
        <h1>Colors Exchange</h1>
        <div id="contract-nav" v-if="mode=='color'">
          <button v-bind:class="{ selected: (tab == 0) }" @click="tabSelect(0)">Exchange</button>
          <button v-bind:class="{ selected: (tab == 1) }" @click="tabSelect(1)">DAO</button>
          <!--<button v-bind:class="{ selected: (tab == 2) }" @click="tabSelect(2)">Stats</button>-->
        </div>
        <div class="clear"></div>
      </header>
      <metamask-gateway>
        <exchange v-if="tab==0"/>
        <d-a-o v-if="tab==1"/>
        <stats v-if="tab==2"/>
      </metamask-gateway>
    </div>
    <footer><a :href="'https://ropsten.etherscan.io/address/'+powhrAddress" target="_blank">Pyramid Contract</a> | <a :href="'https://ropsten.etherscan.io/address/'+tokenAddress" target="_blank">Resolve Contract</a> | <a :href="'https://ropsten.etherscan.io/address/'+colorAddress" target="_blank">Color Contract</a></footer>
  </div>
</template>
<script>
import Chart from 'chart.js';

import { mapState } from 'vuex'
import MetamaskGateway from '@/components/Metamask-Gateway'
import Exchange from '@/components/Exchange'
import DAO from '@/components/DAO'
import Stats from '@/components/Stats'
import NavMenu from '@/components/Nav-Menu'

import powhrAddress from '../store/powhrAddress'
import tokenAddress from '../store/tokenAddress'
import colorAddress from '../store/colorAddress'
console.log("Pyramid Contract: https://ropsten.etherscan.io/address/"+powhrAddress,"\nToken Contract: https://ropsten.etherscan.io/address/"+tokenAddress,"\nColor Contract: https://ropsten.etherscan.io/address/"+colorAddress)

export default {
  name: 'market',
  created(){
    this.$store.dispatch("connectToMetaMask")
    this.$store.commit("update_urlGateway", this.$route.params.masternode)
  },
  data(){return{
      tab:0,
      powhrAddress:powhrAddress,
      tokenAddress:tokenAddress,
      colorAddress:colorAddress
  }},
  methods:{
    tabSelect(x){
      this.tab = x;
    }
  },
  components: {
    NavMenu,
    Exchange,
    DAO,
    Stats,
    MetamaskGateway
  },
  computed:{
    ...mapState([
      "mode"
    ])
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style>
#exchange-page{
  padding-top:30px;
  max-width:80%;
  margin:0 auto;
}
#contract{
  min-height: 100vh;
  position: relative;
  padding-bottom: 100px;
}
#contract footer{
  position: absolute;
  bottom:0;
  width:100%;
  text-align: center;
  background-color: #8e8e8e;
  padding-top: 5px;

}
#contract footer a{
  color:white;
}
#contract header{
  margin-bottom:60px;
  position: relative;
}
#contract header h1{
  position: absolute;
}
#contract-nav{
  width: 100%;
  position: absolute;
  top:20px;
}

#contract-nav button{
  width:80px;
  margin-left:10px;
  margin-right:10px;

  background:#f5f5f5;
  border-style:solid;
  border-width:1.5px;
  border-color:#444;
  padding:7px;
  color: #444;
  position: relative;
  cursor: pointer;
  text-decoration: none;
  display: inline-block;
  width:125px;
}
#contract-nav {
    display: -ms-flexbox;
    display: -webkit-flex;
    display: flex;
    -webkit-flex-direction: row;
    -ms-flex-direction: row;
    flex-direction: row;
    -webkit-flex-wrap: nowrap;
    -ms-flex-wrap: nowrap;
    flex-wrap: nowrap;
    -webkit-justify-content: center;
    -ms-flex-pack: center;
    justify-content: center;
    -webkit-align-content: stretch;
    -ms-flex-line-pack: stretch;
    align-content: stretch;
    -webkit-align-items: flex-start;
    -ms-flex-align: start;
    align-items: flex-start;
    }

#contract-nav button:nth-child(1) {
    -webkit-order: 0;
    -ms-flex-order: 0;
    order: 0;
    -webkit-flex: 0 1 auto;
    -ms-flex: 0 1 auto;
    flex: 0 1 auto;
    -webkit-align-self: auto;
    -ms-flex-item-align: auto;
    align-self: auto;
    }

#contract-nav button:nth-child(2) {
    -webkit-order: 0;
    -ms-flex-order: 0;
    order: 0;
    -webkit-flex: 0 1 auto;
    -ms-flex: 0 1 auto;
    flex: 0 1 auto;
    -webkit-align-self: auto;
    -ms-flex-item-align: auto;
    align-self: auto;
    }

#contract-nav button:nth-child(3) {
    -webkit-order: 0;
    -ms-flex-order: 0;
    order: 0;
    -webkit-flex: 0 1 auto;
    -ms-flex: 0 1 auto;
    flex: 0 1 auto;
    -webkit-align-self: auto;
    -ms-flex-item-align: auto;
    align-self: auto;
    }
</style>
