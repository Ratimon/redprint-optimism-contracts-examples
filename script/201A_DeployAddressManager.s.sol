// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console2 as console} from "@redprint-forge-std/console2.sol";

import {DeployScript, IDeployer} from "@redprint-deploy/deployer/DeployScript.sol";
import {DeployerFunctions} from "@redprint-deploy/deployer/DeployerFunctions.sol";

import {AddressManager} from "@redprint-core/legacy/AddressManager.sol";

contract DeployAddressManagerScript is DeployScript {
    using DeployerFunctions for IDeployer;

    function deploy() external returns (AddressManager) {
        return AddressManager(deployer.deploy_AddressManager("AddressManager"));
    }
}
