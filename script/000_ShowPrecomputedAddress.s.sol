// SPDX-License-Identifier: MIT
pragma solidity =0.8.15;

import {console} from "@forge-std/console.sol";

import {Script} from "@forge-std/Script.sol";


// import {Deployer} from "@script/Deployer.sol";

contract ShowPrecomputedAddress is Script {
    function getAddress() public pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encode("optimism.deploy")))));
    }

    function run() public view {
        console.logAddress(getAddress());
    }
}