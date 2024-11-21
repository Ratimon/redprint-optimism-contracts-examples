// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Initializable} from "@redprint-openzeppelin/proxy/utils/Initializable.sol";
import {ISemver} from "@redprint-core/universal/interfaces/ISemver.sol";
import "@redprint-core/dispute/lib/Types.sol";
import {Unauthorized} from "@redprint-core/libraries/errors/CommonErrors.sol";
import {UnregisteredGame, InvalidGameStatus} from "@redprint-core/dispute/lib/Errors.sol";
import {IFaultDisputeGame} from "@redprint-core/dispute/interfaces/IFaultDisputeGame.sol";
import {IDisputeGame} from "@redprint-core/dispute/interfaces/IDisputeGame.sol";
import {IDisputeGameFactory} from "@redprint-core/dispute/interfaces/IDisputeGameFactory.sol";
import {ISuperchainConfig} from "@redprint-core/L1/interfaces/ISuperchainConfig.sol";

/// @custom:security-contact Consult full code at https://github.com/ethereum-optimism/optimism/blob/v1.9.4/packages/contracts-bedrock/src/dispute/AnchorStateRegistry.sol
contract AnchorStateRegistry is Initializable, ISemver {
    /// @notice Describes an initial anchor state for a game type.
    struct StartingAnchorRoot {
        GameType gameType;
        OutputRoot outputRoot;
    }
    /// @notice Semantic version.
    /// @custom:semver 2.0.1-beta.3
    string public constant version = "2.0.1-beta.3";
    /// @notice DisputeGameFactory address.
    IDisputeGameFactory internal immutable DISPUTE_GAME_FACTORY;
    /// @notice Returns the anchor state for the given game type.
    mapping(GameType => OutputRoot) public anchors;
    /// @notice Address of the SuperchainConfig contract.
    ISuperchainConfig public superchainConfig;

    constructor(IDisputeGameFactory _disputeGameFactory) {
        DISPUTE_GAME_FACTORY = _disputeGameFactory;
        _disableInitializers();
    }

    function initialize(StartingAnchorRoot[] memory _startingAnchorRoots, ISuperchainConfig _superchainConfig)
        public
        initializer
    {
        for (uint256 i = 0; i < _startingAnchorRoots.length; i++) {
            StartingAnchorRoot memory startingAnchorRoot = _startingAnchorRoots[i];
            anchors[startingAnchorRoot.gameType] = startingAnchorRoot.outputRoot;
        }
        superchainConfig = _superchainConfig;
    }

    function disputeGameFactory() external view returns (IDisputeGameFactory) {
        return DISPUTE_GAME_FACTORY;
    }

    function tryUpdateAnchorState() external {
        // Grab the game and game data.
        IFaultDisputeGame game = IFaultDisputeGame(msg.sender);
        (GameType gameType, Claim rootClaim, bytes memory extraData) = game.gameData();

        // Grab the verified address of the game based on the game data.
        // slither-disable-next-line unused-return
        (IDisputeGame factoryRegisteredGame,) =
            DISPUTE_GAME_FACTORY.games({ _gameType: gameType, _rootClaim: rootClaim, _extraData: extraData });

        // Must be a valid game.
        if (address(factoryRegisteredGame) != address(game)) revert UnregisteredGame();

        // No need to update anything if the anchor state is already newer.
        if (game.l2BlockNumber() <= anchors[gameType].l2BlockNumber) {
            return;
        }

        // Must be a game that resolved in favor of the state.
        if (game.status() != GameStatus.DEFENDER_WINS) {
            return;
        }

        // Actually update the anchor state.
        anchors[gameType] = OutputRoot({ l2BlockNumber: game.l2BlockNumber(), root: Hash.wrap(game.rootClaim().raw()) });
    }

    function setAnchorState(IFaultDisputeGame _game) external {
        if (msg.sender != superchainConfig.guardian()) revert Unauthorized();

        // Get the metadata of the game.
        (GameType gameType, Claim rootClaim, bytes memory extraData) = _game.gameData();

        // Grab the verified address of the game based on the game data.
        // slither-disable-next-line unused-return
        (IDisputeGame factoryRegisteredGame,) =
            DISPUTE_GAME_FACTORY.games({ _gameType: gameType, _rootClaim: rootClaim, _extraData: extraData });

        // Must be a valid game.
        if (address(factoryRegisteredGame) != address(_game)) revert UnregisteredGame();

        // The game must have resolved in favor of the root claim.
        if (_game.status() != GameStatus.DEFENDER_WINS) revert InvalidGameStatus();

        // Update the anchor.
        anchors[gameType] =
            OutputRoot({ l2BlockNumber: _game.l2BlockNumber(), root: Hash.wrap(_game.rootClaim().raw()) });
    }
}
