// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import {Script} from "@redprint-forge-std/Script.sol";
// import {IDeployer, getDeployer} from "@redprint-deploy/deployer/DeployScript.sol";
// import {DeploySafeProxyScript} from "@scripts/101_DeploySafeProxyScript.s.sol";
// import {DeployAddressManagerScript} from "@scripts/201A_DeployAddressManagerScript.s.sol";
// import {DeployAndSetupProxyAdminScript} from "@scripts/201B_DeployAndSetupProxyAdminScript.s.sol";
// import {DeploySuperchainConfigProxyScript} from "@scripts/202A_DeploySuperchainConfigProxyScript.s.sol";
// import {DeployAndInitializeSuperchainConfigScript} from "@scripts/202B_DeployAndInitializeSuperchainConfigScript.s.sol";
// import {DeployProtocolVersionsProxyScript} from "@scripts/203A_DeployProtocolVersionsProxyScript.s.sol";
// import {DeployAndInitializeProtocolVersionsScript} from "@scripts/203B_DeployAndInitializeProtocolVersionsScript.s.sol";

// import {DeployOptimismPortalProxyScript} from "@scripts/401A_DeployOptimismPortalProxyScript.s.sol";
// import {DeploySystemConfigProxyScript} from "@scripts/401B_DeploySystemConfigProxyScript.s.sol";
// import {DeployL1StandardBridgeProxyScript} from "@scripts/401C_DeployL1StandardBridgeProxyScript.s.sol";
// import {DeployL1CrossDomainMessengerProxyScript} from "@scripts/401D_DeployL1CrossDomainMessengerProxyScript.s.sol";
// import {DeployOptimismMintableERC20FactoryProxyScript} from "@scripts/401E_DeployOptimismMintableERC20FactoryProxyScript.s.sol";
// import {DeployL1ERC721BridgeProxyScript} from "@scripts/401F_DeployL1ERC721BridgeProxyScript.s.sol";
// import {DeployDisputeGameFactoryProxyScript} from "@scripts/401G_DeployDisputeGameFactoryProxyScript.s.sol";
// import {DeployL2OutputOracleProxyScript} from "@scripts/401H_DeployL2OutputOracleProxyScript.s.sol";
// import {DeployDelayedWETHProxyScript} from "@scripts/401I_DeployDelayedWETHProxyScript.s.sol";
// import {DeployPermissionedDelayedWETHProxyScript} from "@scripts/401J_DeployPermissionedDelayedWETHProxyScript.s.sol";
// import {DeployAnchorStateRegistryProxyScript} from "@scripts/401K_DeployAnchorStateRegistryProxyScript.s.sol";


// contract DeployAllScript is Script {
//     IDeployer deployerProcedue;

//     function run() public {
//         deployerProcedue = getDeployer();
//         deployerProcedue.setAutoSave(true);
//         DeploySafeProxyScript safeDeployments = new DeploySafeProxyScript();
//         //1) set up Safe Multisig
//         safeDeployments.deploy();
//         DeployAddressManagerScript addressManagerDeployments = new DeployAddressManagerScript();
//         DeployAndSetupProxyAdminScript proxyAdminDeployments = new DeployAndSetupProxyAdminScript();

//         DeploySuperchainConfigProxyScript superchainConfigProxyDeployments = new DeploySuperchainConfigProxyScript();
//         DeployAndInitializeSuperchainConfigScript superchainConfigDeployments = new DeployAndInitializeSuperchainConfigScript();

//         DeployProtocolVersionsProxyScript protocolVersionsProxyDeployments = new DeployProtocolVersionsProxyScript();
//         DeployAndInitializeProtocolVersionsScript protocolVersionsDeployments = new DeployAndInitializeProtocolVersionsScript();

//         DeployOptimismPortalProxyScript optimismPortalProxyDeployments = new DeployOptimismPortalProxyScript();
//         DeploySystemConfigProxyScript systemConfigProxyDeployments = new DeploySystemConfigProxyScript();
//         DeployL1StandardBridgeProxyScript l1StandardBridgeProxyDeployments = new DeployL1StandardBridgeProxyScript();
//         DeployL1CrossDomainMessengerProxyScript l1CrossDomainMessengerProxyDeployments = new DeployL1CrossDomainMessengerProxyScript();
//         DeployOptimismMintableERC20FactoryProxyScript optimismMintableERC20FactoryProxyDeployments = new DeployOptimismMintableERC20FactoryProxyScript();
//         DeployL1ERC721BridgeProxyScript l1ERC721BridgeProxyDeployments = new DeployL1ERC721BridgeProxyScript();
//         DeployDisputeGameFactoryProxyScript disputeGameFactoryProxyDeployments = new DeployDisputeGameFactoryProxyScript();
//         DeployL2OutputOracleProxyScript l2OutputOracleProxyDeployments = new DeployL2OutputOracleProxyScript();
//         DeployDelayedWETHProxyScript delayedWETHProxyDeployments = new DeployDelayedWETHProxyScript();
//         DeployPermissionedDelayedWETHProxyScript permissionedDelayedWETHProxyDeployments = new DeployPermissionedDelayedWETHProxyScript();
//         DeployAnchorStateRegistryProxyScript anchorStateRegistryProxyDeployments = new DeployAnchorStateRegistryProxyScript();

//         // Deploy a new ProxyAdmin and AddressManager
//         addressManagerDeployments.deploy();
//         proxyAdminDeployments.deploy();
//         proxyAdminDeployments.initialize();

//         // Deploy the SuperchainConfigProxy
//         superchainConfigProxyDeployments.deploy();
//         superchainConfigDeployments.deploy();
//         superchainConfigDeployments.initialize();

//         // Deploy the ProtocolVersionsProxy
//         protocolVersionsProxyDeployments.deploy();
//         protocolVersionsDeployments.deploy();
//         protocolVersionsDeployments.initialize();

//         optimismPortalProxyDeployments.deploy();
//         systemConfigProxyDeployments.deploy();
//         l1StandardBridgeProxyDeployments.deploy();
//         l1CrossDomainMessengerProxyDeployments.deploy();
//         optimismMintableERC20FactoryProxyDeployments.deploy();
//         l1ERC721BridgeProxyDeployments.deploy();
//         disputeGameFactoryProxyDeployments.deploy();
//         l2OutputOracleProxyDeployments.deploy();
//         delayedWETHProxyDeployments.deploy();
//         permissionedDelayedWETHProxyDeployments.deploy();
//         anchorStateRegistryProxyDeployments.deploy();
//     }
// }
