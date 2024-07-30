// SPDX-License-Identifier: MIT
pragma solidity =0.8.15;

import {console} from "@forge-std/console.sol";

import {Script} from "@forge-std/Script.sol";

import { Config } from "@script/deployer/Config.sol";
import { ForgeArtifacts } from "@script/deployer/ForgeArtifacts.sol";

import {Vm} from "forge-std/Vm.sol";
import { Deployment, IDeployer, getDeployer } from "@script/deployer/Deployer.sol";

contract ShowPrecomputedAddress is Script {

    string internal deploymentOutfile;

    function getAddress() public pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encode("optimism.deploy")))));
    }

    function run() public view {
        console.logAddress(getAddress());

        address addr = address(uint160(uint256(keccak256(abi.encode("optimism.deploy")))));
        Vm vm = Vm(address(bytes20(uint160(uint256(keccak256("hevm cheat code"))))));
        bytes memory code = vm.getDeployedCode("Deployer.sol:GlobalDeployer");

        console.logBytes(code);
        
    }
}