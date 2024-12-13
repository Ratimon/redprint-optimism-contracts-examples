// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "@redprint-forge-std/Script.sol";
import {DeploySafeProxyScript} from "@scripts/101_DeploySafeProxyScript.s.sol";
import {SetupOpAltDAScript} from "@scripts/300_SetupOpAltDAScript.s.sol";
import {SetupOpchainScript} from "@scripts/400_SetupOpchain.s.sol";
import {SetupSuperchainScript} from "@scripts/200_SetupSuperchain.s.sol";

contract DeployAllScript is Script {
    function run() public {
        DeploySafeProxyScript safeDeployments = new DeploySafeProxyScript();
        //1) set up Safe Multisig
        safeDeployments.deploy();
        SetupSuperchainScript superchainSetups = new SetupSuperchainScript();
        superchainSetups.run();
        SetupOpchainScript opchainSetups = new SetupOpchainScript();
        opchainSetups.run();
        SetupOpAltDAScript opAltDASetups = new SetupOpAltDAScript();
        opAltDASetups.run();
    }
}
