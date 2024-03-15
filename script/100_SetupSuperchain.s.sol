// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";


import { IDeployer, getDeployer} from "@script/deployer/DeployScript.sol";

import { AddressManager } from "@main/legacy/AddressManager.sol";
import {DeployAddressManagerScript} from "@script/101_DeployAddressManager.s.sol";


contract SetupSuperchainScript is Script {

    IDeployer deployerProcedue;

    AddressManager addressManager;

    function run() public {

        deployerProcedue = getDeployer();

        DeployAddressManagerScript addressManagerDeployments = new DeployAddressManagerScript();
        addressManagerDeployments.deploy();

        // address addressManager = addressManagerDeployments.deploy();
        // return addressManager;
    }

}


