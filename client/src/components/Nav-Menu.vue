<template>
  <nav>
    <div class="hang-left">
      <h1>PoWHr.io</h1>
    </div>
    <div class="hang-right">
      <router-link to="/">Home</router-link>
      <router-link to="/market">Smart Contract</router-link>
      <!--
      <router-link to="/market">Testnet</router-link>
      <a href="#" target="_blank">Smart Contract</a>-->
      <a href="https://docs.google.com/document/d/1U2WAPDdsgVq4SsFaWhHTjkkn_P-R6ZusDIKyhS5NWhY/edit" target="_blank">Whitepaper</a>
    </div>
  </nav>
</template>

<script>
export default {
  name: 'nav-menu'
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
nav{
  z-index: 500;
  position: fixed;
  top:0;
  left:0;
  background: #333;
  display: block;
  width:100%;
  height:30px;
  line-height:30px;
  
}
h1{
  margin:0;
  color:white;
}
.hang-left{
  float:left;
  padding-left: 10px;
}
.hang-right{
  max-width:300px;
  float:right;
  text-align:right;
}
nav a{
  color:white;
  margin-right:20px;
}
</style>
