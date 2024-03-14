// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import "@forge-std/Script.sol";
import {Testtoken} from "@main/Testtoken.sol";


import {DeployScript, Deployer} from "forge-deploy/DeployScript.sol";
import {DeployerFunctions} from "@generated/deployer/DeployerFunctions.g.sol";

// import {DeployScript, IDeployer} from "@script/deployer/DeployScript.sol";
// import {DeployerFunctions} from "@script/deployer/DeployerFunctions.sol";

// import {ProxyAdmin} from "@main/universal/ProxyAdmin.sol";

contract TesttokenScript is DeployScript {
    using DeployerFunctions for Deployer;
    // function run() external {
    //     string memory mnemonic = vm.envString("MNEMONIC");
    //     uint256 ownerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
    //     vm.startBroadcast(ownerPrivateKey);

    //     Testtoken token = new Testtoken();

    //     vm.stopBroadcast();
    // }

    function deploy() external returns (Testtoken) {
        // string memory mnemonic = vm.envString("MNEMONIC");
        // uint256 ownerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
        // owner = vm.envOr("DEPLOYER", vm.addr(ownerPrivateKey));

        // console.log('ownerPrivateKey', ownerPrivateKey);

        return Testtoken(deployer.deploy_Testtoken("Testtoken"));

    }
}