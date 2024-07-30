// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console2 as console} from "@forge-std/console2.sol";
import {VmSafe} from "@forge-std/Vm.sol";

import {DeployScript, IDeployer} from "@script/deployer/DeployScript.sol";
import {DeployerFunctions} from "@script/deployer/DeployerFunctions.sol";

import {Proxy} from "@main/universal/ProxyAdmin.sol";
import { SuperchainConfig } from "@main/L1/SuperchainConfig.sol";

contract DeploySuperchainConfigProxyScript is DeployScript {
    using DeployerFunctions for IDeployer;

    address proxyOwner;

    function deploy() external returns (Proxy) {
        string memory mnemonic = vm.envString("MNEMONIC");
        uint256 ownerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
        proxyOwner = vm.envOr("DEPLOYER", vm.addr(ownerPrivateKey));

        return Proxy(deployer.deploy_ERC1967Proxy("SuperchainConfigProxy", address(proxyOwner)));
    }
}