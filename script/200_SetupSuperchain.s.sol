// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import { console2 as console } from "@forge-std/console2.sol";

import { IDeployer, getDeployer} from "@script/deployer/DeployScript.sol";

import { AddressManager } from "@main/legacy/AddressManager.sol";

import {DeployAddressManagerScript} from "@script/201_DeployAddressManager.s.sol";
import {DeployProxyAdminScript} from "@script/202_DeployPloxyAdmin.s.sol";


contract SetupSuperchainScript is Script {

    IDeployer deployerProcedue;

    function run() public {

        deployerProcedue = getDeployer();
        deployerProcedue.setAutoSave(true);

        DeployAddressManagerScript addressManagerDeployments = new DeployAddressManagerScript();
        DeployProxyAdminScript proxyAdminDeployments = new DeployProxyAdminScript();
        
        addressManagerDeployments.deploy();
        proxyAdminDeployments.deploy();

        console.log("AddressManager at: ", deployerProcedue.getAddress('AddressManager'));
        console.log("ProxyAdmin at: ", deployerProcedue.getAddress('ProxyAdmin'));

    }

}


