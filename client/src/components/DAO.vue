<template>
  <div class="grid-layout">
    <control-box title="Masternode Requirement">
      <h2>{{masternodeRequirement}}</h2>
      <contract-input label="Vote for Requirement" commit="inputMR" placeholder="e.g. 100"/>
      <contract-button action="voteForMR">Vote</contract-button>
      <contract-data label="Your Suggested Requirement" :value="yourSuggestedMR" />
      <contract-data label="Your Gateway" :value="yourGateway" />
    </control-box>
    <control-box title="Community Resolve">
      <h2>{{communityResolve}}</h2>
      <h2>{{communityFund}} ETH</h2>
      <contract-input label="Vote for Candidate" commit="inputCR" placeholder="e.g. 0xabcdef123456"/>
      <contract-button action="voteForCR">Vote</contract-button>
      <contract-data label="Your Candidate" :value="yourCandidate" />
    </control-box>
    <control-box title="Resolve Naming Service" id="rns-box">
      <div id="name-stake">
        <div><contract-input label="Name" commit="rnsName" placeholder="Susan" /></div>
        <div><contract-input label="Candidate Address" commit="rnsCandidate" placeholder="0xabcdef123456" /></div>
        <div><contract-input label="Amount to Stake" commit="lockAmount" placeholder="e.g. 120" /></div>
        <div><contract-button action="nameStake">Name Stake</contract-button></div>
        <div><contract-data label="Unlocked Resolves" :value="unlockedResolves" /></div>
        <div><contract-button action="updateNameList">Refresh Names</contract-button></div>
      </div>
      <hr>
      <div id="name-listing"  v-for="n in nameList">
        <name-row class="name-row" :nameID="n.nameID" :currentOwner="n.currentOwner"  :yourCandidate="n.yourCandidate" :yourWeight="n.yourWeight" :name="n.name" :candidateWeight="n.candidateWeight" :leaderWeight="n.leaderWeight" ></name-row>
      </div>
    </control-box>
  </div>
</template>

<script>
  import { mapState } from 'vuex'
  import ControlBox from '@/components/Control-Box'
  import ContractData from '@/components/Contract-Data'
  import ContractInput from '@/components/Contract-Input'
  import ContractButton from '@/components/Contract-Button'
  import NameRow from '@/components/Name-Row'
  
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
      ContractButton,
      NameRow
      /*ContractData*/
    },
    computed:{
      ...mapState([
        "yourCandidate",
        "yourSuggestedMR",
        "masternodeRequirement",
        "communityFund",
        "yourGateway",
        "communityResolve",
        "unlockedResolves",
        "nameList"
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
#rns-box{
  grid-column: 1 / span 2;
}
#name-stake{
  display: grid;
  grid-gap: 10px;
  grid-template-columns: auto auto auto;
}

#name-listing{
  /**/
}

.unstake-button-container{
  position: relative;
}

.unstake-button-container .contract-button{
  transform: translate(0px, 10px);
}
</style>
