// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "@forge-std/Script.sol";
import {Upgrades} from "@openzeppelin-foundry-upgrades/Upgrades.sol";
import {MyGoverner3Upgradable, IVotes, TimelockControllerUpgradeable} from "@main-5_0_2/governer/MyGoverner3Upgradable.sol";


contract DeployGovernerScript is Script {

    address token; // put your address here
    address payable timelock ; // put your address here

    function run() external {

        vm.startBroadcast();

        IVotes _token = IVotes(token);
        TimelockControllerUpgradeable _timelock = TimelockControllerUpgradeable(payable(timelock));

        address proxy = Upgrades.deployUUPSProxy("MyGoverner3Upgradable.sol", abi.encodeCall(MyGoverner3Upgradable.initialize, ( _token, _timelock)));
        // address proxy2 = Upgrades.deployUUPSProxy("MyGovernor.sol", abi.encodeCall(MyGovernor.initialize, ( _token, _timelock)));

        vm.stopBroadcast();

    }

}