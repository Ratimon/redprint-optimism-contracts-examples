// SPDX-License-Identifier: MIT
pragma solidity =0.8.15;

import {console} from "@forge-std/console.sol";

import {Script} from "@forge-std/Script.sol";


// import {Deployer} from "@script/Deployer.sol";
import {Vm} from "forge-std/Vm.sol";
import { Deployment, IDeployer, getGlobalDeployer } from "@script/deployer/Deployer.sol";


contract ShowPrecomputedAddress is Script {
    function getAddress() public pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encode("optimism.deploy")))));
    }

    function run() public view {
        console.logAddress(getAddress());

        address addr = address(uint160(uint256(keccak256(abi.encode("optimism.deploy")))));
        // if (addr.code.length > 0) {
        //     return IDeployer(addr);
        // }
        Vm vm = Vm(address(bytes20(uint160(uint256(keccak256("hevm cheat code"))))));
        bytes memory code = vm.getDeployedCode("Deployer.sol:GlobalDeployer");

        console.logBytes(code);

        
    }

    // function getGlobalDeployer() returns (IDeployer) {
    //     //0xD64C5B1F2952CBC28Bd79EB02d3065BbA2696E3A
    //     address addr = address(uint160(uint256(keccak256(abi.encode("optimism.deploy")))));
    //     if (addr.code.length > 0) {
    //         return IDeployer(addr);
    //     }
    //     Vm vm = Vm(address(bytes20(uint160(uint256(keccak256("hevm cheat code"))))));
    //     bytes memory code = vm.getDeployedCode("Deployer.sol:GlobalDeployer");
    //     vm.etch(addr, code);
    //     vm.allowCheatcodes(addr);
    //     GlobalDeployer deployer = GlobalDeployer(addr);
    //     deployer.init();
    //     return deployer;
    // }
}