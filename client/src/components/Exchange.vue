<template>
  <div class="grid-layout">
    <control-box title="Global">
      <div id="global-grid">
        <contract-data label="ETH in Reserve" :value="ethInReserve" :img="ethIcon" />
        <contract-data label="Circulating Bonds" :value="totalBondSupply" :img="bondsIcon" />
        <contract-data label="Resolve Pool" :value="totalStakedResolves" :img="resolveIcon" />
        <contract-data label="Resolve Fee" :value="resolveFee" :img="feeIcon" />
        <contract-data label="Release Hodl" :value="avgHodlRelease" :img="clockIcon" />
      </div>
    </control-box>
    <control-box id="buy-box" title="Buy">
      <contract-data label="Buy Price" :value="buyPrice" />
      <contract-input label="ETH to spend" placeholder="e.g. 0.12" commit="ethToSpend" :onChange="estimateBonds"/>
      <contract-button action="buyBonds">Buy Bonds</contract-button>
      <button id="bond-color-picker" v-on:click="openColorBox" v-bind:style="{ backgroundColor: buyColor}"></button>
      <modal id="color-box" name="color-box" :width="240" :height="240" classes="color-modal">
        <ColorPicker :width="240" :height="240" :disabled="false" :startColor="buyColor" @colorChange="onColorChange"></ColorPicker>
      </modal>
      <contract-data label="Estimated Bonds" :value="estimatedBonds" />
    </control-box>
    <control-box id="" title="Your Account">
        <contract-data label="Bonds" :value="yourBonds" :img="bondsIcon"  v-bind:style="{ backgroundColor: bondColor}"/>
        <contract-data label="ETH Value" :value="yourBondValue" :img="ethIcon" />
        <contract-data label="Resolves in Wallet" :value="yourResolves" :img="resolveIcon" v-if="mode!='color'"/>
        <contract-data label="Your Hodl" :value="yourHodl" :img="clockIcon" />
        <div class="gap"></div>
        <div class="gap"></div>
        <div class="gap"></div>
        <!--<div class="gap"><div class="color-indicator" v-bind:style="{ backgroundColor: bondColor}"><img :src="bondsIcon"/>Bonds</div></div>-->
    </control-box>
    <control-box id="" title="Sell">
      <contract-data label="Sell Price" :value="sellPrice" />
      <contract-input label="Bonds to sell" placeholder="e.g. 120" commit="bondsToSell" :onChange="estimateReturns"/>
      <contract-button action="sellBonds">Sell Bonds</contract-button>
      <contract-data label="Estimated ETH" :value="estimatedEth" />
      <contract-data label="Estimated Resolves" :value="estimatedResolves" />
    </control-box>
    <control-box id="" title="Resolve">
      <contract-data label="Resolves in Wallet" :value="yourResolves" :img="resolveIcon"  v-if="mode=='color'" v-bind:style="{ backgroundColor: resolveColor}"/>
      <!--<div v-if="mode=='color'" class="gap"><div class="color-indicator" v-bind:style="{ backgroundColor: resolveColor}"><img :src="resolveIcon"/>Resolves</div></div>-->
      <contract-data label="Resolves Staking" :value="yourStakedResolves" :img="resolveIcon"/>
      <contract-input label="Stake Resolves" placeholder="e.g. 1200" commit="resolvesToStake"/>
      <contract-button action="stakeResolves">Stake Resolves</contract-button>
      <contract-input v-if="mode!='color'" label="Pull Resolves" placeholder="e.g. 1200" commit="resolvesToPull"/>
      <contract-button v-if="mode!='color'" action="pullResolves">Pull Resolves</contract-button>
    </control-box>
    <control-box id="" title="Earnings">
      <contract-data label="ETH Dividends " :value="yourEarnings" :img="ethIcon"/>
      <contract-input v-if="mode!='color'" label="Earnings to Pull" placeholder="e.g. 0.48" commit="earningsToPull"/>
      <contract-button action="withdrawEarnings">Withdraw</contract-button>
      <contract-input v-if="mode!='color'" label="Earnings to Reinvest" placeholder="e.g. 0.48" commit="earningsToReinvest"/>
      <contract-button action="reinvestEarnings">Reinvest Earnings</contract-button>
      <contract-data v-if="mode!='color'" label="Remaining Resolves" value="0.000" />
    </control-box>
  </div>
</template>

<script>
  import { mapState } from 'vuex'
  import ControlBox from '@/components/Control-Box'
  import ContractData from '@/components/Contract-Data'
  import ContractInput from '@/components/Contract-Input'
  import ContractButton from '@/components/Contract-Button'
  import VueCharts from 'vue-chartjs'
  import ColorPicker from 'vue-color-picker-wheel'

  export default {
    name: 'exchange',
    created(){
      this.$store.dispatch("updateCycle")
    },
    data(){return{
      ethIcon:require('@/assets/eth-icon.png'),
      resolveIcon:require('@/assets/resolve.png'),
      feeIcon:require('@/assets/resolver-fee-icon.png'),
      bondsIcon:require('@/assets/bonds.png'),
      clockIcon:require('@/assets/clock.png'),
      estimateBonds(){this.$store.dispatch("estimateBonds")},
      estimateReturns(){this.$store.dispatch("estimateReturns")}
    }},
    methods: {
      onColorChange(color) {
        console.log("COLOR_____",color)
        this.$store.dispatch("update_buyColor", color)
      },
      openColorBox(){
        this.$modal.show("color-box")
      }
    },
    components: {
      ControlBox,
      ContractData,
      ContractInput,
      ContractButton,
      ColorPicker
    },
    computed:{
      ...mapState([
        "totalBondSupply",
        "totalStakedResolves",
        "ethInReserve",
        "resolveFee",
        "poolFunds",
        "buyPrice",
        "sellPrice",
        "yourBonds",
        "yourBondValue",
        "yourResolves",
        "yourStakedResolves",
        "yourEarnings",
        "estimatedBonds",
        "estimatedEth",
        "estimatedResolves",
        "avgHodlRelease",
        "yourHodl",
        "bondColor",
        "resolveColor",
        "buyColor",
        "mode"
      ])
    }
  }
</script>

<style scoped>
.grid-layout{ 
  display: grid;
  grid-gap: 10px;
  grid-template-columns: auto auto auto;
}
#global-grid{
  display: grid;
  grid-template-columns: auto auto; 
}
#wallet-grid{
  display: grid;
  grid-template-columns: auto auto; 
}
#buy-box{
  position: relative;
}
#bond-color-picker{
  width: 32px;
  height: 24px;
  display: block;
  left:110px;
  transform: translate(0px,-36px);
  position: absolute;
}
#color-box .color-modal{
  width:320px;
  height:240px;
  padding: 20px;
}
.color-indicator{
  padding-left: 3px;
  border-style:solid;
  border-width:1px;
  height:28px;
  line-height: 28px;
  max-width:100px;
}
.gap{padding: 3px;}
.color-indicator img{
  width:24px;
  display: inline;
  margin-right: 3px;
}
h4,h5,h6{
  margin:0;
}

</style>
