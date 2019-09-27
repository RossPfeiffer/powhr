<template>
  <div class="contract-input contract-box">
    <img v-if="img" :src="img"/>
    <div class="right">
      <h6>{{label}}</h6>
      <input type="text" :placeholder="placeholder" :value="val" @input="updateState" />
    </div>
  </div>
</template>

<script>

export default {
  created(){
  },
  name: 'contract-input',
  /*data(){return{
    onChange:function(){console.log('asldkjf')}
  }},*/
  props:[
    'label',
    'placeholder',
    'img',
    'commit',
    'onChange'
  ],
  computed:{
    val(){
      let state = this.$store.state[this.commit];
      if(state === 0)
        return ""
      else
        return state
    }
  },
  methods:{
    updateState(e){
      let value = e.target.value
      if ( value === '')
        value = 0
      this.$store.commit("update_"+this.commit, value)
      if (this.onChange)
        this.onChange()
    }
  }
}

</script>

<style scoped>
.contract-data > img{
  max-width:32px;
}
h6{
  margin:0;
  padding:0;
}
</style>
