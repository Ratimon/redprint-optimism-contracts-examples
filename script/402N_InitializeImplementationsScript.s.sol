// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "@redprint-forge-std/Script.sol";
import {console} from "@redprint-forge-std/console.sol";
import {Vm, VmSafe} from "@redprint-forge-std/Vm.sol";
import {SafeScript} from "@redprint-deploy/safe-management/SafeScript.sol";
import {IDeployer, getDeployer} from "@redprint-deploy/deployer/DeployScript.sol";
import {DeployConfig} from "@redprint-deploy/deployer/DeployConfig.s.sol";

import {Types} from "@redprint-deploy/optimism/Types.sol";
import {ChainAssertions} from "@redprint-deploy/optimism/ChainAssertions.sol";

import { Constants } from "@redprint-core/libraries/Constants.sol";

// import { GameType} from "@redprint-core/dispute/lib/LibUDT.sol";
// import { IDisputeGameFactory } from "@redprint-core/dispute/interfaces/IDisputeGameFactory.sol";
import { ISystemConfig } from "@redprint-core/L1/interfaces/ISystemConfig.sol";
import { ISuperchainConfig } from "@redprint-core/L1/interfaces/ISuperchainConfig.sol";
import { IL2OutputOracle} from "@redprint-core/L1/interfaces/IL2OutputOracle.sol";

import {OptimismPortal} from "@redprint-core/L1/OptimismPortal.sol";
// import {OptimismPortal2} from "@redprint-core/L1/OptimismPortal2.sol";
import {SystemConfig} from "@redprint-core/L1/SystemConfig.sol";

import {IL1CrossDomainMessenger} from "@redprint-core/L1/interfaces/IL1CrossDomainMessenger.sol";
import {ProxyAdmin} from "@redprint-core/universal/ProxyAdmin.sol";
import {Safe} from "@redprint-safe-contracts/Safe.sol";
import {L1StandardBridge} from "@redprint-core/L1/L1StandardBridge.sol";


contract InitializeImplementationsScript is Script , SafeScript{
    IDeployer deployerProcedue;
    address public constant customGasTokenAddress = 0x0000000000000000000000000000000000000000;

    string mnemonic = vm.envString("MNEMONIC");
    uint256 ownerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1);
    address owner = vm.envOr("DEPLOYER_ADDRESS", vm.addr(ownerPrivateKey));

    function run() public {

        deployerProcedue = getDeployer();
        deployerProcedue.setAutoSave(true);

        console.log("Initializing implementations");

        (VmSafe.CallerMode mode ,address msgSender, ) = vm.readCallers();
        if(mode != VmSafe.CallerMode.Broadcast && msgSender != owner) {
            console.log("Pranking owner ...");
            vm.startPrank(owner);

            // initializeOptimismPortal2();
            initializeOptimismPortal();
            initializeSystemConfig();
            initializeL1StandardBridge();
            console.log("Pranking Stopped ...");

            vm.stopPrank();
        } else {
            console.log("Broadcasting ...");
            vm.startBroadcast(owner);

            // initializeOptimismPortal2();
            initializeOptimismPortal();
            initializeSystemConfig();
            initializeL1StandardBridge();
            console.log("Broadcasted");

            vm.stopBroadcast();
        }

    }


    // function initializeOptimismPortal2() internal {
    //     console.log("Upgrading and initializing OptimismPortal2 proxy");

    //     address proxyAdmin = deployerProcedue.mustGetAddress("ProxyAdmin");
    //     address safe = deployerProcedue.mustGetAddress("SystemOwnerSafe");

    //     address optimismPortalProxy = deployerProcedue.mustGetAddress("OptimismPortalProxy");
    //     address optimismPortal2 = deployerProcedue.mustGetAddress("OptimismPortal2");
    //     address disputeGameFactoryProxy = deployerProcedue.mustGetAddress("DisputeGameFactoryProxy");
    //     address systemConfigProxy = deployerProcedue.mustGetAddress("SystemConfigProxy");
    //     address superchainConfigProxy = deployerProcedue.mustGetAddress("SuperchainConfigProxy");

    //     DeployConfig cfg = deployerProcedue.getConfig();

    //     _upgradeAndCallViaSafe({
    //         _proxyAdmin: proxyAdmin,
    //         _safe: safe,
    //         _owner: owner,   
    //         _proxy: payable(optimismPortalProxy),
    //         _implementation: optimismPortal2,
    //         _innerCallData: abi.encodeCall(
    //             OptimismPortal2.initialize,
    //                 (
    //                     IDisputeGameFactory(disputeGameFactoryProxy),
    //                     ISystemConfig(systemConfigProxy),
    //                     ISuperchainConfig(superchainConfigProxy),
    //                     GameType.wrap(uint32(cfg.respectedGameType()))
    //                 )
    //         )
    //     });

    //     OptimismPortal2 portal = OptimismPortal2(payable(optimismPortalProxy));
    //     string memory version = portal.version();
    //     console.log("OptimismPortal2 version: %s", version);

    //     Types.ContractSet memory proxies =  deployerProcedue.getProxies();
    //     ChainAssertions.checkOptimismPortal2({ _contracts: proxies, _cfg: cfg, _isProxy: true });

    // }

    function initializeOptimismPortal() internal {
        console.log("Upgrading and initializing OptimismPortal2 proxy");

        address proxyAdmin = deployerProcedue.mustGetAddress("ProxyAdmin");
        address safe = deployerProcedue.mustGetAddress("SystemOwnerSafe");

        address optimismPortalProxy = deployerProcedue.mustGetAddress("OptimismPortalProxy");
        address optimismPortal = deployerProcedue.mustGetAddress("OptimismPortal");
        address l2OutputOracleProxy = deployerProcedue.mustGetAddress("L2OutputOracleProxy");
        address systemConfigProxy = deployerProcedue.mustGetAddress("SystemConfigProxy");
        address superchainConfigProxy = deployerProcedue.mustGetAddress("SuperchainConfigProxy");

        DeployConfig cfg = deployerProcedue.getConfig();

        _upgradeAndCallViaSafe({
            _proxyAdmin: proxyAdmin,
            _safe: safe,
            _owner: owner,   
            _proxy: payable(optimismPortalProxy),
            _implementation: optimismPortal,
            _innerCallData: abi.encodeCall(
                OptimismPortal.initialize,
                    (
                        IL2OutputOracle(l2OutputOracleProxy),
                        ISystemConfig(systemConfigProxy),
                        ISuperchainConfig(superchainConfigProxy)
                    )
            )
        });

        OptimismPortal portal = OptimismPortal(payable(optimismPortalProxy));
        string memory version = portal.version();
        console.log("OptimismPortal2 version: %s", version);

        Types.ContractSet memory proxies =  deployerProcedue.getProxies();
        ChainAssertions.checkOptimismPortal({ _contracts: proxies, _cfg: cfg, _isProxy: true });

    }

    function initializeSystemConfig() internal {
        console.log("Upgrading and initializing SystemConfig proxy");

        address proxyAdmin = deployerProcedue.mustGetAddress("ProxyAdmin");
        address safe = deployerProcedue.mustGetAddress("SystemOwnerSafe");

        address systemConfigProxy = deployerProcedue.mustGetAddress("SystemConfigProxy");
        address systemConfig = deployerProcedue.mustGetAddress("SystemConfig");

        DeployConfig cfg = deployerProcedue.getConfig();

        bytes32 batcherHash = bytes32(uint256(uint160(cfg.batchSenderAddress())));


        _upgradeAndCallViaSafe({
            _proxyAdmin: proxyAdmin,
            _safe: safe,
            _owner: owner,   
            _proxy: payable(systemConfigProxy),
            _implementation: systemConfig,
            _innerCallData: abi.encodeCall(
                SystemConfig.initialize,
                (
                    cfg.finalSystemOwner(),
                    cfg.basefeeScalar(),
                    cfg.blobbasefeeScalar(),
                    batcherHash,
                    uint64(cfg.l2GenesisBlockGasLimit()),
                    cfg.p2pSequencerAddress(),
                    Constants.DEFAULT_RESOURCE_CONFIG(),
                    cfg.batchInboxAddress(),
                    SystemConfig.Addresses({
                        l1CrossDomainMessenger: deployerProcedue.mustGetAddress("L1CrossDomainMessengerProxy"),
                        l1ERC721Bridge: deployerProcedue.mustGetAddress("L1ERC721BridgeProxy"),
                        l1StandardBridge: deployerProcedue.mustGetAddress("L1StandardBridgeProxy"),
                        disputeGameFactory: deployerProcedue.mustGetAddress("DisputeGameFactoryProxy"),
                        optimismPortal: deployerProcedue.mustGetAddress("OptimismPortalProxy"),
                        optimismMintableERC20Factory: deployerProcedue.mustGetAddress("OptimismMintableERC20FactoryProxy"),
                        // gasPayingToken: Constants.ETHER
                        gasPayingToken: customGasTokenAddress               
                    })
                )
            )
        });

        SystemConfig config = SystemConfig(systemConfigProxy);
        string memory version = config.version();
        console.log("SystemConfig version: %s", version);

        Types.ContractSet memory proxies =  deployerProcedue.getProxies();
        ChainAssertions.checkSystemConfig({ _contracts: proxies, _cfg: cfg, _isProxy: true });

    }

    function initializeL1StandardBridge() internal {

        console.log("Upgrading and initializing L1StandardBridge proxy");
        address proxyAdminAddress = deployerProcedue.mustGetAddress("ProxyAdmin");
        address safeAddress = deployerProcedue.mustGetAddress("SystemOwnerSafe");

        address l1StandardBridgeProxy = deployerProcedue.mustGetAddress("L1StandardBridgeProxy");
        address l1StandardBridge = deployerProcedue.mustGetAddress("L1StandardBridge");
        address l1CrossDomainMessengerProxy = deployerProcedue.mustGetAddress("L1CrossDomainMessengerProxy");
        address superchainConfigProxy = deployerProcedue.mustGetAddress("SuperchainConfigProxy");
        address systemConfigProxy = deployerProcedue.mustGetAddress("SystemConfigProxy");

        uint256 proxyType = uint256(ProxyAdmin(proxyAdminAddress).proxyType(l1StandardBridgeProxy));

        ProxyAdmin proxyAdmin = ProxyAdmin(proxyAdminAddress);
        Safe safe = Safe(payable(safeAddress));

        // to do ? is it needed ?

        // if (proxyType != uint256(ProxyAdmin.ProxyType.CHUGSPLASH)) {
        //     _callViaSafe({
        //         _safe: safe,
        //         _owner: owner,
        //         _target: address(proxyAdmin),
        //         _data: abi.encodeCall(ProxyAdmin.setProxyType, (l1StandardBridgeProxy, ProxyAdmin.ProxyType.CHUGSPLASH))
        //     });
        // }

        // require(uint256(proxyAdmin.proxyType(l1StandardBridgeProxy)) == uint256(ProxyAdmin.ProxyType.CHUGSPLASH),"Type not CHUGSPLASH");

        _upgradeAndCallViaSafe({
            _proxyAdmin: address(proxyAdmin),
            _safe: address(safe),
            _owner: owner,
            _proxy: payable(l1StandardBridgeProxy),
            _implementation: l1StandardBridge,
            _innerCallData: abi.encodeCall(
                L1StandardBridge.initialize,
                (
                    IL1CrossDomainMessenger(l1CrossDomainMessengerProxy),
                    ISuperchainConfig(superchainConfigProxy),
                    ISystemConfig(systemConfigProxy)
                )
            )
        });

        string memory version = L1StandardBridge(payable(l1StandardBridgeProxy)).version();
        console.log("L1StandardBridge version: %s", version);

        Types.ContractSet memory proxies =  deployerProcedue.getProxies();
        ChainAssertions.checkL1StandardBridge({ _contracts: proxies, _isProxy: true });

    }

}
