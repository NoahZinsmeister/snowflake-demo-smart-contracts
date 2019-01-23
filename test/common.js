const HydroToken = artifacts.require('./_testing/HydroToken.sol')
const IdentityRegistry = artifacts.require('./_testing/IdentityRegistry.sol')
const Snowflake = artifacts.require('./_testing/Snowflake.sol')
const OldClientRaindrop = artifacts.require('./_testing/ClientRaindrop/OldClientRaindrop.sol')
const ClientRaindrop = artifacts.require('./_testing/ClientRaindrop/ClientRaindrop.sol')

async function initialize (owner, hydroTokenHolders, amount) {
  const instances = {}

  instances.HydroToken = await HydroToken.new({ from: owner })
  for (let hydroTokenHolder of hydroTokenHolders) {
    await instances.HydroToken.transfer(
      hydroTokenHolder,
      web3.utils.toBN(amount).mul(web3.utils.toBN(1e18)),
      { from: owner }
    )
  }

  instances.IdentityRegistry = await IdentityRegistry.new({ from: owner })

  instances.Snowflake = await Snowflake.new(
    instances.IdentityRegistry.address, instances.HydroToken.address, { from: owner }
  )

  instances.OldClientRaindrop = await OldClientRaindrop.new({ from: owner })

  instances.ClientRaindrop = await ClientRaindrop.new(
    instances.Snowflake.address, instances.OldClientRaindrop.address, 0, 0, { from: owner }
  )
  await instances.Snowflake.setClientRaindropAddress(instances.ClientRaindrop.address, { from: owner })

  return instances
}

module.exports = {
  initialize: initialize
}
