<template>
  <div class="contract-button contract-box">
    <button @click="dispatch"><slot></slot></button>
  </div>
</template>

<script>

export default {
  name: 'contract-button',
  props:{
    action: String
  },
  methods:{
    dispatch(){
      this.$store.dispatch(this.action)
    }
  }
}
</script>

<style scoped>

button{
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
</style>
