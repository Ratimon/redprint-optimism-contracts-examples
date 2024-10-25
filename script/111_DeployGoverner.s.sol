// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "@redprint-forge-std/Script.sol";
import {IDeployer, getDeployer} from "@redprint-deploy/deployer/DeployScript.sol";
import {MyGovernor, IVotes, TimelockController} from "@main-5_0_2/governer/MyGovernor.sol";

contract DeployGovernorScript is Script {

    IDeployer deployerProcedue;

    address token; // put your address here
    address timelock; // put your address here

    function run() external {

        deployerProcedue = getDeployer();
        deployerProcedue.setAutoSave(true);
        
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);

        IVotes _token = IVotes(token);
        TimelockController _timelock = TimelockController(payable(timelock));

        MyGovernor governer = new MyGovernor(_token, _timelock);

        vm.stopBroadcast();

        deployerProcedue.save("SystemOwnerSafe", address(governer));
    }
}
