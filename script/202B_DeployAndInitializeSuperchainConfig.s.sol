// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console2 as console} from "@redprint-forge-std/console2.sol";
import {Vm,VmSafe} from "@redprint-forge-std/Vm.sol";

import {DeployScript, IDeployer} from "@redprint-deploy/deployer/DeployScript.sol";
import {DeployerFunctions, DeployOptions} from "@redprint-deploy/deployer/DeployerFunctions.sol";
import { ChainAssertions } from "@redprint-deploy/optimism/ChainAssertions.sol";

import { SafeScript} from "@redprint-deploy/safe-management/SafeScript.sol";

import {Proxy} from "@redprint-core/universal/ProxyAdmin.sol";
import { SuperchainConfig } from "@redprint-core/L1/SuperchainConfig.sol";

contract DeployAndInitializeSuperchainConfig is DeployScript, SafeScript {
    using DeployerFunctions for IDeployer;

    uint256 ownerPrivateKey = vm.deriveKey(vm.envString("MNEMONIC"), "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
    address owner = vm.envOr("DEPLOYER", vm.addr(ownerPrivateKey));

    SuperchainConfig superchainConfig;

    function deploy() external returns (SuperchainConfig) {
        bytes32 _salt = DeployScript.implSalt();

        DeployOptions memory options = DeployOptions({salt:_salt});

        superchainConfig = deployer.deploy_SuperchainConfig("SuperchainConfig", options);
        return superchainConfig;
    }

    function initialize() external  {
        (VmSafe.CallerMode mode ,address msgSender, ) = vm.readCallers();
        if(mode != VmSafe.CallerMode.Broadcast && msgSender != owner) {
            console.log("Pranking owner ...");
            // vm.prank(owner);
            //  to do : doc this + how to write script
            //  startPrank due to delegate call
            vm.startPrank(owner);
            initializeSuperchainConfig();
            vm.stopPrank();
        } else {
            console.log("Broadcasting ...");
            vm.startBroadcast(owner);

            initializeSuperchainConfig();
            console.log("SuperchainConfig setted to : %s", address(superchainConfig));

            vm.stopBroadcast();
        }
    }
    
    /// @notice Initialize the SuperchainConfig
    function initializeSuperchainConfig() public {
        console.log("Upgrading and initializing SuperchainConfig");
        address payable superchainConfigProxy = deployer.mustGetAddress("SuperchainConfigProxy");
        _upgradeAndCallViaSafe({
            _deployer: deployer,
            _owner: owner,
            _proxy: superchainConfigProxy,
            _implementation:  address(superchainConfig),
            _innerCallData: abi.encodeCall(SuperchainConfig.initialize, ( deployer.getConfig().superchainConfigGuardian(), false))
        });

        ChainAssertions.checkSuperchainConfig({ _contracts: deployer.getProxiesUnstrict(), _cfg: deployer.getConfig(), _isPaused: false });
    }

}