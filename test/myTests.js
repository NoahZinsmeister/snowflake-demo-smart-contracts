const common = require('./common.js')
const UniswapVia = artifacts.require('./UniswapVia.sol')

let instances
contract('Testing', function (accounts) {
  it('initialized successfully', async () => {
    instances = await common.initialize(accounts[0], accounts, 1000)
  })

  // it('UniswapVia deployed successfully', async () => {
  //   instances.UniswapVia = await UniswapVia.new(instances.Snowflake.address, { from: accounts[0] })
  // })
})
