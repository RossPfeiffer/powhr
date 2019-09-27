<template>
  <div class="masker" v-if="walletUnlocked || !walletUnlocked" >
    <slot></slot>
  </div>
</template>

<script>
import { mapState } from 'vuex'

export default {
  name: 'metamask-gateway',
  computed: mapState([
    'walletUnlocked'
  ])
}
</script>

<style scoped>

</style>
