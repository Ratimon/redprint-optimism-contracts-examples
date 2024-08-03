// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console2 as console} from "@forge-std/console2.sol";
import {Vm,VmSafe} from "@forge-std/Vm.sol";

import {DeployScript, IDeployer} from "@script/deployer/DeployScript.sol";
import {DeployerFunctions, DeployOptions} from "@script/deployer/DeployerFunctions.sol";
import { ChainAssertions } from "@script/optimism/ChainAssertions.sol";

// import { Config } from "@script/deployer/Config.sol";

import { Safe } from "@safe-contracts/Safe.sol";
import { Enum as SafeOps } from "@safe-contracts/common/Enum.sol";

import {Proxy} from "@main/universal/ProxyAdmin.sol";
import {ProxyAdmin} from "@main/universal/ProxyAdmin.sol";
import { SuperchainConfig } from "@main/L1/SuperchainConfig.sol";

contract DeployAndInitializeSuperchainConfig is DeployScript {
    using DeployerFunctions for IDeployer;

    // DeployConfig public constant cfg =
    SuperchainConfig config;

    function deploy() external returns (SuperchainConfig) {
        bytes32 _salt = DeployScript.implSalt();

        DeployOptions memory options = DeployOptions({salt:_salt});

        config = deployer.deploy_SuperchainConfig("SuperchainConfig", options);

        // initializeSuperchainConfig();

        return config;
    }

    // /// @notice Initialize the SuperchainConfig
    // function initializeSuperchainConfig() public {
    //     address payable superchainConfigProxy = deployer.mustGetAddress("SuperchainConfigProxy");
    //     // address payable superchainConfig = deployer.mustGetAddress("SuperchainConfig");
    //     _upgradeAndCallViaSafe({
    //         _proxy: superchainConfigProxy,
    //         _implementation:  address(config),
    //         _innerCallData: abi.encodeCall(SuperchainConfig.initialize, ( deployer.getConfig().superchainConfigGuardian(), false))
    //     });



    //     ChainAssertions.checkSuperchainConfig({ _contracts: deployer.getProxiesUnstrict(), _cfg: deployer.getConfig(), _isPaused: false });
    // }

    // /// @notice Call from the Safe contract to the Proxy Admin's upgrade and call method
    // function _upgradeAndCallViaSafe(address _proxy, address _implementation, bytes memory _innerCallData) internal {
    //     address proxyAdmin = deployer.mustGetAddress("ProxyAdmin");

    //     bytes memory data =
    //         abi.encodeCall(ProxyAdmin.upgradeAndCall, (payable(_proxy), _implementation, _innerCallData));

    //     Safe safe = Safe(deployer.mustGetAddress("SystemOwnerSafe"));
    //     _callViaSafe({ _safe: safe, _target: proxyAdmin, _data: data });
    // }

    // /// @notice Make a call from the Safe contract to an arbitrary address with arbitrary data
    // function _callViaSafe(Safe _safe, address _target, bytes memory _data) internal {

    //     console.log('msg.sender');
    //     console.log(msg.sender);

    //     ProxyAdmin proxyAdmin = ProxyAdmin(deployer.mustGetAddress("ProxyAdmin"));

    //     console.log(' proxyAdmin.owner()');
    //     console.log(proxyAdmin.owner());

    //     string memory mnemonic = vm.envString("MNEMONIC");
    //     uint256 ownerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
    //     address owner = vm.envOr("DEPLOYER", vm.addr(ownerPrivateKey));

    //     // This is the signature format used the caller is also the signer.
    //     // address(this) = caller is deploy script
    //     bytes memory signature = abi.encodePacked(uint256(uint160(owner)), bytes32(0), uint8(1));

    //     _safe.execTransaction({
    //         to: _target,
    //         value: 0,
    //         data: _data,
    //         operation: SafeOps.Operation.Call,
    //         safeTxGas: 0,
    //         baseGas: 0,
    //         gasPrice: 0,
    //         gasToken: address(0),
    //         refundReceiver: payable(address(0)),
    //         signatures: signature
    //     });
    // }

    // // to do : abstract inner setup functions

}