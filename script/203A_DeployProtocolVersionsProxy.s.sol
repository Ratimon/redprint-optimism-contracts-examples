// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console2 as console} from "@redprint-forge-std/console2.sol";
import {VmSafe} from "@redprint-forge-std/Vm.sol";

import {DeployScript, IDeployer} from "@redprint-deploy/deployer/DeployScript.sol";
import {DeployerFunctions} from "@redprint-deploy/deployer/DeployerFunctions.sol";

import {Proxy} from "@redprint-core/universal/Proxy.sol";

contract DeployProtocolVersionsProxyScript is DeployScript {
    using DeployerFunctions for IDeployer;

    function deploy() external returns (Proxy) {
        address proxyOwner = deployer.mustGetAddress("ProxyAdmin");

        return Proxy(deployer.deploy_ERC1967Proxy("ProtocolVersionsProxy", address(proxyOwner)));
    }
}