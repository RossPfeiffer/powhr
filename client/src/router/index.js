import Vue from 'vue'
import Router from 'vue-router'
import Home from '@/components/Home'
import Contract from '@/components/Contract'
import FundRaiser from '@/components/FundRaiser'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'Home',
      component: Home
    },
    {
      path: '/contract/:masternode',
      name: 'Contract',
      component: Contract
    },
    {
      path: '/contract',
      name: 'Contract',
      component: Contract
    }/*,
    {
      path: '/fundraiser',
      name: 'FundRaiser',
      component: FundRaiser
    }*/
  ]
})
