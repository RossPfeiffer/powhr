<template>
  <div class="grid-layout">
    <h1>---- DAO ----</h1>
  </div>
</template>

<script>
  import { mapState } from 'vuex'
  //import ControlBox from '@/components/Control-Box'
  
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
      /*ControlBox,
      ContractData*/
    },
    computed:{
      ...mapState([
        /*"totalBondSupply",
        "totalStakedResolves",
        "ethInReserve"*/
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
</style>
