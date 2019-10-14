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
    <control-box id="" title="Buy">
      <contract-data label="Buy Price" :value="buyPrice" />
      <contract-input label="ETH to spend" placeholder="e.g. 0.12" commit="ethToSpend" :onChange="estimateBonds"/>
      <contract-button action="buyBonds">Buy Bonds</contract-button><!--<button id="bond-color-picker" v-on:click="openColorBox"></button>-->
      <!--<modal name="color-box">
        <ColorPicker :width="300" :height="300" :disabled="false" startColor="#ff0000" @colorChange="onColorChange"></ColorPicker>
      </modal>-->
      <contract-data label="Estimated Bonds" :value="estimatedBonds" />
    </control-box>
    <control-box id="" title="Your Account">
      <div id="wallet-grid">
        <contract-data label="Bonds" :value="yourBonds" :img="bondsIcon" />
        <contract-data label="ETH Value" :value="yourBondValue" :img="ethIcon" />
        <contract-data label="Resolves in Wallet" :value="yourResolves" :img="resolveIcon" />
        <contract-data label="Your Hodl" :value="yourHodl" :img="clockIcon" />
      </div>
    </control-box>
    <control-box id="" title="Sell">
      <contract-data label="Sell Price" :value="sellPrice" />
      <contract-input label="Bonds to sell" placeholder="e.g. 120" commit="bondsToSell" :onChange="estimateReturns"/>
      <contract-button action="sellBonds">Sell Bonds</contract-button>
      <contract-data label="Estimated ETH" :value="estimatedEth" />
      <contract-data label="Estimated Resolves" :value="estimatedResolves" />
    </control-box>
    <control-box id="" title="Resolve">
      <contract-data label="Resolves Staking" :value="yourStakedResolves" :img="resolveIcon"/>
      <contract-input label="Stake Resolves" placeholder="e.g. 1200" commit="resolvesToStake"/>
      <contract-button action="stakeResolves">Stake Resolves</contract-button>
      <contract-input label="Pull Resolves" placeholder="e.g. 1200" commit="resolvesToPull"/>
      <contract-button action="pullResolves">Pull Resolves</contract-button>
    </control-box>
    <control-box id="" title="Earnings">
      <contract-data label="ETH Dividends " :value="yourEarnings" :img="ethIcon"/>
      <contract-input label="Earnings to Pull" placeholder="e.g. 0.48" commit="earningsToPull"/>
      <contract-button action="withdrawEarnings">Pull Earnings</contract-button>
      <contract-input label="Earnings to Reinvest" placeholder="e.g. 0.48" commit="earningsToReinvest"/>
      <contract-button action="reinvestEarnings">Reinvest Earnings</contract-button>
      <contract-data label="Remaining Resolves" value="0.000" />
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

  console.log("Sketttttch")
  //console.log(Sketch)
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
      estimateReturns(){this.$store.dispatch("estimateReturns")},
      buyColor:{ r: 255, g: 0, b: 0 }
    }},
    methods: {
      onColorChange(color) {
        console.log('Color has changed to: ', color);
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
        "yourHodl"
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
h4,h5,h6{
  margin:0;
}

</style>
