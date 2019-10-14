<template>
  <div>
    <nav-menu></nav-menu>
    <div id="splash">
      <!--<div class="content">
        <h1>Ethereum's True Scaling Solution</h1>
        <p>
          Scaling the blockchain has profound implications for transaction capacity, anchoring unique value to the ecosystem, and the underlying mechanism has even more.
        </p>
        <button id="go-to-exchange">White Paper</button>
        <button id="go-to-testnet">Testnet</button>
        <button id="go-to-exchange">Exchange</button>
      </div>
      <div class="graphic">
        <img src="../assets/pyramid.svg">
      </div>-->
      <center class="big-image"><img src="../assets/tokenomics.png"> </center>
      <div class="clear"></div>
      <div id="timer">
        <h2>Pyramid Schemes are the Scaling Solution</h2>

        <!--<a class="button">White Paper</a>
        <a class="button">Exchange</a>
        <a class="button">Telegram</a>-->
        <!--<Countdown :end="personalizedTime"></Countdown>-->
        <!--<Countdown :end="personalizedTime"></Countdown>-->
        <a href="https://gist.github.com/Econymous/2e7aa07622bf55619b9790f2fb2190c8" class="button">Git</a>
        <router-link class="button" to="/contract">Exchange</router-link>
        <a href="https://t.me/PrismTokenomics" class="button" target="_blank">Telegram</a>

      </div>
    </div>
    <!--<div id="benefits">
      <div class="benefit">
        <img src="../assets/tokenomics.png"/>
        <h3>Real Tokenomics</h3>
        <p>The Resolve contract presents a duel incentive structure that functions as an engine for economic wealth generation.</p>
      </div>
      <div class="benefit">
        <img src="../assets/intrinsic.png"/>
        <h3>Intrinsic Value</h3>
        <p>Resolve Tokens are evenly distributed by economic forces and have a base value derived from their ability to collect fees from the core contract.</p>
      </div>
      <div class="benefit">
        <img src="../assets/scalability.png"/>
        <h3>Elegant Scalability</h3>
        <p>Perfect distribution stabalizes nested proof-of-stake sidechains using an entirely new financial instrument that has an "inflationary defense" mechanism against whales.</p>
      </div>
      <div class="clear"></div>
    </div>-->
    <!--<div id="potentials">
      <div class="content">
        <h2>The Potentials of Resolve Distribution</h2>
        <div id="potential-grid">
          <div class="potential">
            <img src="../assets/nested-sidechains.png"/>
            <h3>Nested Proof of Stake Sidechains</h3>
            <p>
              Proof of stake is a game of "pay to play", but that game is entirely changed with the resolve token's inflationary defense mechanism. When someone tries to compromise a sidechain running on resolves, bond holders from the core contract are incentivized to release their bonds for resolves at a cheaper rate than a whale can buy them for.
            </p>
          </div>
          <div class="potential">
            <img src="../assets/resource-allocation.png"/>
            <h3>Company/Project Shares</h3>
            <p>
              Resolve tokens are all about one's ratio of holdings to the total supply and therefore are appropiate for controlling allocation of limited resources within a company or project. This allocation can then in turn reward resolve stakers with earnings from the project based on the individual's strategy.
            </p>
            <p>
              The inherent distribution of resolves presents the opportunity for communities to govern the development of their society's infrastructure. Resolve tokens can be applied to building roads, development planning, and the a system of policies that facilitate growth.
            </p>
          </div>
          <div class="potential">
            <img src="../assets/gaming-ecosystem.png"/>
            <h3>Gaming Assets & a Multiverse Experience</h3>
            <p>
              Resolves can be used to crowdsource the governance of digital assets.
              Users can vote on 2D and 3D models, names, attributes and other aspects for these digital objects.
              The fair distribution of resolves ensures a balance of mechanics between these assets and allows for infinite creative throughput.
            </p>
            <p>
              Resolve crowd sourced governance introduces an unprecedented potential for digital assets to be truly meaningful and exchanged across multiple gaming experiences.
              For example, an item used in a first person shooter can be used in a turn-based strategy game or an 8bit MMO.
            </p>
          </div>
          <div class="potential">
            <img src="../assets/geospatial.png"/>
            <h3>The Keystone to Geospatial Protocols</h3>
            <p>
              Region based resolve contracts can be used to fairly elect devices that perform the initial bound witness for a geospatial protocol. This means main-chain level security on the initial boundwitness. This is the final anchor in perfecting proof of location, bringing smart contracts to the physical world through reliable oracles.
            </p>
          </div>
          <div class="potential">
            <img src="../assets/ipfs-killer.png"/>
            <h3>IPFS Killer</h3>
            <p>
              With variable block sizes, the sharding sidechains essentially become proof of storage. Between the multi-thread of blockchains, files can be encrypted and sharded allowing users to securely store private data on public blockchains.
            </p>
          </div>
        </div>
      </div>
    </div>-->
    <!--<footer id="footer">
      <div class="content">
        <div class="footer-goods">
          <h5>Community</h5>
          <ul>
            <li>Discord</li>
            <li>Telegram</li>
            <li>Twitter</li>
          </ul>
        </div>
        <div class="footer-goods">
          <h5>Resolve Contracts</h5>
          <div class="split-list">
            <ul class="">
              <li>________</li>
              <li>______</li>
              <li>___ / ___</li>
              <li>____</li>
              <li>_____</li>
            </ul>
            <ul class="">
              <li>___</li>
              <li>_____</li>
              <li>___</li>
              <li>_____</li>
              <li>________</li>
            </ul>
          </div>
        </div>
        <div class="footer-goods">
          <h5>Technical</h5>
          <ul>
            <li>White Pages</li>
            <li>Github</li>
            <li>Gitter</li>
            <li>Resolve Contract</li>
            <li>Token Contract</li>
          </ul>
        </div>
      </div>
      <div id="floor">0x0000000000000000000000</div>
    </footer>-->
  </div>
</template>

<script>
import NavMenu from '@/components/Nav-Menu'
import Countdown from 'vuejs-countdown'

export default {
  name: 'Home',
  components:{
    NavMenu,
    Countdown
  },
  created(){
    var d = (new Date()).getTimezoneOffset()/60;//20:00
    console.log(d)
    var zone_o_clock = 16 + d
    this.personalizedTime = "October 11, 2019 " + zone_o_clock + ":00" 
  },
  data(){return{
    personalizedTime: ""
  }}
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.big-image img{
  max-width:50%;
  -webkit-filter: grayscale(100%); /* Safari 6.0 - 9.0 */
  filter: grayscale(100%);
}
#splash{
  background-color: #efefef;
  padding:75px;
  padding-bottom:50px;
  color:#444;
  height: 100vh;
  min-height: 550px;
}
#splash .graphic{
  float:right;
  width:50%;
  height:350px;
  background-color: #004488;
}
#splash .content button{float:right;}
#splash .content{
  float:left;
  width:50%;
  background-color: #0099ee;
  padding:25px;
}
#splash h1{
  font-size:32px;
}
#splash p{
  font-size:16px;
}
#timer{
  text-align:center;
}
#timer h4{
  margin-bottom:0;
}
.content{
  /*position: relative;
  top:100px;
  left:100px;*/
}
.content p{
  text-indent: 30px;
  /*width:calc(100% - 200px);*/
}
#splash .button{
  background:none;
  border-style:solid;
  border-width:1px;
  border-color:#777;
  padding:10px;
  color: #444;
  position: relative;
  top:16px;
  cursor: pointer;
  text-decoration: none;
  width:100px;
  display: inline-block;
}
.content .button{
  float:right;
}
.clear{
 clear:both;
}
.benefit{
  width:50%;
  float:left;
  padding:40px;
}
#benefits img{
  max-height: 84px;
}
#benefits, #footer .content, .split-list{
    display: -ms-flexbox;
    display: -webkit-flex;
    display: flex;
    -webkit-flex-direction: row;
    -ms-flex-direction: row;
    flex-direction: row;
    -webkit-flex-wrap: nowrap;
    -ms-flex-wrap: nowrap;
    flex-wrap: nowrap;
    -webkit-justify-content: space-around;
    -ms-flex-pack: justify;
    justify-content:  space-around;
    -webkit-align-content: stretch;
    -ms-flex-line-pack: stretch;
    align-content: stretch;
    -webkit-align-items: flex-start;
    -ms-flex-align: start;
    align-items: flex-start;
}

.benefit:nth-child(1) {
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

.benefit:nth-child(2) {
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

.benefit:nth-child(3) {
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


.footer-goods:nth-child(1) {
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

.footer-goods:nth-child(2) {
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

.footer-goods:nth-child(3) {
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
.footer-goods ul{
  margin-top: 5px;
  list-style-type: none;
  margin:0;
  padding-left:15px;
}
.footer-goods ul li{
  margin-bottom: 8px;
}
.footer-goods{
}
#footer{
  background-color: #808080;
  color:#e7e7e7;
}
#footer h5{
  margin:0;
  margin-bottom: 12px;
}
#footer .content{
  padding-left:75px;
  padding-right:75px;
  max-width: 100%;
  margin: 0 auto;
  padding-top:25px;
}
.split-list{
  width:200px;
}
.split-list ul:nth-child(1) {
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

.split-list ul:nth-child(2) {
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
#floor{
  margin-top:20vh;
  padding-top:3px;
  padding-bottom:3px;
  background-color: #636363;
  text-align: center;
  color:#8a8a8a; 
}
#potentials{
  background-color: #d7d7d7;
  padding:75px;
  color:#4a4a4a;
}
#potential-grid{
  display: grid;
  grid-gap:10px;
  grid-template-columns: auto auto;
}
.potential{
  background-color: #ededed;
  padding:25px;
  position: relative;
  overflow: hidden;
}
.potential p{
  z-index: 100;
  position: relative;
  font-size:115%;
}
.potential img{
  position: absolute;
  right:50px;
  width:50%;
  filter: invert(100%);
  z-index: 10;
}
/* Chain by Kick from the Noun Project */
/* Network by ArtWorkLeaf from the Noun Project */
/* nested-sidechains */

/* Video Game by Graphic Tigers from the Noun Project */
/* adventure by Made from the Noun Project */
/* gaming-ecosystem */

/* Construction by Hopkins from the Noun Project */
/* resource-allocation */

/* global by wardehpillai from the Noun Project */
/* geospatial */

/* computing by Flatart from the Noun Project */
/* ipfs-killer */
</style>
