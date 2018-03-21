const FundraiserRaffle = artifacts.require('FundRaiserRaffle')
const assert = require('assert')
const BigNumber = require('bignumber.js')
const { addressZero } = require('./utils/general')

describe('when deploying FundraiserRaffle', () => {
  contract('FundraiserRaffle', accounts => {
    const owner = accounts[0]
    const fundraiser = accounts[1]
    const endDate = new BigNumber(Date.now())
      .div(1000)
      .add(5)
      .floor()
    let frl

    before('setup contracts', async () => {
      frl = await FundraiserRaffle.new(endDate, fundraiser)
    })

    it('should start with correct values', async () => {
      const actualOwner = await frl.owner()
      const fundraisedAmount = await frl.fundraisedAmount()
      const winnableAmount = await frl.winnableAmount()
      const winner = await frl.winner()
      const actualEndDate = await frl.endDate()
      const fundraiserAddress = await frl.fundraiserAddress()
      const randNumGen = await frl.randNumGen()
      const stage = await frl.stage()

      assert.equal(actualOwner, owner, 'owner should matched expected value')
      assert.equal(
        fundraisedAmount.toString(),
        new BigNumber(0).toString(),
        'fundraised amount start as 0'
      )
      assert.equal(
        winnableAmount.toString(),
        new BigNumber(0),
        'winnable amount should start as 0'
      )
      assert.equal(
        winner.toString(),
        new BigNumber(0).toString(),
        'winner should start as 0'
      )
      assert.equal(
        endDate.toString(),
        actualEndDate.toString(),
        'end date should match value set in constructor'
      )
      assert.equal(
        fundraiserAddress,
        fundraiser,
        'fundraiser should match value set in constructor'
      )
      assert.equal(
        randNumGen,
        addressZero,
        'randNumGen address should be uninitialized'
      )
      assert.equal(
        stage.toString(),
        new BigNumber(0).toString(),
        'stage should start at 0 (PreStart)'
      )
    })
  })
})
