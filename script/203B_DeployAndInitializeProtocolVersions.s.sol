// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console2 as console} from "@forge-std/console2.sol";
import {Vm,VmSafe} from "@forge-std/Vm.sol";

import {DeployScript, IDeployer} from "@script/deployer/DeployScript.sol";
import {DeployerFunctions, DeployOptions} from "@script/deployer/DeployerFunctions.sol";

import { Types } from "@script/optimism/Types.sol";
import { ChainAssertions } from "@script/optimism/ChainAssertions.sol";

import { Safe } from "@safe-contracts/Safe.sol";
import { Enum as SafeOps } from "@safe-contracts/common/Enum.sol";

import {Proxy} from "@main/universal/ProxyAdmin.sol";
import {ProxyAdmin} from "@main/universal/ProxyAdmin.sol";

import { ProtocolVersions, ProtocolVersion } from "@main/L1/ProtocolVersions.sol";

contract DeployAndInitializeProtocolVersionsScript is DeployScript {
    using DeployerFunctions for IDeployer;

    uint256 ownerPrivateKey = vm.deriveKey(vm.envString("MNEMONIC"), "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
    address owner = vm.envOr("DEPLOYER", vm.addr(ownerPrivateKey));

    // SuperchainConfig superChainConfig;
    ProtocolVersions versions;

    function deploy() external returns (ProtocolVersions) {
        bytes32 _salt = DeployScript.implSalt();

        DeployOptions memory options = DeployOptions({salt:_salt});

        versions = deployer.deploy_ProtocolVersions("ProtocolVersions", options);

        Types.ContractSet memory contracts = _proxiesUnstrict();
        contracts.ProtocolVersions = address(versions);
        // superChainConfig = SuperchainConfig(deployer.mustGetAddress("SuperchainConfigProxy"));
        ChainAssertions.checkProtocolVersions({ _contracts: contracts, _cfg: deployer.getConfig(), _isProxy: false });

        return versions;
    }

    /// @notice Returns the proxy addresses, not reverting if any are unset.
    function _proxiesUnstrict() internal view returns (Types.ContractSet memory proxies_) {
        proxies_ = Types.ContractSet({
            L1CrossDomainMessenger: deployer.getAddress("L1CrossDomainMessengerProxy"),
            L1StandardBridge: deployer.getAddress("L1StandardBridgeProxy"),
            L2OutputOracle: deployer.getAddress("L2OutputOracleProxy"),
            DisputeGameFactory: deployer.getAddress("DisputeGameFactoryProxy"),
            DelayedWETH: deployer.getAddress("DelayedWETHProxy"),
            AnchorStateRegistry: deployer.getAddress("AnchorStateRegistryProxy"),
            OptimismMintableERC20Factory: deployer.getAddress("OptimismMintableERC20FactoryProxy"),
            OptimismPortal: deployer.getAddress("OptimismPortalProxy"),
            OptimismPortal2: deployer.getAddress("OptimismPortalProxy"),
            SystemConfig: deployer.getAddress("SystemConfigProxy"),
            L1ERC721Bridge: deployer.getAddress("L1ERC721BridgeProxy"),
            ProtocolVersions: deployer.getAddress("ProtocolVersionsProxy"),
            SuperchainConfig: deployer.getAddress("SuperchainConfigProxy")
        });
    }


    function initialize() external  {
       
        (VmSafe.CallerMode mode ,address msgSender, ) = vm.readCallers();
        if(mode != VmSafe.CallerMode.Broadcast && msgSender != owner) {
            console.log("Pranking owner ...");
            // vm.prank(owner);
            //  to do : doc this + how to write script
            //  startPrank due to delegate call
            vm.startPrank(owner);
            initializeProtocolVersions();
            vm.stopPrank();
        } else {
            console.log("Broadcasting ...");
            vm.startBroadcast(owner);

            initializeProtocolVersions();
            console.log("ProtocolVersions setted to : %s", address(versions));

            vm.stopBroadcast();
        }

    }
    

    /// @notice Initialize the ProtocolVersions
    function initializeProtocolVersions() public {

        console.log("Upgrading and initializing ProtocolVersions proxy");

        address protocolVersionsProxy = deployer.mustGetAddress("ProtocolVersionsProxy");
        address protocolVersions = deployer.mustGetAddress("ProtocolVersions");

        address finalSystemOwner = deployer.getConfig().finalSystemOwner();
        uint256 requiredProtocolVersion = deployer.getConfig().requiredProtocolVersion();
        uint256 recommendedProtocolVersion = deployer.getConfig().recommendedProtocolVersion();

        _upgradeAndCallViaSafe({
            _proxy: payable(protocolVersionsProxy),
            _implementation: protocolVersions,
            _innerCallData: abi.encodeCall(
                ProtocolVersions.initialize,
                (
                    finalSystemOwner,
                    ProtocolVersion.wrap(requiredProtocolVersion),
                    ProtocolVersion.wrap(recommendedProtocolVersion)
                )
            )
        });

        ProtocolVersions _versions = ProtocolVersions(protocolVersionsProxy);
        string memory version = _versions.version();
        console.log("ProtocolVersions version: %s", version);

        ChainAssertions.checkProtocolVersions({ _contracts: _proxiesUnstrict(), _cfg: deployer.getConfig(), _isProxy: true });

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