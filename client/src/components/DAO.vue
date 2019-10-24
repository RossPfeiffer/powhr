<template>
  <div class="grid-layout">
    <control-box title="Masternode Requirement">
      <h2>{{masternodeRequirement}}</h2>
      <contract-input label="Vote for Requirement" commit="inputMR" placeholder="e.g. 100"/>
      <contract-button action="voteForMR">Vote</contract-button>
      <contract-data label="Your Suggested Requirement" :value="yourSuggestedMR" />
    </control-box>
    <control-box title="Community Resolve">
      <h2>{{communityResolve}}</h2>
      <contract-input label="Vote for Candidate" commit="inputCR" placeholder="e.g. 0xabcdef123456"/>
      <contract-button action="voteForCR">Vote</contract-button>
      <contract-data label="Your Candidate" :value="yourCandidate" />
    </control-box>
  </div>
</template>

<script>
  import { mapState } from 'vuex'
  import ControlBox from '@/components/Control-Box'
  import ContractData from '@/components/Contract-Data'
  import ContractInput from '@/components/Contract-Input'
  import ContractButton from '@/components/Contract-Button'
  
  export default {
    name: 'd-a-o',
    created(){
    },
    data(){return{
      /*ethIcon:require('@/assets/eth-icon.png'),
      bondsIcon:require('@/assets/bonds-icon.png'),
      estimateBonds(){this.$store.dispatch("estimateBonds")},*/
    }},
    components: {
      ControlBox,
      ContractData,
      ContractInput,
      ContractButton
      /*ContractData*/
    },
    computed:{
      ...mapState([
        "yourCandidate",
        "yourSuggestedMR",
        "masternodeRequirement",
        "communityResolve"
      ])
    }
  }
</script>

<style scoped>
.grid-layout{ 
  display: grid;
  grid-gap: 10px;
  grid-template-columns: auto auto;
}
#global-grid{
  display: grid;
  grid-template-columns: auto auto; 
}
</style>
