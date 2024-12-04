// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "@redprint-forge-std/Script.sol";
import {console} from "@redprint-forge-std/console.sol";
import {Vm, VmSafe} from "@redprint-forge-std/Vm.sol";
import {IDeployer, getDeployer} from "@redprint-deploy/deployer/DeployScript.sol";
import {DeployConfig} from "@redprint-deploy/deployer/DeployConfig.s.sol";


import { IBigStepper } from "@redprint-core/dispute/interfaces/IBigStepper.sol";
import {  GameType, GameTypes, Claim, Duration } from "@redprint-core/dispute/lib/Types.sol";

// import {AnchorStateRegistry} from "@redprint-core/dispute/AnchorStateRegistry.sol";
import { IAnchorStateRegistry } from "@redprint-core/dispute/interfaces/IAnchorStateRegistry.sol";

import {DisputeGameFactory} from "@redprint-core/dispute/DisputeGameFactory.sol";
import { FaultDisputeGame } from "@redprint-core/dispute/FaultDisputeGame.sol";
import {IDisputeGame} from "@redprint-core/dispute/interfaces/IDisputeGame.sol";

import { PermissionedDisputeGame } from "@redprint-core/dispute/PermissionedDisputeGame.sol";
// import {DelayedWETH} from "@redprint-core/dispute/DelayedWETH.sol";
import { IDelayedWETH } from "@redprint-core/dispute/interfaces/IDelayedWETH.sol";

import { AlphabetVM } from "@redprint-test/mocks/AlphabetVM.sol";

import { IPreimageOracle } from "@redprint-core/dispute/interfaces/IBigStepper.sol";

// import {PreimageOracle} from "@redprint-core/cannon/PreimageOracle.sol";



contract SetFaultGameImplementationScript is Script {

    IDeployer deployerProcedue;

    string mnemonic = vm.envString("MNEMONIC");
    uint256 ownerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1);
    address owner = vm.envOr("DEPLOYER_ADDRESS", vm.addr(ownerPrivateKey));


    function run() public {

        deployerProcedue = getDeployer();
        deployerProcedue.setAutoSave(true);

        console.log("Set FaultGameImplementations Ccontract");

        (VmSafe.CallerMode mode ,address msgSender, ) = vm.readCallers();
        if(mode != VmSafe.CallerMode.Broadcast && msgSender != owner) {
            console.log("Pranking owner ...");
            vm.startPrank(owner);
            setAlphabetFaultGameImplementation({ _allowUpgrade: false });
  
            console.log("Pranking Stopped ...");

            vm.stopPrank();
        } else {
            console.log("Broadcasting ...");
            vm.startBroadcast(owner);
            setAlphabetFaultGameImplementation({ _allowUpgrade: false });
   
            console.log("Broadcasted");

            vm.stopBroadcast();
        }

    }

    struct FaultDisputeGameParams {
        IAnchorStateRegistry anchorStateRegistry;
        IDelayedWETH weth;
        GameType gameType;
        Claim absolutePrestate;
        IBigStepper faultVm;
        uint256 maxGameDepth;
        Duration maxClockDuration;
    }

    function setAlphabetFaultGameImplementation(bool _allowUpgrade) internal {
        console.log("Setting Alphabet FaultDisputeGame implementation");
        DisputeGameFactory factory = DisputeGameFactory(deployerProcedue.mustGetAddress("DisputeGameFactoryProxy"));
        IDelayedWETH weth = IDelayedWETH(deployerProcedue.mustGetAddress("DelayedWETHProxy"));

        DeployConfig cfg = deployerProcedue.getConfig();

        Claim outputAbsolutePrestate = Claim.wrap(bytes32(cfg.faultGameAbsolutePrestate()));
        _setFaultGameImplementation({
            _factory: factory,
            _allowUpgrade: _allowUpgrade,
            _params: FaultDisputeGameParams({
                anchorStateRegistry: IAnchorStateRegistry(deployerProcedue.mustGetAddress("AnchorStateRegistryProxy")),
                weth: weth,
                gameType: GameTypes.ALPHABET,
                absolutePrestate: outputAbsolutePrestate,
                faultVm: IBigStepper(new AlphabetVM(outputAbsolutePrestate, IPreimageOracle(deployerProcedue.mustGetAddress("PreimageOracle")))),
                // The max depth for the alphabet trace is always 3. Add 1 because split depth is fully inclusive.
                maxGameDepth: cfg.faultGameSplitDepth() + 3 + 1,
                maxClockDuration: Duration.wrap(uint64(cfg.faultGameMaxClockDuration()))
            })
        });
    }

    /// @notice Sets the implementation for the given fault game type in the `DisputeGameFactory`.
    function _setFaultGameImplementation(
        DisputeGameFactory _factory,
        bool _allowUpgrade,
        FaultDisputeGameParams memory _params
    )
        internal
    {
        if (address(_factory.gameImpls(_params.gameType)) != address(0) && !_allowUpgrade) {
            console.log(
                "[WARN] DisputeGameFactoryProxy: `FaultDisputeGame` implementation already set for game type: %s",
                vm.toString(GameType.unwrap(_params.gameType))
            );
            return;
        }

        DeployConfig cfg = deployerProcedue.getConfig();
        uint32 rawGameType = GameType.unwrap(_params.gameType);
        if (rawGameType != GameTypes.PERMISSIONED_CANNON.raw()) {

            address faultDisputeGameAddress = address(new FaultDisputeGame({
                _gameType: _params.gameType,
                _absolutePrestate: _params.absolutePrestate,
                _maxGameDepth: _params.maxGameDepth,
                _splitDepth: cfg.faultGameSplitDepth(),
                _clockExtension: Duration.wrap(uint64(cfg.faultGameClockExtension())),
                _maxClockDuration: _params.maxClockDuration,
                _vm: _params.faultVm,
                _weth: _params.weth,
                _anchorStateRegistry: _params.anchorStateRegistry,
                _l2ChainId: cfg.l2ChainID()
            }));
             deployerProcedue.save("FaultDisputeGame", faultDisputeGameAddress);

            _factory.setImplementation(
                _params.gameType,
                IDisputeGame(faultDisputeGameAddress)
            );
           
        } else {
            address permissionedDisputeGameAddress = address(new PermissionedDisputeGame({
                    _gameType: _params.gameType,
                    _absolutePrestate: _params.absolutePrestate,
                    _maxGameDepth: _params.maxGameDepth,
                    _splitDepth: cfg.faultGameSplitDepth(),
                    _clockExtension: Duration.wrap(uint64(cfg.faultGameClockExtension())),
                    _maxClockDuration: Duration.wrap(uint64(cfg.faultGameMaxClockDuration())),
                    _vm: _params.faultVm,
                    _weth: _params.weth,
                    _anchorStateRegistry: _params.anchorStateRegistry,
                    _l2ChainId: cfg.l2ChainID(),
                    _proposer: cfg.l2OutputOracleProposer(),
                    _challenger: cfg.l2OutputOracleChallenger()
            }));
            
            deployerProcedue.save("PermissionedDisputeGame", permissionedDisputeGameAddress);
            _factory.setImplementation(
                _params.gameType,
                IDisputeGame(permissionedDisputeGameAddress)
            );
        }

        string memory gameTypeString;
        if (rawGameType == GameTypes.CANNON.raw()) {
            gameTypeString = "Cannon";
        } else if (rawGameType == GameTypes.PERMISSIONED_CANNON.raw()) {
            gameTypeString = "PermissionedCannon";
        } else if (rawGameType == GameTypes.ALPHABET.raw()) {
            gameTypeString = "Alphabet";
        } else {
            gameTypeString = "Unknown";
        }

        console.log(
            "DisputeGameFactoryProxy: set `FaultDisputeGame` implementation (Backend: %s | GameType: %s)",
            gameTypeString,
            vm.toString(rawGameType)
        );
    }

}
