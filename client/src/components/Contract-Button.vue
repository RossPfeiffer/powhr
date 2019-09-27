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
</style>
