// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OwnableUpgradeable} from "@redprint-openzeppelin-upgradeable/access/OwnableUpgradeable.sol";
import {WETH98} from "@redprint-core/universal/WETH98.sol";
import {ISemver} from "@redprint-core/universal/interfaces/ISemver.sol";
import {ISuperchainConfig} from "@redprint-core/L1/interfaces/ISuperchainConfig.sol";

/// @custom:security-contact Consult full code athttps://github.com/ethereum-optimism/optimism/blob/v1.9.4/packages/contracts-bedrock/src/dispute/DelayedWETH.sol
contract DelayedWETH is OwnableUpgradeable, WETH98, ISemver {
    /// @notice Represents a withdrawal request.
    struct WithdrawalRequest {
        uint256 amount;
        uint256 timestamp;
    }
    /// @notice Emitted when an unwrap is started.
    /// @param src The address that started the unwrap.
    /// @param wad The amount of WETH that was unwrapped.
    event Unwrap(address indexed src, uint256 wad);
    /// @notice Semantic version.
    /// @custom:semver 1.2.0-beta.2
    string public constant version = "1.2.0-beta.2";
    /// @notice Returns a withdrawal request for the given address.
    mapping(address => mapping(address => WithdrawalRequest)) public withdrawals;
    /// @notice Withdrawal delay in seconds.
    uint256 internal immutable DELAY_SECONDS;
    /// @notice Address of the SuperchainConfig contract.
    ISuperchainConfig public config;

    constructor(uint256 _delay) {
        DELAY_SECONDS = _delay;
        initialize({ _owner: address(0), _config: ISuperchainConfig(address(0)) });
    }

    function initialize(address _owner, ISuperchainConfig _config)
        public
        initializer
    {
        __Ownable_init();
        _transferOwnership(_owner);
        config = _config;
    }

    function delay() external view returns (uint256) {
        return DELAY_SECONDS;
    }

    function unlock(address _guy, uint256 _wad) external {
        // Note that the unlock function can be called by any address, but the actual unlocking capability still only
        // gives the msg.sender the ability to withdraw from the account. As long as the unlock and withdraw functions
        // are called with the proper recipient addresses, this will be safe. Could be made safer by having external
        // accounts execute withdrawals themselves but that would have added extra complexity and made DelayedWETH a
        // leaky abstraction, so we chose this instead.
        WithdrawalRequest storage wd = withdrawals[msg.sender][_guy];
        wd.timestamp = block.timestamp;
        wd.amount += _wad;
    }

    function withdraw(uint256 _wad) public override {
        withdraw(msg.sender, _wad);
    }

    function withdraw(address _guy, uint256 _wad) public {
        require(!config.paused(), "DelayedWETH: contract is paused");
        WithdrawalRequest storage wd = withdrawals[msg.sender][_guy];
        require(wd.amount >= _wad, "DelayedWETH: insufficient unlocked withdrawal");
        require(wd.timestamp > 0, "DelayedWETH: withdrawal not unlocked");
        require(wd.timestamp + DELAY_SECONDS <= block.timestamp, "DelayedWETH: withdrawal delay not met");
        wd.amount -= _wad;
        super.withdraw(_wad);
    }

    function recover(uint256 _wad) external {
        require(msg.sender == owner(), "DelayedWETH: not owner");
        uint256 amount = _wad < address(this).balance ? _wad : address(this).balance;
        (bool success,) = payable(msg.sender).call{ value: amount }(hex"");
        require(success, "DelayedWETH: recover failed");
    }

    function hold(address _guy, uint256 _wad) external {
        require(msg.sender == owner(), "DelayedWETH: not owner");
        allowance[_guy][msg.sender] = _wad;
        emit Approval(_guy, msg.sender, _wad);
    }
}
