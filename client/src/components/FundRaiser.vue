<template>
  <div>
    <nav-menu></nav-menu>
    <metamask-gateway>
      <div class="grid-layout">
        <control-box id="" title="Global">
          <contract-data label="Total ETH for Deploy" :value="totalEth4Launch" :img="ethIcon" />
          <contract-data label="Total ETH Donated" :value="totalEthDonated" :img="ethIcon" />
        </control-box>
        <control-box id="" title="Donate">
          <contract-data label="Your ETH for Deploy" :value="yourEth4Launch" :img="ethIcon" />
          <contract-input label="ETH to Donate" placeholder="e.g. 0.12" commit="ethToDonate"/>
          <contract-button action="funding_donate">Donate ETH</contract-button>
          <contract-button action="funding_backout">Retract Position</contract-button>
        </control-box>
        <control-box id="" title="Launch Vote">
          <contract-data label="Launch Contract" value="No Launch Contract Yet"/>
          <contract-data label="Your Approval Status" value="N/A"/>
          <contract-button action="funding_approveLaunch">Approve Launch</contract-button>
          <contract-button action="funding_denyLaunch">Deny Launch</contract-button>
          <div v-if="currentAddress==developerAddress">
            <contract-input label="Propose Contract" placeholder="0x00000" commit="contractToPropose"/>
            <contract-button action="funding_updateLaunchContract">Propose Contract</contract-button>
          </div>
        </control-box>
      </div>
    </metamask-gateway>
  </div>
</template>

<script>
  import { mapState } from 'vuex'
  import MetamaskGateway from '@/components/Metamask-Gateway'
  import ControlBox from '@/components/Control-Box'
  import ContractData from '@/components/Contract-Data'
  import ContractInput from '@/components/Contract-Input'
  import ContractButton from '@/components/Contract-Button'
  import NavMenu from '@/components/Nav-Menu'

  export default {
    name: 'exchange',
    created(){
      this.$store.dispatch("connectToMetaMask")
      this.$store.dispatch("funding_init")
      this.$store.dispatch("funding_updateCycle")
    },
    data(){return{
      ethIcon:require('@/assets/eth-icon.png'),
      resolveIcon:require('@/assets/resolve-icon.png'),
      feeIcon:require('@/assets/resolver-fee-icon.png'),
      bondsIcon:require('@/assets/bonds-icon.png')
    }},
    components: {
      NavMenu,
      ControlBox,
      ContractData,
      ContractInput,
      ContractButton,
      MetamaskGateway
    },
    computed:{
      ...mapState([
        "totalBondSupply",
        "totalStakedResolves",
        "ethInReserve",
        "resolveFee",
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
        "currentAddress",

        "ethToDonate",
        "totalEth4Launch",
        "totalEthDonated",
        "yourEth4Launch",
        "launchContract",
        "developerAddress"
      ])
    }
  }
</script>

<style scoped>
  .grid-layout{
  }
  h4,h5,h6{
    margin:0;
  }
</style>
