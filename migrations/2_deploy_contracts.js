const FundraiserRaffle = artifacts.require('./FundraiserRaffle.sol')

module.exports = (deployer, network, accounts) => {
  // for now set to 15 minutes from now...
  deployer.deploy(
    FundraiserRaffle,
    Date.now() / 1000 + 1 * 60 * 15,
    accounts[1]
  )
}
