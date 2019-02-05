pragma solidity ^0.5.0;

import "./interfaces/HydroInterface.sol";
import "./interfaces/SnowflakeInterface.sol";
import "./interfaces/IdentityRegistryInterface.sol";

contract HydroRinkeby {
    function getMoreTokens() external;
}

contract DemoHelper {
    address public snowflakeAddress;
    SnowflakeInterface private snowflake;
    IdentityRegistryInterface private identityRegistry;
    address public snowMoResolverAddress;

    constructor (address _snowflakeAddress, address _resolverAddress) public {
        snowflakeAddress = _snowflakeAddress;
        snowflake = SnowflakeInterface(snowflakeAddress);
        identityRegistry = IdentityRegistryInterface(snowflake.identityRegistryAddress());
        snowMoResolverAddress = _resolverAddress;
    }

    // wrap createIdentityDelegated and initialize the client raindrop resolver
    function createIdentityDelegated(
        address associatedAddress, address tokensReceivedAddress,
        uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) public returns (uint ein) {
        // create 1484 identity
        address[] memory _providers = new address[](2);
        _providers[0] = snowflakeAddress;
        _providers[1] = address(this);

        uint _ein = identityRegistry.createIdentityDelegated(
            associatedAddress, associatedAddress, _providers, new address[](0), v, r, s, timestamp
        );

        // add snowmo resolver
        snowflake.addResolverAsProvider(
            _ein, snowMoResolverAddress, true, 0, abi.encode(associatedAddress, tokensReceivedAddress)
        );

        // get free testnet tokens
        HydroRinkeby(snowflake.hydroTokenAddress()).getMoreTokens();

        // deposit new tokens into snowflake
        HydroInterface(snowflake.hydroTokenAddress())
            .approveAndCall(snowflakeAddress, 10000000000000000000000, abi.encode(_ein));

        return _ein;
    }
}
