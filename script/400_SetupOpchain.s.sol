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

import {DeployL1CrossDomainMessengerScript} from "@script/402A_DeployL1CrossDomainMessengerScript.s.sol";

contract SetupOpchainScript is Script {
    IDeployer deployerProcedue;

    function run() public {
        deployerProcedue = getDeployer();
        deployerProcedue.setAutoSave(true);
        
        // Proxies Deployments
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

        // Implementations Deployments
        DeployL1CrossDomainMessengerScript l1CrossDomainMessengerDeployments = new DeployL1CrossDomainMessengerScript();


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
        transferAddressManagerOwnership();
        
        console.log("OptimismPortalProxy at: ", deployerProcedue.getAddress("OptimismPortalProxy"));
        console.log("SystemConfigProxy at: ", deployerProcedue.getAddress("SystemConfigProxy"));
        console.log("L1CrossDomainMessengerProxy at: ", deployerProcedue.getAddress("L1CrossDomainMessengerProxy"));
        console.log("L1ERC721BridgeProxy at: ", deployerProcedue.getAddress("L1ERC721BridgeProxy"));

        console.log("DisputeGameFactoryProxy at: ", deployerProcedue.getAddress("DisputeGameFactoryProxy"));
        console.log("L2OutputOracleProxy at: ", deployerProcedue.getAddress("L2OutputOracleProxy"));
        console.log("DelayedWETHProxy at: ", deployerProcedue.getAddress("DelayedWETHProxy"));
        console.log("PermissionedDelayedWETHProxy at: ", deployerProcedue.getAddress("PermissionedDelayedWETHProxy"));
        console.log("AnchorStateRegistryProxy at: ", deployerProcedue.getAddress("AnchorStateRegistryProxy"));

        l1CrossDomainMessengerDeployments.deploy();
        
        console.log("L1CrossDomainMessenger at: ", deployerProcedue.getAddress("L1CrossDomainMessenger"));
    }

    function transferAddressManagerOwnership() internal {
        
        console.log("Transferring AddressManager ownership to ProxyAdmin");
        AddressManager addressManager = AddressManager(deployerProcedue.mustGetAddress("AddressManager"));
        address owner = addressManager.owner();
        address proxyAdmin = deployerProcedue.mustGetAddress("ProxyAdmin");
        (VmSafe.CallerMode mode ,address msgSender, ) = vm.readCallers();

        if (owner != proxyAdmin) {

            if(mode != VmSafe.CallerMode.Broadcast && msgSender != owner) {
                console.log("Pranking ower ...");
                vm.prank(owner);
             } else {
                console.log("Broadcasting ...");
                vm.broadcast(owner);
             }

            addressManager.transferOwnership(proxyAdmin);
            console.log("AddressManager ownership transferred to %s", proxyAdmin);
        }

        require(addressManager.owner() == proxyAdmin);
    }
}
