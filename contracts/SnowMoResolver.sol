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
    function sendTo(uint einFrom, uint einTo, uint amount, string memory message) public {
        require(identityRegistry.isProviderFor(einFrom, msg.sender), "");
        address tokenPreference = tokenPreferences[einTo];
        if (tokenPreference == address(0)) {
            transferSnowflakeBalanceFrom(einFrom, einTo, amount, message);
        } else {
            require(tokenReceiptAddresses[einTo] != address(0), "");
            withdrawSnowflakeBalanceFromVia(
                einFrom, tokenReceiptAddresses[einTo], amount, tokenPreferences[einTo], message
            );
        }
    }

    // force transfer
    function forceTransferTo(uint einFrom, uint einTo, uint amount, string memory message) public {
        require(identityRegistry.isProviderFor(einFrom, msg.sender), "");
        transferSnowflakeBalanceFrom(einFrom, einTo, amount, message);
    }

    // force withdraw
    function forceWithdrawTo(uint einFrom, uint einTo, uint amount, string memory message) public {
        require(identityRegistry.isProviderFor(einFrom, msg.sender), "");
        require(tokenReceiptAddresses[einTo] != address(0), "");
        withdrawSnowflakeBalanceFrom(einFrom, tokenReceiptAddresses[einTo], amount, message);
    }

    // force withdraw
    function forceWithdrawTo(uint einFrom, address to, uint amount, string memory message) public {
        require(identityRegistry.isProviderFor(einFrom, msg.sender), "");
        withdrawSnowflakeBalanceFrom(einFrom, to, amount, message);
    }

    // force withdraw via
    function forceWithdrawToVia(uint einFrom, uint einTo, uint amount, string memory message) public {
        require(identityRegistry.isProviderFor(einFrom, msg.sender), "");
        require(tokenReceiptAddresses[einTo] != address(0), "");
        require(tokenPreferences[einTo] != address(0), "");
        withdrawSnowflakeBalanceFromVia(
            einFrom, tokenReceiptAddresses[einTo], amount, tokenPreferences[einTo], message
        );
    }

    // force withdraw via
    function forceWithdrawToVia(uint einFrom, uint einTo, uint amount, address tokenPreference, string memory message)
        public
    {
        require(identityRegistry.isProviderFor(einFrom, msg.sender), "");
        require(tokenReceiptAddresses[einTo] != address(0), "");

        withdrawSnowflakeBalanceFromVia(einFrom, tokenReceiptAddresses[einTo], amount, tokenPreference, message);
    }

    // force withdraw via
    function forceWithdrawToVia(uint einFrom, address to, uint amount, address tokenPreference, string memory message)
        public
    {
        require(identityRegistry.isProviderFor(einFrom, msg.sender), "");
        withdrawSnowflakeBalanceFromVia(einFrom, to, amount, tokenPreference, message);
    }

    // wrapper to emit events
    function transferSnowflakeBalanceFrom(uint einFrom, uint einTo, uint amount, string memory message) private {
        snowflake.transferSnowflakeBalanceFrom(einFrom, einTo, amount);
        emit TransferFrom(einFrom, einTo, amount, message);
    }

    // wrapper to emit events
    function withdrawSnowflakeBalanceFrom(uint einFrom, address to, uint amount, string memory message) private {
        snowflake.withdrawSnowflakeBalanceFrom(einFrom, to, amount);
        emit WithdrawFrom(einFrom, to, amount, message);
    }

    // wrapper to emit events
    function withdrawSnowflakeBalanceFromVia(
        uint einFrom, address to, uint amount, address tokenAddress, string memory message
    ) private {
        withdrawSnowflakeBalanceFromVia(
            einFrom, to, amount, tokenAddress, 1, 1, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff,
            message
        );
    }

    function withdrawSnowflakeBalanceFromVia(
        uint einFrom, address to, uint amount,
        address tokenAddress, uint minTokensBought, uint minEthBought, uint deadline, string memory message
    ) private {
        bytes memory snowflakeCallBytes = abi.encode(tokenAddress, minTokensBought, minEthBought, deadline);
        snowflake.withdrawSnowflakeBalanceFromVia(einFrom, uniswapViaAddress, to, amount, snowflakeCallBytes);
        emit WithdrawFromVia(einFrom, to, uniswapViaAddress, amount, message, snowflakeCallBytes);
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

    function changeTokenPreference(uint ein, address newTokenPreference) public
    {
        require(identityRegistry.isProviderFor(ein, msg.sender), "");
        tokenPreferences[ein] = newTokenPreference;
    }

    function onRemoval(uint /* ein */, bytes memory /* extraData */) public senderIsSnowflake() returns (bool) {
        return true;
    }

    event SnowMoSignup(uint indexed ein);
    event TransferFrom(uint indexed einFrom, uint indexed einTo, uint amount, string message);
    event WithdrawFrom(uint indexed einFrom, address indexed to, uint amount, string message);
    event WithdrawFromVia(
        uint indexed einFrom, address indexed to, address via, uint amount, string message, bytes snowflakeCallBytes
    );
}
