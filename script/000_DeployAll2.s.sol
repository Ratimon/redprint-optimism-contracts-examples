// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "@redprint-forge-std/Script.sol";
import {IDeployer, getDeployer} from "@redprint-deploy/deployer/DeployScript.sol";
import {DeploySafeProxyScript} from "@script/101_DeploySafeProxyScript.s.sol";
import {DeployAddressManagerScript} from "@script/201A_DeployAddressManagerScript.s.sol";
import {DeployAndSetupProxyAdminScript} from "@script/201B_DeployAndSetupProxyAdminScript.s.sol";
import {DeploySuperchainConfigProxyScript} from "@script/202A_DeploySuperchainConfigProxyScript.s.sol";
import {DeployAndInitializeSuperchainConfigScript} from "@script/202B_DeployAndInitializeSuperchainConfigScript.s.sol";
import {DeployProtocolVersionsProxyScript} from "@script/203A_DeployProtocolVersionsProxyScript.s.sol";
import {DeployAndInitializeProtocolVersionsScript} from "@script/203B_DeployAndInitializeProtocolVersionsScript.s.sol";

contract DeployAllScript is Script {
    IDeployer deployerProcedue;

    function run() public {
        deployerProcedue = getDeployer();
        deployerProcedue.setAutoSave(true);
        DeploySafeProxyScript safeDeployments = new DeploySafeProxyScript();
        //1) set up Safe Multisig
        safeDeployments.deploy();
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
    }
}
