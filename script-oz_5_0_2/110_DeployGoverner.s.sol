// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DeployScript, IDeployer} from "@script/deployer/DeployScript.sol";
import {DeployerFunctions} from "@script-5_0_2/deployer/DeployerFunctions.sol";

// import "@openzeppelin-5_0_2/governance/extensions/GovernorVotes.sol";
// import "@openzeppelin-5_0_2/governance/extensions/GovernorTimelockControl.sol";
import {MyGovernor, IVotes, TimelockController} from "@main-5_0_2/governer/MyGovernor.sol";

contract DeployGovernerScript is DeployScript {
    using DeployerFunctions for IDeployer;

    address token; // put your address here
    address timelock; // put your address here

    function deploy() external returns (MyGovernor) {

        IVotes _token = IVotes(token);
        TimelockController _timelock = TimelockController(payable(timelock));

        return MyGovernor(deployer.deploy_Governer("MyGovernor",_token, _timelock ));
    }
}