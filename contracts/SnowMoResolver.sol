pragma solidity ^0.5.0;

import "./SnowflakeResolver.sol";
import "./interfaces/SnowflakeInterface.sol";
import "./interfaces/IdentityRegistryInterface.sol";

contract SnowMoResolver is SnowflakeResolver {
    address public uniswapViaAddress;
    SnowflakeInterface private snowflake;
    IdentityRegistryInterface private identityRegistry;

    mapping (uint => address) public tokenReceiptAddresses;
    mapping (uint => address) public tokenPreferences;

    constructor (address snowflakeAddress, address _uniswapViaAddress)
        SnowflakeResolver(
            "SnowMo", "Decentralized meta-transaction payment protocol fueled by HYDRO.", snowflakeAddress, true, false
        )
        public
    {
        setSnowflakeAddress(snowflakeAddress);
        uniswapViaAddress = _uniswapViaAddress;
    
    }

    function setSnowflakeAddress(address snowflakeAddress) public onlyOwner() {
        super.setSnowflakeAddress(snowflakeAddress);

        snowflake = SnowflakeInterface(snowflakeAddress);
        identityRegistry = IdentityRegistryInterface(snowflake.identityRegistryAddress());
    }

    // preference-based send
    function sendTo(uint einFrom, uint einTo, uint amount) public {
        require(identityRegistry.isProviderFor(einFrom, msg.sender), "");
        address tokenPreference = tokenPreferences[einTo];
        if (tokenPreference == address(0)) {
            snowflake.transferSnowflakeBalanceFrom(einFrom, einTo, amount);
        } else {
            require(tokenReceiptAddresses[einTo] != address(0), "");
            snowflake.withdrawSnowflakeBalanceFromVia(
                einFrom, uniswapViaAddress, tokenReceiptAddresses[einTo], amount, abi.encode(tokenPreferences[einTo])
            );
        }
    }

    // force transfer
    function forceTransferTo(uint einFrom, uint einTo, uint amount) public {
        require(identityRegistry.isProviderFor(einFrom, msg.sender), "");
        snowflake.transferSnowflakeBalanceFrom(einFrom, einTo, amount);
    }

    // force withdraw
    function forceWithdrawTo(uint einFrom, uint einTo, uint amount) public {
        require(identityRegistry.isProviderFor(einFrom, msg.sender), "");
        require(tokenReceiptAddresses[einTo] != address(0), "");
        snowflake.withdrawSnowflakeBalanceFrom(einFrom, tokenReceiptAddresses[einTo], amount);
    }

    // force withdraw
    function forceWithdrawTo(uint einFrom, address to, uint amount) public {
        require(identityRegistry.isProviderFor(einFrom, msg.sender), "");
        snowflake.withdrawSnowflakeBalanceFrom(einFrom, to, amount);
    }

    // force withdraw via
    function forceWithdrawToVia(uint einFrom, uint einTo, uint amount) public {
        require(identityRegistry.isProviderFor(einFrom, msg.sender), "");
        require(tokenReceiptAddresses[einTo] != address(0), "");
        require(tokenPreferences[einTo] != address(0), "");
        snowflake.withdrawSnowflakeBalanceFromVia(
            einFrom, uniswapViaAddress, tokenReceiptAddresses[einTo], amount, abi.encode(tokenPreferences[einTo])
        );
    }

    // force withdraw via
    function forceWithdrawToVia(uint einFrom, uint einTo, uint amount, address tokenPreference) public {
        require(identityRegistry.isProviderFor(einFrom, msg.sender), "");
        require(tokenReceiptAddresses[einTo] != address(0), "");
        snowflake.withdrawSnowflakeBalanceFromVia(
            einFrom, uniswapViaAddress, tokenReceiptAddresses[einTo], amount, abi.encode(tokenPreference)
        );
    }

    // force withdraw via
    function forceWithdrawToVia(uint einFrom, address to, uint amount, address tokenPreference) public {
        require(identityRegistry.isProviderFor(einFrom, msg.sender), "");
        snowflake.withdrawSnowflakeBalanceFromVia(
            einFrom, uniswapViaAddress, to, amount, abi.encode(tokenPreference)
        );
    }

    function onAddition(uint ein, uint /* allowance */, bytes memory extraData)
        public senderIsSnowflake() returns (bool)
    {
        (address tokenReceiptAddress, address tokenPreferenceAddress) = abi.decode(extraData, (address, address));
        tokenReceiptAddresses[ein] = tokenReceiptAddress;
        if (tokenPreferenceAddress != address(0)) {
            tokenPreferences[ein] = tokenPreferenceAddress;
        }

        emit SnowMoSignup(ein);

        return true;
    }

    function onRemoval(uint /* ein */, bytes memory /* extraData */) public senderIsSnowflake() returns (bool) {
        return true;
    }

    event SnowMoSignup(uint indexed ein);
}
