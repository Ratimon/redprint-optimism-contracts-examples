// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "@redprint-forge-std/Script.sol";
import {console} from "@redprint-forge-std/console.sol";
import {Vm, VmSafe} from "@redprint-forge-std/Vm.sol";
import {IDeployer, getDeployer} from "@redprint-deploy/deployer/DeployScript.sol";
import {AddressManager} from "@redprint-core/legacy/AddressManager.sol";
import {DeployOptimismPortalProxyScript} from "@script/401A_DeployOptimismPortalProxyScript.s.sol";
import {DeploySystemConfigProxyScript} from "@script/401B_DeploySystemConfigProxyScript.s.sol";
import {DeployL1StandardBridgeProxyScript} from "@script/401C_DeployL1StandardBridgeProxyScript.s.sol";
import {DeployL1CrossDomainMessengerProxyScript} from "@script/401D_DeployL1CrossDomainMessengerProxyScript.s.sol";
import {DeployOptimismMintableERC20FactoryProxyScript} from "@script/401E_DeployOptimismMintableERC20FactoryProxyScript.s.sol";
import {DeployL1ERC721BridgeProxyScript} from "@script/401F_DeployL1ERC721BridgeProxyScript.s.sol";
import {DeployDisputeGameFactoryProxyScript} from "@script/401G_DeployDisputeGameFactoryProxyScript.s.sol";
import {DeployL2OutputOracleProxyScript} from "@script/401H_DeployL2OutputOracleProxyScript.s.sol";
import {DeployDelayedWETHProxyScript} from "@script/401I_DeployDelayedWETHProxyScript.s.sol";
import {DeployPermissionedDelayedWETHProxyScript} from "@script/401J_DeployPermissionedDelayedWETHProxyScript.s.sol";
import {DeployAnchorStateRegistryProxyScript} from "@script/401K_DeployAnchorStateRegistryProxyScript.s.sol";
import {TransferAddressManagerOwnershipScript} from "@script/401L_TransferAddressManagerOwnershipScript.s.sol";

// implementations
import {DeployL1CrossDomainMessengerScript} from "@script/402A_DeployL1CrossDomainMessengerScript.s.sol";
import {DeployOptimismMintableERC20FactoryScript} from "@script/402B_DeployOptimismMintableERC20Factory.s.sol";
// import {DeploySystemConfigScript} from "@script/402C_DeploySystemConfig.s.sol";
import {DeploySystemConfigInteropScript} from "@script/402C_DeploySystemConfigScript2.s.sol";
import {DeployL1StandardBridgeScript} from "@script/402D_DeployL1StandardBridgeScript.s.sol";
import {DeployL1ERC721BridgeScript} from "@script/402E_DeployL1ERC721BridgeScript.s.sol";
import {DeployOptimismPortalScript} from "@script/402F_DeployOptimismPortalScript.s.sol";
import {DeployL2OutputOracleScript} from "@script/402G_DeployL2OutputOracleScript.s.sol";
// import {DeployOptimismPortal2Script} from "@script/402H_DeployOptimismPortal2Script.s.sol";
import {DeployOptimismPortalInteropScript} from "@script/402H_DeployOptimismPortalInteropScript.s.sol";
import {DeployDisputeGameFactoryScript} from "@script/402I_DeployDisputeGameFactoryScript.s.sol";
import {DeployDelayedWETHScript} from "@script/402J_DeployDelayedWETHScript.s.sol";
import {DeployPreimageOracleScript} from "@script/402K_DeployPreimageOracleScript.s.sol";
import {DeployMIPSScript} from "@script/402L_DeployMIPSScript.s.sol";
import {DeployAnchorStateRegistryScript} from "@script/402M_DeployAnchorStateRegistryScript.s.sol";
import {InitializeImplementationsScript} from "@script/402N_InitializeImplementationsScript.s.sol";


contract SetupOpchainScript is Script {
    IDeployer deployerProcedue;

    function run() public {
        deployerProcedue = getDeployer();
        deployerProcedue.setAutoSave(true);
        
        DeployOptimismPortalProxyScript optimismPortalProxyDeployments = new DeployOptimismPortalProxyScript();
        DeploySystemConfigProxyScript systemConfigProxyDeployments = new DeploySystemConfigProxyScript();
        DeployL1StandardBridgeProxyScript l1StandardBridgeProxyDeployments = new DeployL1StandardBridgeProxyScript();
        DeployL1CrossDomainMessengerProxyScript l1CrossDomainMessengerProxyDeployments = new DeployL1CrossDomainMessengerProxyScript();
        DeployOptimismMintableERC20FactoryProxyScript optimismMintableERC20FactoryProxyDeployments = new DeployOptimismMintableERC20FactoryProxyScript();
        DeployL1ERC721BridgeProxyScript l1ERC721BridgeProxyDeployments = new DeployL1ERC721BridgeProxyScript();
        DeployDisputeGameFactoryProxyScript disputeGameFactoryProxyDeployments = new DeployDisputeGameFactoryProxyScript();
        DeployL2OutputOracleProxyScript l2OutputOracleProxyDeployments = new DeployL2OutputOracleProxyScript();
        DeployDelayedWETHProxyScript delayedWETHProxyDeployments = new DeployDelayedWETHProxyScript();
        DeployPermissionedDelayedWETHProxyScript permissionedDelayedWETHProxyDeployments = new DeployPermissionedDelayedWETHProxyScript();
        DeployAnchorStateRegistryProxyScript anchorStateRegistryProxyDeployments = new DeployAnchorStateRegistryProxyScript();
        TransferAddressManagerOwnershipScript transferAddressManagerOwnership = new TransferAddressManagerOwnershipScript();

        optimismPortalProxyDeployments.deploy();
        systemConfigProxyDeployments.deploy();
        l1StandardBridgeProxyDeployments.deploy();
        l1CrossDomainMessengerProxyDeployments.deploy();
        optimismMintableERC20FactoryProxyDeployments.deploy();
        l1ERC721BridgeProxyDeployments.deploy();
        disputeGameFactoryProxyDeployments.deploy();
        l2OutputOracleProxyDeployments.deploy();
        delayedWETHProxyDeployments.deploy();
        permissionedDelayedWETHProxyDeployments.deploy();
        anchorStateRegistryProxyDeployments.deploy();
        transferAddressManagerOwnership.run();
        
        console.log("OptimismPortalProxy at: ", deployerProcedue.getAddress("OptimismPortalProxy"));
        console.log("SystemConfigProxy at: ", deployerProcedue.getAddress("SystemConfigProxy"));
        console.log("L1CrossDomainMessengerProxy at: ", deployerProcedue.getAddress("L1CrossDomainMessengerProxy"));
        console.log("L1ERC721BridgeProxy at: ", deployerProcedue.getAddress("L1ERC721BridgeProxy"));

        console.log("DisputeGameFactoryProxy at: ", deployerProcedue.getAddress("DisputeGameFactoryProxy"));
        console.log("L2OutputOracleProxy at: ", deployerProcedue.getAddress("L2OutputOracleProxy"));
        console.log("DelayedWETHProxy at: ", deployerProcedue.getAddress("DelayedWETHProxy"));
        console.log("PermissionedDelayedWETHProxy at: ", deployerProcedue.getAddress("PermissionedDelayedWETHProxy"));
        console.log("AnchorStateRegistryProxy at: ", deployerProcedue.getAddress("AnchorStateRegistryProxy"));

        DeployL1CrossDomainMessengerScript l1CrossDomainMessengerDeployments = new DeployL1CrossDomainMessengerScript();
        DeployOptimismMintableERC20FactoryScript optimismMintableERC20FactoryDeployments = new DeployOptimismMintableERC20FactoryScript();
        DeploySystemConfigInteropScript systemConfigDeployments = new DeploySystemConfigInteropScript();
        DeployL1StandardBridgeScript l1StandardBridgeDeployments = new DeployL1StandardBridgeScript();
        DeployL1ERC721BridgeScript l1ERC721BridgeDeployments = new DeployL1ERC721BridgeScript();
        DeployOptimismPortalScript optimismPortalDeployments = new DeployOptimismPortalScript();
        DeployL2OutputOracleScript l2OutputOracleDeployments = new DeployL2OutputOracleScript();
        // DeployOptimismPortal2Script optimismPortal2Deployments = new DeployOptimismPortal2Script();
        DeployOptimismPortalInteropScript optimismPortal2Deployments = new DeployOptimismPortalInteropScript();
        DeployDisputeGameFactoryScript disputeGameFactoryDeployments = new DeployDisputeGameFactoryScript();
        DeployDelayedWETHScript delayedWETHDeployments = new DeployDelayedWETHScript();
        DeployPreimageOracleScript preimageOracleDeployments = new DeployPreimageOracleScript();
        DeployMIPSScript mipsDeployments = new DeployMIPSScript();
        DeployAnchorStateRegistryScript anchorStateRegistryDeployments = new DeployAnchorStateRegistryScript();
        InitializeImplementationsScript initializeImplementations = new InitializeImplementationsScript();


        l1CrossDomainMessengerDeployments.deploy();
        optimismMintableERC20FactoryDeployments.deploy();
        systemConfigDeployments.deploy();
        l1StandardBridgeDeployments.deploy();
        l1ERC721BridgeDeployments.deploy();
        optimismPortalDeployments.deploy();
        l2OutputOracleDeployments.deploy();
        optimismPortal2Deployments.deploy();
        disputeGameFactoryDeployments.deploy();
        delayedWETHDeployments.deploy();
        preimageOracleDeployments.deploy();
        mipsDeployments.deploy();
        anchorStateRegistryDeployments.deploy();
        initializeImplementations.run();
        
        console.log("L1CrossDomainMessenger at: ", deployerProcedue.getAddress("L1CrossDomainMessenger"));
        console.log("OptimismMintableERC20Factory at: ", deployerProcedue.getAddress("OptimismMintableERC20Factory"));
        console.log("SystemConfigInterop at: ", deployerProcedue.getAddress("SystemConfigInterop"));
        console.log("L1StandardBridge at: ", deployerProcedue.getAddress("L1StandardBridge"));
        console.log("L1ERC721Bridge at: ", deployerProcedue.getAddress("L1ERC721Bridge"));
        console.log("OptimismPortal at: ", deployerProcedue.getAddress("OptimismPortal"));

        console.log("FaultProof Contract"); 
        console.log("OptimismPortal2 at: ", deployerProcedue.getAddress("OptimismPortal2"));
        console.log("L2OutputOracle at: ", deployerProcedue.getAddress("L2OutputOracle"));
        console.log("DisputeGameFactory at: ", deployerProcedue.getAddress("DisputeGameFactory"));
        console.log("DelayedWETH at: ", deployerProcedue.getAddress("DelayedWETH"));
        console.log("PreimageOracle at: ", deployerProcedue.getAddress("PreimageOracle"));
        console.log("MIPS at: ", deployerProcedue.getAddress("MIPS"));
        console.log("AnchorStateRegistry at: ", deployerProcedue.getAddress("AnchorStateRegistry"));
    }


    // function transferAddressManagerOwnership() internal {
        
    //     console.log("Transferring AddressManager ownership to ProxyAdmin");
    //     AddressManager addressManager = AddressManager(deployerProcedue.mustGetAddress("AddressManager"));
    //     address owner = addressManager.owner();
    //     address proxyAdmin = deployerProcedue.mustGetAddress("ProxyAdmin");
    //     (VmSafe.CallerMode mode ,address msgSender, ) = vm.readCallers();

    //     if (owner != proxyAdmin) {

    //         if(mode != VmSafe.CallerMode.Broadcast && msgSender != owner) {
    //             console.log("Pranking owner ...");
    //             vm.prank(owner);
    //          } else {
    //             console.log("Broadcasting ...");
    //             vm.broadcast(owner);
    //          }

    //         addressManager.transferOwnership(proxyAdmin);
    //         console.log("AddressManager ownership transferred to %s", proxyAdmin);
    //     }

    //     require(addressManager.owner() == proxyAdmin);
    // }
}
