// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console2 as console} from "@forge-std/console2.sol";
import {Vm,VmSafe} from "@forge-std/Vm.sol";

import {DeployScript, IDeployer} from "@script/deployer/DeployScript.sol";
import {DeployerFunctions, DeployOptions} from "@script/deployer/DeployerFunctions.sol";
import { ChainAssertions } from "@script/optimism/ChainAssertions.sol";

import { Safe } from "@safe-contracts/Safe.sol";
import { Enum as SafeOps } from "@safe-contracts/common/Enum.sol";

import {Proxy} from "@main/universal/ProxyAdmin.sol";
import {ProxyAdmin} from "@main/universal/ProxyAdmin.sol";
import { SuperchainConfig } from "@main/L1/SuperchainConfig.sol";

contract DeployAndInitializeSuperchainConfig is DeployScript {
    using DeployerFunctions for IDeployer;

    uint256 ownerPrivateKey = vm.deriveKey(vm.envString("MNEMONIC"), "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
    address owner = vm.envOr("DEPLOYER", vm.addr(ownerPrivateKey));

    // DeployConfig public constant cfg =
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
            _proxy: superchainConfigProxy,
            _implementation:  address(superchainConfig),
            _innerCallData: abi.encodeCall(SuperchainConfig.initialize, ( deployer.getConfig().superchainConfigGuardian(), false))
        });

        ChainAssertions.checkSuperchainConfig({ _contracts: deployer.getProxiesUnstrict(), _cfg: deployer.getConfig(), _isPaused: false });
    }

    /// @notice Call from the Safe contract to the Proxy Admin's upgrade and call method
    function _upgradeAndCallViaSafe(address _proxy, address _implementation, bytes memory _innerCallData) internal {
        address proxyAdmin = deployer.mustGetAddress("ProxyAdmin");

        bytes memory data =
            abi.encodeCall(ProxyAdmin.upgradeAndCall, (payable(_proxy), _implementation, _innerCallData));

        Safe safe = Safe(deployer.mustGetAddress("SystemOwnerSafe"));
        _callViaSafe({ _safe: safe, _target: proxyAdmin, _data: data });
    }

    /// @notice Make a call from the Safe contract to an arbitrary address with arbitrary data
    function _callViaSafe(Safe _safe, address _target, bytes memory _data) internal {

        // ProxyAdmin proxyAdmin = ProxyAdmin(deployer.mustGetAddress("ProxyAdmin"));
        // This is the signature format used the caller is also the signer.
        bytes memory signature = abi.encodePacked(uint256(uint160(owner)), bytes32(0), uint8(1));

        _safe.execTransaction({
            to: _target,
            value: 0,
            data: _data,
            operation: SafeOps.Operation.Call,
            safeTxGas: 0,
            baseGas: 0,
            gasPrice: 0,
            gasToken: address(0),
            refundReceiver: payable(address(0)),
            signatures: signature
        });

    }

    // to do : abstract inner setup functions

}