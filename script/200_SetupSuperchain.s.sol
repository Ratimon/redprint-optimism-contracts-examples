// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import { console2 as console } from "@forge-std/console2.sol";

import { IDeployer, getDeployer} from "@script/deployer/DeployScript.sol";

import { AddressManager } from "@main/legacy/AddressManager.sol";

import {DeploySafeScript} from "@script/100_DeploySafe.s.sol";
import {DeployAddressManagerScript} from "@script/201_DeployAddressManager.s.sol";


contract SetupSuperchainScript is Script {

    IDeployer deployerProcedue;

    AddressManager addressManager;

    function run() public {

        deployerProcedue = getDeployer();
        deployerProcedue.setAutoSave(true);

        DeploySafeScript safeDeployments = new DeploySafeScript();
        DeployAddressManagerScript addressManagerDeployments = new DeployAddressManagerScript();

        safeDeployments.deploy();
        addressManagerDeployments.deploy();
        console.log("SystemOwnerSafe at: ", deployerProcedue.getAddress('SystemOwnerSafe'));

        // address addressManager = addressManagerDeployments.deploy();
        // return addressManager;

        
    }

}


