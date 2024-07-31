// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console2 as console} from "@forge-std/console2.sol";
import {Vm,VmSafe} from "@forge-std/Vm.sol";

import {DeployScript, IDeployer} from "@script/deployer/DeployScript.sol";
import {DeployerFunctions, DeployOptions} from "@script/deployer/DeployerFunctions.sol";

import { Config } from "@script/deployer/Config.sol";

import { SuperchainConfig } from "@main/L1/SuperchainConfig.sol";

contract DeployAndInitializeSuperchainConfig is DeployScript {
    using DeployerFunctions for IDeployer;


    function deploy() external returns (SuperchainConfig) {
        bytes32 _salt = _implSalt();

        DeployOptions memory options = DeployOptions({salt:_salt});

        return (deployer.deploy_SuperchainConfig("SuperchainConfig", options));
    }

    /// @notice The create2 salt used for deployment of the contract implementations.
    ///         Using this helps to reduce config across networks as the implementation
    ///         addresses will be the same across networks when deployed with create2.
    function _implSalt() internal view returns (bytes32) {
        return keccak256(bytes(Config.implSalt()));
    }

}