// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@forge-std/Script.sol";
import {MyGovernor, IVotes, TimelockController} from "@main-5_0_2/governer/MyGovernor.sol";

contract DeployGovernerScript is Script {

    address token; // put your address here
    address timelock; // put your address here

    function run() external {
        
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);

        IVotes _token = IVotes(token);
        TimelockController _timelock = TimelockController(payable(timelock));

        MyGovernor governer = new MyGovernor(_token, _timelock);

        vm.stopBroadcast();
    }
}
