const SafeMath = artifacts.require('./_testing/zeppelin/math/SafeMath.sol')
const AddressSet = artifacts.require('./_testing/AddressSet/AddressSet.sol')
const StringUtils = artifacts.require('./_testing/ClientRaindrop/StringUtils.sol')

const HydroToken = artifacts.require('./_testing/HydroToken.sol')
const IdentityRegistry = artifacts.require('./_testing/IdentityRegistry.sol')
const Snowflake = artifacts.require('./_testing/Snowflake.sol')
const OldClientRaindrop = artifacts.require('./_testing/ClientRaindrop/OldClientRaindrop.sol')
const ClientRaindrop = artifacts.require('./_testing/ClientRaindrop/ClientRaindrop.sol')

const UniswapVia = artifacts.require('./UniswapVia.sol')
const SnowMoResolver = artifacts.require('./SnowMoResolver.sol')
const DemoHelper = artifacts.require('./DemoHelper.sol')

// link libraries
module.exports = async function(deployer) {
  // await deployer.deploy(SafeMath)
  // await deployer.deploy(AddressSet)
  // await deployer.deploy(StringUtils)
  //
  // deployer.link(SafeMath, HydroToken)
  // deployer.link(SafeMath, Snowflake)
  // deployer.link(AddressSet, IdentityRegistry)
  // deployer.link(StringUtils, OldClientRaindrop)
  // deployer.link(StringUtils, ClientRaindrop)

  await deployer.deploy(UniswapVia, "0xB0D5a36733886a4c5597849a05B315626aF5222E", "0xf5D915570BC477f9B8D6C0E980aA81757A3AaC36")
    .then(uniswapVia => {
      return deployer.deploy(SnowMoResolver, "0xB0D5a36733886a4c5597849a05B315626aF5222E", uniswapVia.address)
        .then(snowMoResolver => {
          return deployer.deploy(DemoHelper, "0xB0D5a36733886a4c5597849a05B315626aF5222E", snowMoResolver.address)
        })
    })
}
