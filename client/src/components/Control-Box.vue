<template>
  <div class="control-box">
    <h4>{{title}}</h4>
    <div class="slot-wrap">
      <slot></slot>
    </div>
  </div>
</template>

<script>

export default {
  name: 'control-box',
  props:{
    title: String
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
</style>
