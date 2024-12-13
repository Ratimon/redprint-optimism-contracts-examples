// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ISemver} from "@redprint-core/universal/interfaces/ISemver.sol";
import {Initializable} from "@redprint-openzeppelin/proxy/utils/Initializable.sol";
import {Storage} from "@redprint-core/libraries/Storage.sol";

/// @custom:security-contact Consult full code at https://github.com/ethereum-optimism/optimism/blob/v1.9.4/packages/contracts-bedrock/src/L1/SuperchainConfig.sol
contract SuperchainConfig is Initializable, ISemver {
    /// @notice Enum representing different types of updates.
    /// @custom:value GUARDIAN            Represents an update to the guardian.
    enum UpdateType {
        GUARDIAN
    }
    /// @notice Whether or not the Superchain is paused.
    bytes32 public constant PAUSED_SLOT = bytes32(uint256(keccak256("superchainConfig.paused")) - 1);
    /// @notice The address of the guardian, which can pause withdrawals from the System.
    ///         It can only be modified by an upgrade.
    bytes32 public constant GUARDIAN_SLOT = bytes32(uint256(keccak256("superchainConfig.guardian")) - 1);
    /// @notice Emitted when the pause is triggered.
    /// @param identifier A string helping to identify provenance of the pause transaction.
    event Paused(string identifier);
    /// @notice Emitted when the pause is lifted.
    event Unpaused();
    event ConfigUpdate(UpdateType indexed updateType, bytes data);
    /// @notice Semantic version.
    /// @custom:semver 1.1.1-beta.1
    string public constant version = "1.1.1-beta.1";

    constructor() {
        initialize({ _guardian: address(0), _paused: false });
    }

    function initialize(address _guardian, bool _paused) public initializer {
        _setGuardian(_guardian);
        if (_paused) {
            _pause("Initializer paused");
        }
    }

    function guardian() public view returns (address guardian_) {
        guardian_ = Storage.getAddress(GUARDIAN_SLOT);
    }

    function paused() public view returns (bool paused_) {
        paused_ = Storage.getBool(PAUSED_SLOT);
    }

    function pause(string memory _identifier) external {
        require(msg.sender == guardian(), "SuperchainConfig: only guardian can pause");
        _pause(_identifier);
    }

    function _pause(string memory _identifier) internal returns (address) {
        Storage.setBool(PAUSED_SLOT, true);
        emit Paused(_identifier);
    }

    function unpause() external {
        require(msg.sender == guardian(), "SuperchainConfig: only guardian can unpause");
        Storage.setBool(PAUSED_SLOT, false);
        emit Unpaused();
    }

    function _setGuardian(address _guardian) internal {
        Storage.setAddress(GUARDIAN_SLOT, _guardian);
        emit ConfigUpdate(UpdateType.GUARDIAN, abi.encode(_guardian));
    }
}
