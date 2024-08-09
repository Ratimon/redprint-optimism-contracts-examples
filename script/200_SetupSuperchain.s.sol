// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console2 as console} from "@forge-std/console2.sol";

import {IDeployer, getDeployer} from "@script/deployer/DeployScript.sol";

import {DeployAddressManagerScript} from "@script/201A_DeployAddressManager.s.sol";
import {DeployAndSetupProxyAdminScript} from "@script/201B_DeployAndSetupProxyAdmin.s.sol";
import {DeploySuperchainConfigProxyScript} from "@script/202A_DeploySuperchainConfigProxy.s.sol";
import {DeployAndInitializeSuperchainConfig} from "@script/202B_DeployAndInitializeSuperchainConfig.s.sol";
import {DeployProtocolVersionsProxyScript} from "@script/203A_DeployProtocolVersionsProxy.s.sol";
import {DeployAndInitializeProtocolVersionsScript} from "@script/203B_DeployAndInitializeProtocolVersions.s.sol";


import {AddressManager} from "@main/legacy/AddressManager.sol";

contract SetupSuperchainScript is Script {
    IDeployer deployerProcedue;

    function run() public {
        deployerProcedue = getDeployer();
        deployerProcedue.setAutoSave(true);

        DeployAddressManagerScript addressManagerDeployments = new DeployAddressManagerScript();
        DeployAndSetupProxyAdminScript proxyAdminDeployments = new DeployAndSetupProxyAdminScript();

        DeploySuperchainConfigProxyScript superchainConfigProxyDeployments = new DeploySuperchainConfigProxyScript();
        DeployAndInitializeSuperchainConfig superchainConfigDeployments = new DeployAndInitializeSuperchainConfig();

        DeployProtocolVersionsProxyScript protocolVersionsProxyDeployments = new DeployProtocolVersionsProxyScript();
        DeployAndInitializeProtocolVersionsScript protocolVersionsDeployments = new DeployAndInitializeProtocolVersionsScript();

        // Deploy a new ProxyAdmin and AddressManager
        addressManagerDeployments.deploy();
        proxyAdminDeployments.deploy();
        proxyAdminDeployments.initialize();

        // Deploy the SuperchainConfigProxy
        superchainConfigProxyDeployments.deploy();
        superchainConfigDeployments.deploy();
        superchainConfigDeployments.initialize();

        // Deploy the ProtocolVersionsProxy
        protocolVersionsProxyDeployments.deploy();
        protocolVersionsDeployments.deploy();
        protocolVersionsDeployments.initialize();


        console.log("AddressManager at: ", deployerProcedue.getAddress("AddressManager"));
        console.log("ProxyAdmin at: ", deployerProcedue.getAddress("ProxyAdmin"));
        console.log("SuperchainConfigProxy at: ", deployerProcedue.getAddress("SuperchainConfigProxy"));
        console.log("SuperchainConfig at: ", deployerProcedue.getAddress("SuperchainConfig"));
        console.log("ProtocolVersionsProxy at: ", deployerProcedue.getAddress("ProtocolVersionsProxy"));
    }
}
