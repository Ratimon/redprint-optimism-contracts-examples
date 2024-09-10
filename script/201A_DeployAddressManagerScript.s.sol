// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DeployScript} from "@redprint-deploy/deployer/DeployScript.sol";
import {DeployerFunctions, IDeployer} from "@redprint-deploy/deployer/DeployerFunctions.sol";
import {AddressManager} from "@redprint-core/legacy/AddressManager.sol";

/// @custom:security-contact Consult full internal deploy script at https://github.com/Ratimon/redprint-forge
contract DeployAddressManagerScript is DeployScript {
    using DeployerFunctions for IDeployer ;
    function deploy() external returns (AddressManager) {
        return AddressManager(deployer.deploy_AddressManager("AddressManager"));
    }
}
