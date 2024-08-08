// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console2 as console} from "@forge-std/console2.sol";
import {VmSafe} from "@forge-std/Vm.sol";

import {DeployScript, IDeployer} from "@script/deployer/DeployScript.sol";
import {DeployerFunctions} from "@script/deployer/DeployerFunctions.sol";

import {Proxy} from "@main/universal/ProxyAdmin.sol";

contract DeploySuperchainConfigProxyScript is DeployScript {
    using DeployerFunctions for IDeployer;

    function deploy() external returns (Proxy) {

        address proxyOwner = deployer.mustGetAddress("ProxyAdmin");

        return Proxy(deployer.deploy_ERC1967Proxy("SuperchainConfigProxy", address(proxyOwner)));
    }
}