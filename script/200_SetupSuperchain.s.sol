// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "@redprint-forge-std/Script.sol";
import {console2 as console} from "@redprint-forge-std/console2.sol";

import {IDeployer, getDeployer} from "@redprint-deploy/deployer/DeployScript.sol";

import {DeployAddressManagerScript} from "@script/201A_DeployAddressManagerScript.s.sol";
import {DeployAndSetupProxyAdminScript} from "@script/201B_DeployAndSetupProxyAdminScript.s.sol";
import {DeploySuperchainConfigProxyScript} from "@script/202A_DeploySuperchainConfigProxyScript.s.sol";
import {DeployAndInitializeSuperchainConfigScript} from "@script/202B_DeployAndInitializeSuperchainConfigScript.s.sol";
import {DeployProtocolVersionsProxyScript} from "@script/203A_DeployProtocolVersionsProxyScript.s.sol";
import {DeployAndInitializeProtocolVersionsScript} from "@script/203B_DeployAndInitializeProtocolVersionsScript.s.sol";

import {DeployOptimismPortalProxyScript} from "@script/401A_DeployOptimismPortalProxyScript.s.sol";
import {DeploySystemConfigProxyScript} from "@script/401B_DeploySystemConfigProxyScript.s.sol";
import {DeployL1CrossDomainMessengerProxyScript} from "@script/401C_DeployL1CrossDomainMessengerProxyScript.s.sol";

import {AddressManager} from "@redprint-core/legacy/AddressManager.sol";

contract SetupSuperchainScript is Script {
    IDeployer deployerProcedue;

    function run() public {
        deployerProcedue = getDeployer();
        deployerProcedue.setAutoSave(true);

        DeployAddressManagerScript addressManagerDeployments = new DeployAddressManagerScript();
        DeployAndSetupProxyAdminScript proxyAdminDeployments = new DeployAndSetupProxyAdminScript();

        DeploySuperchainConfigProxyScript superchainConfigProxyDeployments = new DeploySuperchainConfigProxyScript();
        DeployAndInitializeSuperchainConfigScript superchainConfigDeployments = new DeployAndInitializeSuperchainConfigScript();

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
