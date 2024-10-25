// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "@redprint-forge-std/Script.sol";
import {DeploySafeProxyScript} from "@script/101_DeploySafeProxyScript.s.sol";
import {DeployGovernorScript} from "@script/111_DeployGoverner.s.sol";
import {SetupSuperchainScript} from "@script/200_SetupSuperchain.s.sol";
import {SetupOpchainScript} from "@script/400_SetupOpchain.s.sol";

contract DeployAllScript is Script {
    function run() public {
        DeploySafeProxyScript safeDeployments = new DeploySafeProxyScript();
        // DeployGovernorScript governorDeployments = new DeployGovernorScript();
        //1) set up Safe Multisig
        safeDeployments.deploy();
        // governorDeployments.run();
        
        SetupSuperchainScript superchainSetups = new SetupSuperchainScript();
        superchainSetups.run();

        SetupOpchainScript opchainSetups = new SetupOpchainScript();
        opchainSetups.run();
    }
}
