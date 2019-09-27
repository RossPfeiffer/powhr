import Vue from 'vue'
import Router from 'vue-router'
import Home from '@/components/Home'
import Market from '@/components/Market'
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
      path: '/market',
      name: 'Market',
      component: Market
    }/*,
    {
      path: '/fundraiser',
      name: 'FundRaiser',
      component: FundRaiser
    }*/
  ]
})
