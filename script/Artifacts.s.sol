// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { console2 as console } from "@forge-std/console2.sol";
import { stdJson } from "@forge-std/StdJson.sol";
import { Vm } from "@forge-std/Vm.sol";
import { Executables } from "@script/Executables.sol";
import { Predeploys } from "@main/libraries/Predeploys.sol";
import { Chains } from "@script/Chains.sol";
import { Config } from "@script/Config.sol";


/// @notice Represents a deployment. Is serialized to JSON as a key/value
///         pair. Can be accessed from within scripts.
struct Deployment {
    string name;
    address payable addr;
}

struct Prank {
    bool active;
    address addr;
}

/// @title Artifacts
/// @notice Useful for accessing deployment artifacts from within scripts.
abstract contract Artifacts {
    /// @notice Foundry cheatcode VM.
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
    /// @notice Error for when attempting to fetch a deployment and it does not exist

    error DeploymentDoesNotExist(string);
    /// @notice Error for when trying to save an invalid deployment
    error InvalidDeployment(string);
    /// @notice The set of deployments that have been done during execution.

    mapping(string => Deployment) internal _namedDeployments;
    /// @notice The same as `_namedDeployments` but as an array.
    Deployment[] internal _newDeployments;
    /// @notice Path to the directory containing the hh deploy style artifacts
    string internal deploymentsDir;
    /// @notice The path to the deployment artifact that is being written to.
    string internal deployArtifactPath;
    /// @notice The namespace for the deployment. Can be set with the env var DEPLOYMENT_CONTEXT.
    string internal deploymentContext;

    string internal chainIdAsString;

    bool internal _autoBroadcast = true;

    Prank internal _prank;

    /// @notice init a deployer with the current context
    /// the context is by default the current chainId
    /// but if the DEPLOYMENT_CONTEXT env variable is set, the context take that value
    /// The context allow you to organise deployments in a set as well as make specific configurations
    function init() external {
        _autoBroadcast = true; // needed as we etch the deployed code and so the initialization in the declaration above is not taken in consideration
        if (bytes(chainIdAsString).length > 0) {
            return;
        }
        // TODO? allow to pass context in constructor
        uint256 currentChainID;
        assembly {
            currentChainID := chainid()
        }
        chainIdAsString = vm.toString(currentChainID);

        // we read the deployment folder for a .chainId file
        // if the chainId here do not match the current one
        // we are using the same context name on different chain, this is an error
        string memory root = vm.projectRoot();
        // The `deploymentContext` should match the name of the deploy-config file.
        deploymentContext = _getDeploymentContext();
        deploymentsDir = string.concat(root, "/deployments/", deploymentContext);

        if (!vm.isDir(deploymentsDir)) {
            vm.createDir(deploymentsDir, true);
        }

        deployArtifactPath = Config.deployArtifactPath(deploymentsDir);
        try vm.readFile(deployArtifactPath) returns (string memory) { }
        catch {
            vm.writeJson("{}", deployArtifactPath);
        }
        console.log("Using deploy artifact %s", deployArtifactPath);

        try vm.createDir(deploymentsDir, true) { } catch (bytes memory) { }

        uint256 chainId = Config.chainID();
        console.log("Connected to network with chainid %s", chainId);

        // Load addresses from a JSON file if the CONTRACT_ADDRESSES_PATH environment variable
        // is set. Great for loading addresses from `superchain-registry`.
        string memory addresses = Config.contractAddressesPath();
        if (bytes(addresses).length > 0) {
            console.log("Loading addresses from %s", addresses);
            _loadAddresses(addresses);
        }

    }

    // --------------------------------------------------------------------------------------------
    // Public Interface
    // --------------------------------------------------------------------------------------------

    function autoBroadcasting() external view returns (bool) {
        return _autoBroadcast;
    }

    function setAutoBroadcast(bool broadcast) external {
        _autoBroadcast = broadcast;
    }

    function activatePrank(address addr) external {
        _prank.active = true;
        _prank.addr = addr;
    }

    function deactivatePrank() external {
        _prank.active = false;
        _prank.addr = address(0);
    }

    function prankStatus() external view returns (bool active, address addr) {
        active = _prank.active;
        addr = _prank.addr;
    }

    /// @notice Populates the addresses to be used in a script based on a JSON file.
    ///         The format of the JSON file is the same that it output by this script
    ///         as well as the JSON files that contain addresses in the `superchain-registry`
    ///         repo. The JSON key is the name of the contract and the value is an address.
    function _loadAddresses(string memory _path) internal {
        string[] memory commands = new string[](3);
        commands[0] = "bash";
        commands[1] = "-c";
        commands[2] = string.concat("jq -cr < ", _path);
        string memory json = string(vm.ffi(commands));
        string[] memory keys = vm.parseJsonKeys(json, "");
        for (uint256 i; i < keys.length; i++) {
            string memory key = keys[i];
            address addr = stdJson.readAddress(json, string.concat("$.", key));
            save(key, addr);
        }
    }

    /// @notice Returns all of the deployments done in the current context.
    function newDeployments() external view returns (Deployment[] memory) {
        return _newDeployments;
    }

    /// @notice Returns whether or not a particular deployment exists.
    /// @param _name The name of the deployment.
    /// @return exists  Whether the deployment exists or not.
    function has(string memory _name) public view returns (bool) {
        Deployment memory existing = _namedDeployments[_name];
        if (existing.addr != address(0)) {
            return bytes(existing.name).length > 0;
        }
        return _getExistingDeploymentAddress(_name) != address(0);
    }

    /// @notice Returns the address of a deployment. Also handles the predeploys.
    /// @param _name The name of the deployment.
    /// @return The address of the deployment. May be `address(0)` if the deployment does not
    ///         exist.
    function getAddress(string memory _name) public view returns (address payable) {
        Deployment memory existing = _namedDeployments[_name];
        if (existing.addr != address(0)) {
            if (bytes(existing.name).length == 0) {
                return payable(address(0));
            }
            return existing.addr;
        }
        address addr = _getExistingDeploymentAddress(_name);
        if (addr != address(0)) return payable(addr);

        bytes32 digest = keccak256(bytes(_name));
        if (digest == keccak256(bytes("L2CrossDomainMessenger"))) {
            return payable(Predeploys.L2_CROSS_DOMAIN_MESSENGER);
        } else if (digest == keccak256(bytes("L2ToL1MessagePasser"))) {
            return payable(Predeploys.L2_TO_L1_MESSAGE_PASSER);
        } else if (digest == keccak256(bytes("L2StandardBridge"))) {
            return payable(Predeploys.L2_STANDARD_BRIDGE);
        } else if (digest == keccak256(bytes("L2ERC721Bridge"))) {
            return payable(Predeploys.L2_ERC721_BRIDGE);
        } else if (digest == keccak256(bytes("SequencerFeeWallet"))) {
            return payable(Predeploys.SEQUENCER_FEE_WALLET);
        } else if (digest == keccak256(bytes("OptimismMintableERC20Factory"))) {
            return payable(Predeploys.OPTIMISM_MINTABLE_ERC20_FACTORY);
        } else if (digest == keccak256(bytes("OptimismMintableERC721Factory"))) {
            return payable(Predeploys.OPTIMISM_MINTABLE_ERC721_FACTORY);
        } else if (digest == keccak256(bytes("L1Block"))) {
            return payable(Predeploys.L1_BLOCK_ATTRIBUTES);
        } else if (digest == keccak256(bytes("GasPriceOracle"))) {
            return payable(Predeploys.GAS_PRICE_ORACLE);
        } else if (digest == keccak256(bytes("L1MessageSender"))) {
            return payable(Predeploys.L1_MESSAGE_SENDER);
        } else if (digest == keccak256(bytes("DeployerWhitelist"))) {
            return payable(Predeploys.DEPLOYER_WHITELIST);
        } else if (digest == keccak256(bytes("WETH9"))) {
            return payable(Predeploys.WETH9);
        } else if (digest == keccak256(bytes("LegacyERC20ETH"))) {
            return payable(Predeploys.LEGACY_ERC20_ETH);
        } else if (digest == keccak256(bytes("L1BlockNumber"))) {
            return payable(Predeploys.L1_BLOCK_NUMBER);
        } else if (digest == keccak256(bytes("LegacyMessagePasser"))) {
            return payable(Predeploys.LEGACY_MESSAGE_PASSER);
        } else if (digest == keccak256(bytes("ProxyAdmin"))) {
            return payable(Predeploys.PROXY_ADMIN);
        } else if (digest == keccak256(bytes("BaseFeeVault"))) {
            return payable(Predeploys.BASE_FEE_VAULT);
        } else if (digest == keccak256(bytes("L1FeeVault"))) {
            return payable(Predeploys.L1_FEE_VAULT);
        } else if (digest == keccak256(bytes("GovernanceToken"))) {
            return payable(Predeploys.GOVERNANCE_TOKEN);
        } else if (digest == keccak256(bytes("SchemaRegistry"))) {
            return payable(Predeploys.SCHEMA_REGISTRY);
        } else if (digest == keccak256(bytes("EAS"))) {
            return payable(Predeploys.EAS);
        }
        return payable(address(0));
    }

    /// @notice Returns the address of a deployment and reverts if the deployment
    ///         does not exist.
    /// @return The address of the deployment.
    function mustGetAddress(string memory _name) public view returns (address payable) {
        address addr = getAddress(_name);
        if (addr == address(0)) {
            revert DeploymentDoesNotExist(_name);
        }
        return payable(addr);
    }

    /// @notice allow to override an existing deployment by ignoring the current one.
    /// the deployment will only be overriden on disk once the broadast is performed and `forge-deploy` sync is invoked.
    /// @param name deployment's name to override
    function ignoreDeployment(string memory name) public {
        _namedDeployments[name].name = "";
        _namedDeployments[name].addr = payable(address(1)); // TO ensure it is picked up as being ignored
    }

    /// @notice Returns a deployment that is suitable to be used to interact with contracts.
    /// @param _name The name of the deployment.
    /// @return deployment The deployment.
    function get(string memory _name) public view returns (Deployment memory) {
        Deployment memory deployment = _namedDeployments[_name];
        if (deployment.addr != address(0)) {
            return deployment;
        } else {
            return _getExistingDeployment(_name);
        }
    }

    /// @notice Appends a deployment to disk as a JSON deploy artifact.
    /// this is a low level call and is used by ./DefaultDeployerFunction.sol
    /// @param _name deployment's name
    /// @param _deployed address of the deployed contract
    // / @param artifact forge's artifact path <solidity file>.sol:<contract name>
    // / @param args arguments' bytes provided to the constructor
    // / @param bytecode the contract's bytecode used to deploy the contract
    function save(
        string memory _name,
        address _deployed
    ) public {
        if (bytes(_name).length == 0) {
            revert InvalidDeployment("EmptyName");
        }
        if (bytes(_namedDeployments[_name].name).length > 0) {
            revert InvalidDeployment("AlreadyExists");
        }

        console.log("Saving %s: %s", _name, _deployed);
        Deployment memory deployment = Deployment({ name: _name, addr: payable(_deployed) });
        _namedDeployments[_name] = deployment;
        _newDeployments.push(deployment);
        _appendDeployment(_name, _deployed);
    }

    /// @notice Adds a deployment to the temp deployments file
    function _appendDeployment(string memory _name, address _deployed) internal {
        vm.writeJson({ json: stdJson.serialize("", _name, _deployed), path: deployArtifactPath });
    }

    /// @notice Reads the artifact from the filesystem by name and returns the address.
    /// @param _name The name of the artifact to read.
    /// @return The address of the artifact.
    function _getExistingDeploymentAddress(string memory _name) internal view returns (address payable) {
        return _getExistingDeployment(_name).addr;
    }

    /// @notice Reads the artifact from the filesystem by name and returns the Deployment.
    /// @param _name The name of the artifact to read.
    /// @return The deployment corresponding to the name.
    function _getExistingDeployment(string memory _name) internal view returns (Deployment memory) {
        string memory path = string.concat(deploymentsDir, "/", _name, ".json");
        try vm.readFile(path) returns (string memory json) {
            address addr = stdJson.readAddress(json, "$.address");
            return Deployment({ addr: payable(addr), name: _name });
        } catch {
            return Deployment({ addr: payable(address(0)), name: "" });
        }
    }

    /// @notice Stubs a deployment retrieved through `get`.
    /// @param _name The name of the deployment.
    /// @param _addr The mock address of the deployment.
    function prankDeployment(string memory _name, address _addr) public {
        if (bytes(_name).length == 0) {
            revert InvalidDeployment("EmptyName");
        }

        Deployment memory deployment = Deployment({ name: _name, addr: payable(_addr) });
        _namedDeployments[_name] = deployment;
    }

    /// @notice The context of the deployment is used to namespace the artifacts.
    ///         An unknown context will use the chainid as the context name.
    ///         This is legacy code and should be removed in the future.
    function _getDeploymentContext() private view returns (string memory) {
        string memory context = Config.deploymentContext();
        if (bytes(context).length > 0) {
            return context;
        }

        uint256 chainid = Config.chainID();
        if (chainid == Chains.Mainnet) {
            return "mainnet";
        } else if (chainid == Chains.Goerli) {
            return "goerli";
        } else if (chainid == Chains.OPGoerli) {
            return "optimism-goerli";
        } else if (chainid == Chains.OPMainnet) {
            return "optimism-mainnet";
        } else if (chainid == Chains.LocalDevnet || chainid == Chains.GethDevnet) {
            return "devnetL1";
        } else if (chainid == Chains.Hardhat) {
            return "hardhat";
        } else if (chainid == Chains.Sepolia) {
            return "sepolia";
        } else if (chainid == Chains.OPSepolia) {
            return "optimism-sepolia";
        } else {
            return vm.toString(chainid);
        }
    }

}
