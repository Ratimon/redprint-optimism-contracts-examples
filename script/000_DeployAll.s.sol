// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "@redprint-forge-std/Script.sol";
import {console2 as console} from "@redprint-forge-std/console2.sol";

import {IDeployer, getDeployer} from "@redprint-deploy/deployer/DeployScript.sol";
import {DeploySafeProxyScript} from "@script/101_DeploySafeProxyScript.s.sol";
import {SetupSuperchainScript} from "@script/200_SetupSuperchain.s.sol";
import {SetupOpchainScript} from "@script/400_SetupOpchain.s.sol";

contract DeployAllScript is Script {
    IDeployer deployerProcedue;

    function run() public {
        deployerProcedue = getDeployer();
        deployerProcedue.setAutoSave(true);

        // DeploySafeProxy
        DeploySafeProxyScript safeDeployments = new DeploySafeProxyScript();
        SetupSuperchainScript superchainSetups = new SetupSuperchainScript();

        //1) set up Safe Multisig
        safeDeployments.deploy();
        //2) set up superChain
        superchainSetups.run();
        //3) TODO set up plasma
        
        //4) set up layer2 OP Chain
        SetupOpchainScript opchainSetups = new SetupOpchainScript();
    }
}
