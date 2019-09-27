<template>
  <div class="grid-layout">
    <h1>---- Stats ----</h1>
    <button @click="pullInitialStats">Pull Initial Stats</button>
    <br>
    <canvas id="stats-canvas" width="500" height="500"></canvas>
  </div>
</template>

<script>
  import { mapState } from 'vuex'
  import DataService from '@/services/DataService'
  import Chart from 'chart.js'

  export default {
    name: 'stats',
    mounted(){
      let canvas = document.getElementById('stats-canvas') 
      console.log("What is the canvas???")
      console.log(canvas)
      var myLineChart = new Chart(canvas, {
          type: 'line',
          data: {
              labels: ['Red', 'Blue', 'Yellow', 'Green', 'Purple', 'Orange'],
              datasets: [{
                  label: '# of Votes',
                  data: [12, 19, 3, 5, 2, 3],
                  backgroundColor: [
                      'rgba(255, 99, 132, 0.2)',
                      'rgba(54, 162, 235, 0.2)',
                      'rgba(255, 206, 86, 0.2)',
                      'rgba(75, 192, 192, 0.2)',
                      'rgba(153, 102, 255, 0.2)',
                      'rgba(255, 159, 64, 0.2)'
                  ],
                  borderColor: [
                      'rgba(255, 99, 132, 1)',
                      'rgba(54, 162, 235, 1)',
                      'rgba(255, 206, 86, 1)',
                      'rgba(75, 192, 192, 1)',
                      'rgba(153, 102, 255, 1)',
                      'rgba(255, 159, 64, 1)'
                  ],
                  borderWidth: 2
              }]
          },
          options: {
              scales: {
                  yAxes: [{
                      ticks: {
                          beginAtZero: true
                      }
                  }]
              }
          }
      });
      console.log(myLineChart)
    },
    data(){ return {
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
    },
    methods: {
      async pullInitialStats(){
        const response = await DataService.pullInitialStats()
        console.log(response.data)
      }
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
