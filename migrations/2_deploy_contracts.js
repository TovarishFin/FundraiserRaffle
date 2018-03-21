const FundraiserRaffle = artifacts.require('./FundraiserRaffle.sol')
const RandomNumberGenerator = artifacts.require('./RandomNumberGenerator.sol')

module.exports = async (deployer, network, accounts) => {
  // for now set to 15 minutes from now...
  await deployer.deploy(
    FundraiserRaffle,
    Date.now() / 1000 + 1 * 60 * 10,
    accounts[1]
  )
  const frl = await FundraiserRaffle.deployed()
  await deployer.deploy(RandomNumberGenerator, frl.address)
  const rng = await RandomNumberGenerator.deployed()
  console.log('setting oracle address in frl as owner...')
  await frl.setOracle(rng.address)
}
