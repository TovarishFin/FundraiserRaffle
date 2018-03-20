const FundraiserRaffle = artifacts.require('./FundraiserRaffle.sol')
const BigNumber = require('bignumber.js')

module.exports = (deployer, network, accounts) => {
  deployer.deploy(FundraiserRaffle, accounts[2], new BigNumber('10e18'))
}
