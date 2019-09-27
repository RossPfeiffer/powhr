export default {
  convertEthToWei(x){return parseInt(x*1e18 )},
  convertWeiToEth(x){return x/ 1e18},
  int(x){return parseInt( x.toString() )}
}
