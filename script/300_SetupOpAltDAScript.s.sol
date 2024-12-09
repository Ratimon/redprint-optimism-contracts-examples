// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "@redprint-forge-std/Script.sol";
import {console} from "@redprint-forge-std/console.sol";
import {IDeployer, getDeployer} from "@redprint-deploy/deployer/DeployScript.sol";
import {DeployDataAvailabilityChallengeProxyScript} from "@script/301A_DeployDataAvailabilityChallengeProxyScript.s.sol";
import {DeployDataAvailabilityChallengeScript} from "@script/301B_DeployDataAvailabilityChallengeScript.s.sol";

contract SetupOpAltDAScript is Script {
    IDeployer deployerProcedue;

    function run() public {
        deployerProcedue = getDeployer();
        deployerProcedue.setAutoSave(true);

        console.log("Setup Op Alt DA ... ");

        DeployDataAvailabilityChallengeProxyScript dataAvailabilityChallengeProxyDeployments = new DeployDataAvailabilityChallengeProxyScript();
        DeployDataAvailabilityChallengeScript dataAvailabilityChallengeDeployments = new DeployDataAvailabilityChallengeScript();

        dataAvailabilityChallengeProxyDeployments.deploy();
        dataAvailabilityChallengeDeployments.deploy();


        console.log("DataAvailabilityChallengeProxy at: ", deployerProcedue.getAddress("DataAvailabilityChallengeProxy"));
        console.log("DataAvailabilityChallenge at: ", deployerProcedue.getAddress("DataAvailabilityChallenge"));

    }
}
