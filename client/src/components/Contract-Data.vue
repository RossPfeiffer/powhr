<template>
  <div class="contract-data contract-box">
    <img v-if="img" :src="img"/>
    <div class="right">
      <h6>{{label}}</h6>
      <span>{{value}}</span>
    </div>
  </div>
</template>

<script>
  export default {
    name: 'contract-data',
    props:{
      label: String,
      value: String,
      img: String
    }
  }
</script>

<style scoped>
.contract-data{
  display: block;
}
.contract-data > img{
  max-width:32px;
  display: inline-block;
}
.contract-data .right{
  display: inline-block;
}
.contract-data .right:after{
  clear:both;
}
h6{
  margin:0;
}
</style>
