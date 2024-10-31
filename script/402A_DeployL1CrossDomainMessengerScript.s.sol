// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DeployScript, IDeployer} from "@redprint-deploy/deployer/DeployScript.sol";

import {DeployerFunctions, DeployOptions} from "@redprint-deploy/deployer/DeployerFunctions.sol";
import {Types} from "@redprint-deploy/optimism/Types.sol";
import {ChainAssertions} from "@redprint-deploy/optimism/ChainAssertions.sol";

import {L1CrossDomainMessenger} from "@redprint-core/L1/L1CrossDomainMessenger.sol";

/// @custom:security-contact Consult full internal deploy script at https://github.com/Ratimon/redprint-forge
contract DeployL1CrossDomainMessengerScript is DeployScript {
    using DeployerFunctions for IDeployer ;

    L1CrossDomainMessenger l1CrossDomainMessenger;

    function deploy() external returns (L1CrossDomainMessenger) {
        bytes32 _salt = DeployScript.implSalt();

        DeployOptions memory options = DeployOptions({salt:_salt});
        l1CrossDomainMessenger = deployer.deploy_L1CrossDomainMessenger("L1CrossDomainMessenger", options);
        Types.ContractSet memory contracts =  deployer.getProxiesUnstrict();
       
        contracts.L1CrossDomainMessenger = address(l1CrossDomainMessenger);
        ChainAssertions.checkL1CrossDomainMessenger({ _contracts: contracts, _vm: vm, _isProxy: false });

        return l1CrossDomainMessenger;
    }

    // to do : Abstract
    // function _proxiesUnstrict()
    //     internal
    //     view
    //     returns (Types.ContractSet memory proxies_)
    // {
    //     proxies_ = Types.ContractSet({
    //         L1CrossDomainMessenger: deployer.getAddress("L1CrossDomainMessengerProxy"),
    //         L1StandardBridge: deployer.getAddress("L1StandardBridgeProxy"),
    //         L2OutputOracle: deployer.getAddress("L2OutputOracleProxy"),
    //         DisputeGameFactory: deployer.getAddress("DisputeGameFactoryProxy"),
    //         DelayedWETH: deployer.getAddress("DelayedWETHProxy"),
    //         AnchorStateRegistry: deployer.getAddress("AnchorStateRegistryProxy"),
    //         OptimismMintableERC20Factory: deployer.getAddress("OptimismMintableERC20FactoryProxy"),
    //         OptimismPortal: deployer.getAddress("OptimismPortalProxy"),
    //         OptimismPortal2: deployer.getAddress("OptimismPortalProxy"),
    //         SystemConfig: deployer.getAddress("SystemConfigProxy"),
    //         L1ERC721Bridge: deployer.getAddress("L1ERC721BridgeProxy"),
    //         ProtocolVersions: deployer.getAddress("ProtocolVersionsProxy"),
    //         SuperchainConfig: deployer.getAddress("SuperchainConfigProxy")
    //     });
    // }
}
