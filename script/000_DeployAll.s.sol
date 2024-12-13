// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DeploySafeProxyScript} from "@script/101_DeploySafeProxyScript.s.sol";
import {Script} from "@redprint-forge-std/Script.sol";
import {SetupOpAltDAScript} from "@script/300_SetupOpAltDAScript.s.sol";
import {SetupOpchainScript} from "@script/400_SetupOpchain.s.sol";
import {SetupSuperchainScript} from "@script/200_SetupSuperchain.s.sol";

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
