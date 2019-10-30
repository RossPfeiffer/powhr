<template>
  <div class="name-row">
    <div><contract-data :label="currentOwner" :value="name" /></div>
    <div><contract-data :label="yourCandidate" :value="candidateWeight+' / '+leaderWeight" /></div>
    <div class="unstake-input"><!--<contract-input :label="'Amount to Unstake [ '+yourWeight+' Locked ]'" commit="lockAmount" placeholder="e.g. 120" />-->
      <h6>Amount to Unstake [ {{ yourWeight }} Locked ]</h6>
      <input type="text" placeholder="e.g. 120" @input="updateInput" />
    </div>
    <div class="unstake-button-container" @click="unstake"><contract-button>Unstake</contract-button></div>
  </div>
</template>

<script>
  import ControlBox from '@/components/Control-Box'
  import ContractData from '@/components/Contract-Data'
  import ContractInput from '@/components/Contract-Input'
  import ContractButton from '@/components/Contract-Button'

export default {
  name: 'name-row',
  components: {
    ControlBox,
    ContractData,
    ContractInput,
    ContractButton
  },
  props:{
    name: String,
    nameID: String,
    currentOwner: String,
    yourCandidate: String,
    candidateWeight: String,
    leaderWeight: String,
    yourWeight: String
  },
  data(){return{
    input: 0
  }},
  methods:{
    unstake(){
      console.log("____unstakeName__")
      this.$store.dispatch("unstakeName", { nameID: this.nameID, amount: this.input } )
    },
    updateInput(e){
      let value = e.target.value
      if ( value === '')
        value = '0'
      //console.log("---++++",value)
      this.input = value 
    }
  }
}
</script>

<style scoped>
.control-box{
  display: block;
  border-style:solid;
  border-width: 1px;
  float:left;
  /*
  width:300px;
  height:300px;*/
  box-sizing: content-box;
}
.contract-box{
  margin-top:5px;
  margin-bottom:5px;
}
.slot-wrap{
  padding:20px;
}
.control-box h4{
  font-size:110%;
  text-indent: 20px;
  margin:0;
  padding-top: 10px;
  padding-bottom: 5px;
  background-color: #ededed;
}

.name-row{
  display: grid;
  grid-template-columns: auto auto auto auto;
}
.unstake-input h6{
  margin:0;
  padding:0;
}
</style>
