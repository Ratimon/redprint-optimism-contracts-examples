// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DeployScript, IDeployer} from "@redprint-deploy/deployer/DeployScript.sol";
import {DeployerFunctions, DeployOptions} from "@redprint-deploy/deployer/DeployerFunctions.sol";
import {DeployConfig} from "@redprint-deploy/deployer/DeployConfig.s.sol";

import {DataAvailabilityChallenge} from "@redprint-core/L1/DataAvailabilityChallenge.sol";

/// @custom:security-contact Consult full internal deploy script at https://github.com/Ratimon/redprint-forge
contract DeployDataAvailabilityChallengeScript is DeployScript {
    using DeployerFunctions for IDeployer ;
    function deploy() external returns (DataAvailabilityChallenge) {

        bytes32 _salt = DeployScript.implSalt();
        DeployOptions memory options = DeployOptions({salt:_salt});

        return DataAvailabilityChallenge(deployer.deploy_DataAvailabilityChallenge("DataAvailabilityChallenge", options));
    }
}
